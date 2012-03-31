Strict

Import "framework.bmx"

Const STARCOUNT = 50

New TNeHe11.Run(11, "Flag effect")

Type TNeHe11 Extends TNeHe
	
	Field points:Float[45,45,3]	' The array for the points on the grid of our "wave"
	Field wiggle_count:Int=0
	Field xrot:Float				' X Rotation
	Field yrot:Float				' Y Rotation
	Field zrot:Float				' Z Rotation
	Field hold:Float				' Temporarily holds a floating point value
	
	Field Checkimage:Byte[256,256,3]
	Field Texname:Int			' Storage for 1 texture

	Method  Init()
		Local float_x:Float, float_y:Float
		Local x:Int, y:Int
		LoadGlTextures()														' Load The Texture(s)
		glEnable GL_TEXTURE_2D													' Enable Texture Mapping
		glClearColor(0.0, 0.0, 0.0, 0.5)										' This Will Clear The Background Color To Black
		glClearDepth 1.0														' Enables Clearing Of The Depth Buffer
		glDepthFunc GL_LESS														' The Type Of Depth Test To Do
		glEnable GL_DEPTH_TEST													' Enables Depth Testing
		glShadeModel(GL_SMOOTH)													' Enables Smooth Color Shading
		glViewport(0,0,ScreenWidth,ScreenHeight)								' Set viewport
		glMatrixMode(GL_PROJECTION)
		glLoadIdentity()														' Reset The Projection Matrix
		gluPerspective(45.0,Float(ScreenWidth)/Float(ScreenHeight),0.5,100.0)	' Calculate The Aspect Ratio Of The Window
		glMatrixMode(GL_MODELVIEW)
		glPolygonMode(GL_BACK, GL_FILL)											' Back Face Is Solid
		glPolygonMode(GL_FRONT, GL_LINE)										' Front Face Is Made Of Lines
		
		For x=0 To 44
			For y=0 To 44
				points[x,y,0]=(Float(x)/5.0)-4.5
				points[x,y,1]=(Float(y)/5.0)-4.5
				points[x,y,2]=Sin((Float(x)/5.0)*40.0)
			Next
		Next
	End Method


	Method LoadGlTextures()
		Local PointeurImg:Byte Ptr
		Local TexWidth
		Local TexHeight
		Local tex01:TPixmap=LoadPixmap("data\tim.bmp")
		TexWidth=tex01.Width
		TexHeight=tex01.Height
		PointeurImg=PixmapPixelPtr(tex01,0,0)
		Local pp:Float=0
		For Local y:Int=TexHeight-1 To 0 Step -1
			For Local x:Int=0 To TexWidth-1
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
		Local x:Int
		Local y:Int
		Local float_x:Float
		Local float_y:Float
		Local float_xb:Float
		Local float_yb:Float
	
		glClear GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT
		glLoadIdentity
		glTranslatef 0.0, 0.0, -12.0
		glRotatef xrot, 1.0, 0.0, 0.0
		glRotatef yrot, 0.0, 1.0, 0.0  
		glRotatef zrot, 0.0, 0.0, 1.0
		glBindTexture GL_TEXTURE_2D, Texname
		glPolygonMode GL_BACK, GL_FILL
		glPolygonMode GL_FRONT, GL_LINE
		glBegin GL_QUADS
			For x = 0 To 43
				For y = 0 To 43
					float_x = Float(x)/44.0
					float_y = Float(y)/44.0
					float_xb = Float(x+1)/44.0
					float_yb = Float(y+1)/44.0
					glTexCoord2f float_x, float_y
					glVertex3f points[x,y,0], points[x,y,1], points[x,y,2]
	
					glTexCoord2f float_x, float_yb
					glVertex3f points[x,y+1,0], points[x,y+1,1], points[x,y+1,2]
	
					glTexCoord2f float_xb, float_yb
					glVertex3f points[x+1,y+1,0], points[x+1,y+1,1], points[x+1,y+1,2]
	
					glTexCoord2f float_xb, float_y
					glVertex3f points[x+1,y,0], points[x+1,y,1], points[x+1,y,2]
				Next
			Next
		glEnd
	
		If wiggle_count = 2 Then
			For y = 0 To 44
				hold=points[0,y,2]
				For x=0 To 43
					points[x,y,2] = points[x+1,y,2]
				Next
				points[44,y,2] = hold
			Next
			wiggle_count = 0
		End If
	
		wiggle_count:+1
		xrot:+ 0.3
		yrot:+ 0.2
		zrot:+ 0.4
	End Method 

End Type