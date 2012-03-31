Strict

Import "framework.bmx"

New TNeHe23.Run(23,"EnvironMent Mapping")

Type TNeHe23 Extends TNeHe	
	Field ScreenWidth:Int=800
	Field ScreenHeight:Int=600
	Field ScreenDepth:Int=32
	
	Field light:Byte				' Lighting ON/OFF
	Field xrot:Float				' X Rotation
	Field yrot:Float				' Y Rotation
	Field xspeed:Float			' X Rotation Speed
	Field yspeed:Float			' Y Rotation Speed
	Field z:Float=-10.0			' Depth Into The Screen
	
	Field quadratic:Int Ptr		' Storage For Our Quadratic Objects
	
	Field LightAmbient:Float[]=[0.5, 0.5, 0.5, 1.0]
	Field LightDiffuse:Float[]=[1.0, 1.0, 1.0, 1.0]
	Field LightPosition:Float[]=[0.0, 0.0, 2.0, 1.0]
	
	Field Texname:Int[6]			' Storage For 6 Textures
	Field Filter:Int=0			' Which Filter To Use
	Field Objet:Int=1			' Which Object To Draw
	
	Field LighNotifi:String[]=["OFF","ON"]
	Field TextureNotifi:String[]=["NEAREST","LINEAR","MIPMAP"]
	Field FormNotifi:String[]=["Cube","Cylinder","Sphere","Cone"]
	
	
	Method Init()
		LoadGlTextures()
		glEnable(GL_TEXTURE_2D)											' Enable Texture Mapping
		glShadeModel(GL_SMOOTH)											' Enable Smooth Shading
		glClearColor(0.0, 0.0, 0.0, 0.5)									' Black Background
		glClearDepth(1.0)													' Depth Buffer Setup
		glEnable(GL_DEPTH_TEST)											' Enables Depth Testing
		glDepthFunc(GL_LEQUAL)												' The Type Of Depth Testing To Do
		glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST)					' Really Nice Perspective Calculations
	
		glLightfv(GL_LIGHT1, GL_AMBIENT, LightAmbient)						' Setup The Ambient Light
		glLightfv(GL_LIGHT1, GL_DIFFUSE, LightDiffuse)						' Setup The Diffuse Light
		glLightfv(GL_LIGHT1, GL_POSITION,LightPosition)						' Position The Light
		glEnable(GL_LIGHT1)												' Enable Light One
	
		quadratic=Int Ptr gluNewQuadric()									' Create A Pointer To The Quadric Object (Return 0 If No Memory)
		gluQuadricNormals(quadratic, GL_SMOOTH)							' Create Smooth Normals
		gluQuadricTexture(quadratic, GL_TRUE)								' Create Texture Coords
	
		glTexGeni(GL_S, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP)					' Set The Texture Generation Mode For S To Sphere Mapping
		glTexGeni(GL_T, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP)					' Set The Texture Generation Mode For T To Sphere Mapping	
		
		glViewport(0,0,ScreenWidth,ScreenHeight)							' Set viewport
		glMatrixMode(GL_PROJECTION)										' Select The Projection Matrix
		glLoadIdentity()													' Reset The Projection Matrix
		gluPerspective(45.0,Float(ScreenWidth)/Float(ScreenHeight),0.1,100.0)	' Calculate The Aspect Ratio Of The Window
		glMatrixMode(GL_MODELVIEW)											' Select The Modelview Matrix
		glLoadIdentity()													' Reset The Modelview Matrix
	End Method
	
	Method LoadGlTextures()
		Local loop:Int
		Local TextureImage:TPixmap[2]
		TextureImage:TPixmap[0]=LoadPixmap("data\Reflect.bmp")				' Flip image vertically
		TextureImage:TPixmap[0]=YFlipPixmap(TextureImage[0])
		TextureImage:TPixmap[1]=LoadPixmap("data\BG.bmp")
		TextureImage:TPixmap[1]=YFlipPixmap(TextureImage[1])					' Flip image vertically
		
		glGenTextures(6, Varptr Texname[0])									' Create Three Textures
		For loop=0 To 1
			' Create Nearest Filtered Texture
			glBindTexture(GL_TEXTURE_2D, Texname[loop])						' Gen Tex 0 And 1
			glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_NEAREST)
			glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST)
			glTexImage2D(GL_TEXTURE_2D, 0, 3, TextureImage[loop].width, TextureImage[loop].height, 0, GL_RGB, GL_UNSIGNED_BYTE, TextureImage[loop].pixels)
			' Create Linear Filtered Texture
			glBindTexture(GL_TEXTURE_2D, Texname[loop+2])					' Gen Tex 2 And 3
			glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
			glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
			glTexImage2D(GL_TEXTURE_2D, 0, 3, TextureImage[loop].width, TextureImage[loop].height, 0, GL_RGB, GL_UNSIGNED_BYTE, TextureImage[loop].pixels)
			' Create MipMapped Texture
			glBindTexture(GL_TEXTURE_2D, Texname[loop+4])					' Gen Tex 4 And 5
			glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
			glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR_MIPMAP_NEAREST);
			gluBuild2DMipmaps(GL_TEXTURE_2D, 3, TextureImage[loop].width, TextureImage[loop].height, GL_RGB, GL_UNSIGNED_BYTE, TextureImage[loop].pixels)
		Next
	End Method
	
	Method Loop()
		If KeyHit(KEY_L) Then						
			light=Not light
		EndIf
		If  light=0 Then
			glDisable(GL_LIGHTING)
		Else
			glEnable(GL_LIGHTING)
		EndIf
		
		If KeyHit(KEY_T)
			Filter:+1
			If Filter>2 Then Filter=0
		EndIf
		
		If KeyHit(KEY_SPACE)
			Objet:+1
			If Objet>3 Then Objet=0
		EndIf
		If KeyDown(KEY_PAGEUP) Then z:-0.02
		If KeyDown(KEY_PAGEDOWN) Then z:+0.02
		If KeyDown(KEY_UP) Then xspeed:-0.01
		If KeyDown(KEY_DOWN) Then xspeed:+0.01
		If KeyDown(KEY_RIGHT) Then yspeed:+0.01
		If KeyDown(KEY_LEFT) Then yspeed:-0.01
		
		glClear GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT			' Clear The Screen And The Depth Buffer
		glLoadIdentity()											' Reset The Current Modelview Matrix
		glTranslatef(0.0,0.0,z)
		glEnable(GL_TEXTURE_GEN_S)									' Enable Texture Coord Generation For S
		glEnable(GL_TEXTURE_GEN_T)									' Enable Texture Coord Generation For T
	
		glBindTexture(GL_TEXTURE_2D, Texname[filter*2])				' This Will Select The Sphere Map
		glPushMatrix()											' Push current matrix
		glRotatef(xrot,1.0,0.0,0.0)
		glRotatef(yrot,0.0,1.0,0.0)
		Select Objet
			Case 0
			glDrawCube()
			Case 1
			glTranslatef(0.0,0.0,-1.5)								' Center The Cylinder
			gluCylinder(quadratic,1.0,1.0,3.0,32,32)				' A Cylinder With A Radius Of 0.5 And A Height Of 2
			Case 2
			gluSphere(quadratic,1.3,32,32)							' Draw A Sphere With A Radius Of 1 And 16 Longitude And 16 Latitude Segments
			Case 3
			glTranslatef(0.0,0.0,-1.5)								' Center The Cone
			gluCylinder(quadratic,1.0,0.0,3.0,32,32)				' A Cone With A Bottom Radius Of .5 And A Height Of 2
		End Select
	
		glPopMatrix()												' Reset the matix previously pushed
		glDisable(GL_TEXTURE_GEN_S)								' Disable Texture Coord Generation For S
		glDisable(GL_TEXTURE_GEN_T)								' Disable Texture Coord Generation For T
	
		glBindTexture(GL_TEXTURE_2D, Texname[filter*2+1])			' This Will Select The BG Maps...
		glPushMatrix()											' Push current matrix
			glTranslatef(0.0, 0.0, -24.0)
			glBegin(GL_QUADS)
				glNormal3f( 0.0, 0.0, 1.0)
				glTexCoord2f(0.0, 0.0); glVertex3f(-13.3, -10.0,  10.0)
				glTexCoord2f(1.0, 0.0); glVertex3f( 13.3, -10.0,  10.0)
				glTexCoord2f(1.0, 1.0); glVertex3f( 13.3,  10.0,  10.0)
				glTexCoord2f(0.0, 1.0); glVertex3f(-13.3,  10.0,  10.0)
			glEnd()
		glPopMatrix()												' Reset the matix previously pushed
	
		xrot:+xspeed
		yrot:+yspeed
	End Method
	
	Method glDrawCube()
		glBegin(GL_QUADS)
			' Front Face
			glNormal3f( 0.0, 0.0, 0.5)
			glTexCoord2f(0.0, 0.0); glVertex3f(-1.0, -1.0,  1.0)
			glTexCoord2f(1.0, 0.0); glVertex3f( 1.0, -1.0,  1.0)
			glTexCoord2f(1.0, 1.0); glVertex3f( 1.0,  1.0,  1.0)
			glTexCoord2f(0.0, 1.0); glVertex3f(-1.0,  1.0,  1.0)
			' Back Face
			glNormal3f( 0.0, 0.0,-0.5)
			glTexCoord2f(1.0, 0.0); glVertex3f(-1.0, -1.0, -1.0)
			glTexCoord2f(1.0, 1.0); glVertex3f(-1.0,  1.0, -1.0)
			glTexCoord2f(0.0, 1.0); glVertex3f( 1.0,  1.0, -1.0)
			glTexCoord2f(0.0, 0.0); glVertex3f( 1.0, -1.0, -1.0)
			' Top Face
			glNormal3f( 0.0, 0.5, 0.0)
			glTexCoord2f(0.0, 1.0); glVertex3f(-1.0,  1.0, -1.0)
			glTexCoord2f(0.0, 0.0); glVertex3f(-1.0,  1.0,  1.0)
			glTexCoord2f(1.0, 0.0); glVertex3f( 1.0,  1.0,  1.0)
			glTexCoord2f(1.0, 1.0); glVertex3f( 1.0,  1.0, -1.0)
			' Bottom Face
			glNormal3f( 0.0,-0.5, 0.0)
			glTexCoord2f(1.0, 1.0); glVertex3f(-1.0, -1.0, -1.0)
			glTexCoord2f(0.0, 1.0); glVertex3f( 1.0, -1.0, -1.0)
			glTexCoord2f(0.0, 0.0); glVertex3f( 1.0, -1.0,  1.0)
			glTexCoord2f(1.0, 0.0); glVertex3f(-1.0, -1.0,  1.0)
			' Right Face
			glNormal3f( 0.5, 0.0, 0.0)
			glTexCoord2f(1.0, 0.0); glVertex3f( 1.0, -1.0, -1.0)
			glTexCoord2f(1.0, 1.0); glVertex3f( 1.0,  1.0, -1.0)
			glTexCoord2f(0.0, 1.0); glVertex3f( 1.0,  1.0,  1.0)
			glTexCoord2f(0.0, 0.0); glVertex3f( 1.0, -1.0,  1.0)
			' Left Face
			glNormal3f(-0.5, 0.0, 0.0)
			glTexCoord2f(0.0, 0.0); glVertex3f(-1.0, -1.0, -1.0)
			glTexCoord2f(1.0, 0.0); glVertex3f(-1.0, -1.0,  1.0)
			glTexCoord2f(1.0, 1.0); glVertex3f(-1.0,  1.0,  1.0)
			glTexCoord2f(0.0, 1.0); glVertex3f(-1.0,  1.0, -1.0)
		glEnd()
	End Method
	
	Method DrawMenu(Framecounter_framerate,ShowMenu)
		glDisable(GL_TEXTURE_2D)	
		glDisable(GL_DEPTH_TEST)	
		glDisable(GL_LIGHT1)
		glDisable(GL_LIGHTING)
		glColor3f(1.0,1.0,1.0)
		GLDrawText("F1 : Hide/Show menu",10,ScreenHeight-16-8)
		GLDrawText("FPS : "+Framecounter_framerate,ScreenWidth-(8*12),ScreenHeight-16-8)
		If ShowMenu Then
			GLDrawText("NeHe & TipTup's Environment Mapping Tutorial (lesson 23)",10,24)
		
			GLDrawText("'T' Texture filter : " + TextureNotifi[Filter],10,56)
			GLDrawText("'L' Light          : " + LighNotifi[light],10,72)
			GLDrawText("'SPACE' Quadratic  : " + FormNotifi[Objet],10,88)
		EndIf
		glEnable(GL_LIGHTING)
		glEnable(GL_LIGHT1)
		glEnable(GL_DEPTH_TEST)
		glEnable(GL_TEXTURE_2D)
	End Method
End Type