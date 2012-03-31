Strict

Import "framework.bmx"

New TNeHe12.run(12,"Display lists")

Type TNeHe12 Extends TNeHe

	Field box:Int			' Storage For The Box Display List
	Field top:Int			' Storage For The Top Display List
	
	Field xrot:Float			' Rotates Cube On The X Axis
	Field yrot:Float			' Rotates Cube On The Y Axis
	
	Field boxcol:Float[]=[1.0,0.0,0.0,1.0,0.5,0.0,1.0,1.0,0.0,0.0,1.0,0.0,0.0,1.0,1.0]
	Field topcol:Float[]=[0.5,0.0,0.0,0.5,0.25,0.0,0.5,0.5,0.0,0.0,0.5,0.0,0.0,0.5,0.5]
	
	Field Checkimage:Byte[128,128,3]
	Field Texname:Int				' Storage for 1 texture
	 
	Method Init()
		LoadGlTextures()														' Load The Texture(s)
		BuildLists()
		glEnable GL_TEXTURE_2D													' Enable Texture Mapping
		glClearColor(0.0, 0.0, 0.0, 0.5)										' This Will Clear The Background Color To Black
		glClearDepth 1.0														' Enables Clearing Of The Depth Buffer
		glDepthFunc GL_LESS													' The Type Of Depth Test To Do
		glEnable GL_DEPTH_TEST													' Enables Depth Testing
		glShadeModel(GL_SMOOTH)												' Enables Smooth Color Shading
		glEnable(GL_LIGHT0)													' Quick And Dirty Lighting (Assumes Light0 Is Set Up)
		glEnable(GL_LIGHTING)													' Enable Lighting
		glEnable(GL_COLOR_MATERIAL)											' Enable Material Coloring
		glViewport(0,0,ScreenWidth,ScreenHeight)								' Set viewport
		glMatrixMode(GL_PROJECTION)
		glLoadIdentity()														' Reset The Projection Matrix
		gluPerspective(45.0,Float(ScreenWidth)/Float(ScreenHeight),0.5,100.0)		' Calculate The Aspect Ratio Of The Window
		glMatrixMode(GL_MODELVIEW)
	End Method

	Method LoadGlTextures()
		Local PointeurImg:Byte Ptr
		Local TexWidth
		Local TexHeight
		Local tex01:TPixmap=LoadPixmap("data\cube.bmp")
		TexWidth=tex01.Width
		TexHeight=tex01.Height
		PointeurImg=PixmapPixelPtr(tex01,0,0)
		Local pp:Int=0
		For Local y:Int=TexHeight-1 To 0 Step -1
			For Local x:int=0 To TexWidth-1
				Checkimage[y,x,0]=PointeurImg[pp]
				Checkimage[y,x,1]=PointeurImg[pp+1]
				Checkimage[y,x,2]=PointeurImg[pp+2]
				pp=pp+3
			Next
		Next
		' Create Texture
		glGenTextures 1, Varptr Texname
		glBindTexture GL_TEXTURE_2D,Texname
		glTexParameteri GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR
		glTexParameteri GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR
		glTexImage2D GL_TEXTURE_2D, 0, 3, TexWidth, TexHeight, 0, GL_RGB, GL_UNSIGNED_BYTE, Checkimage
	End Method

	Method loop()
		Local yloop:Int
		Local xloop:Int
	
		If KeyDown(KEY_LEFT) Then yrot:-0.2
		If KeyDown(KEY_RIGHT) Then yrot:+0.2
		If KeyDown(KEY_UP) Then xrot:-0.2
		If KeyDown(KEY_DOWN) Then xrot:+0.2
		
		glClear GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT		' Clear The Screen And The Depth Buffer
		glBindTexture(GL_TEXTURE_2D, Texname)
		For yloop=1 To 5
			For xloop=0 To yloop-1
				glLoadIdentity()								' Reset The View
				glTranslatef(1.4+(Float(xloop)*2.8)-(Float(yloop)*1.4),((6.0-Float(yloop))*2.4)-7.0,-20.0)
				glRotatef(45.0-(2.0*Float(yloop))+xrot,1.0,0.0,0.0)
				glRotatef(45.0+yrot,0.0,1.0,0.0)
				glColor3fv(Varptr boxcol[yloop-1])										'(boxcol[yloop-1])
				glCallList(box)
				glColor3fv(Varptr topcol[yloop-1])
				glCallList(top)
			Next
		Next
	End Method
	
	' Build Cube Display Lists
	Method BuildLists()
		box=glGenLists(2)													' Generate 2 Different Lists
		glNewList(box,GL_COMPILE)											' Start With The Box List
			glBegin(GL_QUADS)
				' Bottom Face
				glNormal3f( 0.0,-1.0, 0.0)
				glTexCoord2f(1.0, 1.0); glVertex3f(-1.0, -1.0, -1.0)
				glTexCoord2f(0.0, 1.0); glVertex3f( 1.0, -1.0, -1.0)
				glTexCoord2f(0.0, 0.0); glVertex3f( 1.0, -1.0,  1.0)
				glTexCoord2f(1.0, 0.0); glVertex3f(-1.0, -1.0,  1.0)
				' Front Face
				glNormal3f( 0.0, 0.0, 1.0)
				glTexCoord2f(0.0, 0.0); glVertex3f(-1.0, -1.0,  1.0)
				glTexCoord2f(1.0, 0.0); glVertex3f( 1.0, -1.0,  1.0)
				glTexCoord2f(1.0, 1.0); glVertex3f( 1.0,  1.0,  1.0)
				glTexCoord2f(0.0, 1.0); glVertex3f(-1.0,  1.0,  1.0)
				' Back Face
				glNormal3f( 0.0, 0.0,-1.0)
				glTexCoord2f(1.0, 0.0); glVertex3f(-1.0, -1.0, -1.0)
				glTexCoord2f(1.0, 1.0); glVertex3f(-1.0,  1.0, -1.0)
				glTexCoord2f(0.0, 1.0); glVertex3f( 1.0,  1.0, -1.0)
				glTexCoord2f(0.0, 0.0); glVertex3f( 1.0, -1.0, -1.0)
				' Right face
				glNormal3f( 1.0, 0.0, 0.0)
				glTexCoord2f(1.0, 0.0); glVertex3f( 1.0, -1.0, -1.0)
				glTexCoord2f(1.0, 1.0); glVertex3f( 1.0,  1.0, -1.0)
				glTexCoord2f(0.0, 1.0); glVertex3f( 1.0,  1.0,  1.0)
				glTexCoord2f(0.0, 0.0); glVertex3f( 1.0, -1.0,  1.0)
				' Left Face
				glNormal3f(-1.0, 0.0, 0.0)
				glTexCoord2f(0.0, 0.0); glVertex3f(-1.0, -1.0, -1.0)
				glTexCoord2f(1.0, 0.0); glVertex3f(-1.0, -1.0,  1.0)
				glTexCoord2f(1.0, 1.0); glVertex3f(-1.0,  1.0,  1.0)
				glTexCoord2f(0.0, 1.0); glVertex3f(-1.0,  1.0, -1.0)
			glEnd()
		glEndList()
		top=box+1														' Storage For "Top" Is "Box" Plus One
		glNewList(top,GL_COMPILE)											' Now The "Top" Display List
			glBegin(GL_QUADS)
				' Top Face
				glNormal3f( 0.0, 1.0, 0.0);
				glTexCoord2f(0.0, 1.0); glVertex3f(-1.0,  1.0, -1.0);
				glTexCoord2f(0.0, 0.0); glVertex3f(-1.0,  1.0,  1.0);
				glTexCoord2f(1.0, 0.0); glVertex3f( 1.0,  1.0,  1.0);
				glTexCoord2f(1.0, 1.0); glVertex3f( 1.0,  1.0, -1.0);
			glEnd()
		glEndList()
	End Method

End Type