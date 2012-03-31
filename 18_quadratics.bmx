Strict
Import "framework.bmx"

New TNehe18.Run(18,"Quadratics")

Type TNeHe18 Extends TNehe
	Field light:Byte				' Lighting ON/OFF
	
	Field part1:Int				' Start Of Disc
	Field part2:Int				' End Of Disc
	Field p1:Int=0				' Increase 1
	Field p2:Int=1				' Increase 2
	
	Field xrot:Float				' X Rotation
	Field yrot:Float				' Y Rotation
	Field xspeed:Float			' X Rotation Speed
	Field yspeed:Float			' Y Rotation Speed
	Field z:Float=-5.0			' Depth Into The Screen
	
	Field quadratic:Int Ptr		' Storage For Our Quadratic Objects
	
	Field LightAmbient:Float[]=[0.5, 0.5, 0.5, 1.0]
	Field LightDiffuse:Float[]=[1.0, 1.0, 1.0, 1.0]
	Field LightPosition:Float[]=[0.0, 0.0, 2.0, 1.0]
	
	Field Texname:Int[3]			' Storage For 3 Textures
	Field Filter:Int=0			' Which Filter To Use
	Field Objet:Int=0			' Which Object To Draw
	
	Field LighNotifi:String[]=["OFF","ON"]
	Field TextureNotifi:String[]=["NEAREST","LINEAR","MIPMAP"]
	Field FormNotifi:String[]=["Cube","Cylinder","Disk","sphere","Cone","Partial disk"]


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
	
		glViewport(0,0,ScreenWidth,ScreenHeight)							' Set viewport
		glMatrixMode(GL_PROJECTION)										' Select The Projection Matrix
		glLoadIdentity()													' Reset The Projection Matrix
		gluPerspective(45.0,Float(ScreenWidth)/Float(ScreenHeight),0.1,100.0)	' Calculate The Aspect Ratio Of The Window
		glMatrixMode(GL_MODELVIEW)											' Select The Modelview Matrix
		glLoadIdentity()
	End Method
	
	Method LoadGlTextures()
		Local TextureImage:TPixmap
		TextureImage:TPixmap=LoadPixmap("data\Wall.bmp")
	
		glGenTextures(3, Varptr Texname[0])						' Create Three Textures
		' Create Nearest Filtered Texture
		glBindTexture(GL_TEXTURE_2D, Texname[0])
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_NEAREST)
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST)
		glTexImage2D(GL_TEXTURE_2D, 0, 3, TextureImage.width, TextureImage.height, 0, GL_RGB, GL_UNSIGNED_BYTE, TextureImage.pixels)
		' Create Linear Filtered Texture
		glBindTexture(GL_TEXTURE_2D, Texname[1])
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
		glTexImage2D(GL_TEXTURE_2D, 0, 3, TextureImage.width, TextureImage.height, 0, GL_RGB, GL_UNSIGNED_BYTE, TextureImage.pixels)
		' Create MipMapped Texture
		glBindTexture(GL_TEXTURE_2D, Texname[2])
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR_MIPMAP_NEAREST);
		gluBuild2DMipmaps(GL_TEXTURE_2D, 3, TextureImage.width, TextureImage.height, GL_RGB, GL_UNSIGNED_BYTE, TextureImage.pixels)
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
			If Objet>5 Then Objet=0
		EndIf
			
		If KeyDown(KEY_PAGEUP) Then z:-0.02
		If KeyDown(KEY_PAGEDOWN) Then z:+0.02
		If KeyHit(KEY_UP) Then xspeed:-0.01
		If KeyHit(KEY_DOWN) Then xspeed:+0.01
		If KeyHit(KEY_RIGHT) Then yspeed:+0.01
		If KeyHit(KEY_LEFT) Then yspeed:-0.01
	
		glClear GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT			' Clear The Screen And The Depth Buffer
		glLoadIdentity()											' Reset The Current Modelview Matrix
		glTranslatef(0.0,0.0,z)
		glRotatef(xrot,1.0,0.0,0.0)
		glRotatef(yrot,0.0,1.0,0.0)
		glBindTexture(GL_TEXTURE_2D, Texname[filter])
	
		Select Objet
			Case 0
			glDrawCube()
			Case 1
			glTranslatef(0.0,0.0,-1.5)							' Center The Cylinder
			gluCylinder(quadratic,1.0,1.0,3.0,32,32)		' A Cylinder With A Radius Of 0.5 And A Height Of 2
			Case 2
			gluDisk(quadratic,0.5,1.5,32,32)			' Draw A Disc (CD Shape) With An Inner Radius Of 0.5, And An Outer Radius Of 2.  Plus A Lot Of Segments ;)
			Case 3
			gluSphere(quadratic,1.3,32,32)				' Draw A Sphere With A Radius Of 1 And 16 Longitude And 16 Latitude Segments
			Case 4
			glTranslatef(0.0,0.0,-1.5)							' Center The Cone
			gluCylinder(quadratic,1.0,0.0,3.0,32,32)		' A Cone With A Bottom Radius Of .5 And A Height Of 2
			Case 5
			part1:+p1
			part2:+p2
			If(part1>359) Then								' 360 Degrees
				p1=0
				part1=0
				p2=1
				part2=0
			EndIf
			If(part2>359)	 Then								' 360 Degrees
				p1=1
				p2=0
			EndIf
			gluPartialDisk(quadratic,0.5,1.5,32,32,part1,part2-part1)		' A Disk Like The One Before
		End Select
	
		xrot:+xspeed
		yrot:+yspeed
		glDisable(GL_TEXTURE_2D)	
		glDisable(GL_DEPTH_TEST)	
		glDisable(GL_LIGHT1)
		glDisable(GL_LIGHTING)
		glColor3f(1.0,1.0,1.0)
		'--------------------------------------------------------
		GLDrawText("NeHe & TipTup's Quadratics Tutorial (lesson 18)",10,24)
		
		GLDrawText("'T' Texture filter : " + TextureNotifi[Filter],10,56)
		GLDrawText("'L' Light          : " + LighNotifi[light],10,72)
		GLDrawText("'SPACE' Quadratic  : " + FormNotifi[Objet],10,88)
		
		glEnable(GL_LIGHTING)
		glEnable(GL_LIGHT1)
		glEnable(GL_DEPTH_TEST)
		glEnable(GL_TEXTURE_2D)
	End Method
	
	Method glDrawCube()
		glBegin(GL_QUADS)
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
			' Top Face
			glNormal3f( 0.0, 1.0, 0.0)
			glTexCoord2f(0.0, 1.0); glVertex3f(-1.0,  1.0, -1.0)
			glTexCoord2f(0.0, 0.0); glVertex3f(-1.0,  1.0,  1.0)
			glTexCoord2f(1.0, 0.0); glVertex3f( 1.0,  1.0,  1.0)
			glTexCoord2f(1.0, 1.0); glVertex3f( 1.0,  1.0, -1.0)
			' Bottom Face
			glNormal3f( 0.0,-1.0, 0.0);
			glTexCoord2f(1.0, 1.0); glVertex3f(-1.0, -1.0, -1.0)
			glTexCoord2f(0.0, 1.0); glVertex3f( 1.0, -1.0, -1.0)
			glTexCoord2f(0.0, 0.0); glVertex3f( 1.0, -1.0,  1.0)
			glTexCoord2f(1.0, 0.0); glVertex3f(-1.0, -1.0,  1.0)
			' Right Face
			glNormal3f( 1.0, 0.0, 0.0);
			glTexCoord2f(1.0, 0.0); glVertex3f( 1.0, -1.0, -1.0)
			glTexCoord2f(1.0, 1.0); glVertex3f( 1.0,  1.0, -1.0)
			glTexCoord2f(0.0, 1.0); glVertex3f( 1.0,  1.0,  1.0)
			glTexCoord2f(0.0, 0.0); glVertex3f( 1.0, -1.0,  1.0)
			' Left Face
			glNormal3f(-1.0, 0.0, 0.0);
			glTexCoord2f(0.0, 0.0); glVertex3f(-1.0, -1.0, -1.0)
			glTexCoord2f(1.0, 0.0); glVertex3f(-1.0, -1.0,  1.0)
			glTexCoord2f(1.0, 1.0); glVertex3f(-1.0,  1.0,  1.0)
			glTexCoord2f(0.0, 1.0); glVertex3f(-1.0,  1.0, -1.0)
		glEnd()
	End Method
End Type