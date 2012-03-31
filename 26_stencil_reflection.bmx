Strict

Import "framework.bmx"

New TNeHe26.Run(26,"Stencil and Reflection",GRAPHICS_BACKBUFFER|GRAPHICS_DEPTHBUFFER | GL_STENCIL_BUFFER)
	
Type TNeHe26 Extends TNehe
	
	' Light Parameters
	Field LightAmb:Float[]=[0.7, 0.7, 0.7, 1.0]		' Ambient Light
	Field LightDif:Float[]=[1.0, 1.0, 1.0, 1.0]		' Diffuse Light
	Field LightPos:Float[]=[4.0, 4.0, 6.0, 1.0]		' Light Position
	
	Field q:Int Ptr								'  Quadratic For Drawing A Sphere
	
	Field xrot:Float=0.0							' X Rotation
	Field yrot:Float=0.0							' Y Rotation
	Field xrotspeed:Float=0.0						' X Rotation Speed
	Field yrotspeed:Float=0.0						' Y Rotation Speed
	Field zoom:Float=-7.0							' Depth Into The Screen
	Field height:Float=2.0						' Height Of Ball From Floor
	
	Field texture:Int[3]							' Storage For 3 Textures
	Field showMenu:Int
	
	'field LighNotifi:String[]=["OFF","ON"]
	'field TextureNotifi:String[]=["NEAREST","LINEAR","MIPMAP"]
	'field FormNotifi:String[]=["Cube","Cylinder","Sphere","Cone"]
	
	' When you create a context, don't forget to activate the stencil buffer.
	' This tutorial use it. 
	
	Method Init()
		LoadGlTextures()
		glShadeModel(GL_SMOOTH)											' Enable Smooth Shading
		glClearColor(0.2, 0.5, 1.0, 1.0)									' Background
		glClearDepth(1.0)													' Depth Buffer Setup
		glClearStencil(0)													' Clear The Stencil Buffer To 0
		glEnable(GL_DEPTH_TEST)											' Enables Depth Testing
		glDepthFunc(GL_LEQUAL)												' The Type Of Depth Testing To Do
		glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST)					' Really Nice Perspective Calculations
		glEnable(GL_TEXTURE_2D)											' Enable 2D Texture Mapping
	
		glLightfv(GL_LIGHT0, GL_AMBIENT, LightAmb)							' Set The Ambient Lighting For Light0
		glLightfv(GL_LIGHT0, GL_DIFFUSE, LightDif)							' Set The Diffuse Lighting For Light0
		glLightfv(GL_LIGHT0, GL_POSITION, LightPos)							' Set The Position For Light0
		glEnable(GL_LIGHT0)												' Enable Light 0
		glEnable(GL_LIGHTING)												' Enable Lighting
	
		q=Int Ptr gluNewQuadric()											' Create A New Quadratic
		gluQuadricNormals(q, GL_SMOOTH)										' Generate Smooth Normals For The Quad
		gluQuadricTexture(q, GL_TRUE)										' Enable Texture Coords For The Quad
		glTexGeni(GL_S, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP)					' Set Up Sphere Mapping
		glTexGeni(GL_T, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP)					' Set Up Sphere Mapping
		
		glViewport(0,0,ScreenWidth,ScreenHeight)							' Set viewport
		glMatrixMode(GL_PROJECTION)										' Select The Projection Matrix
		glLoadIdentity()													' Reset The Projection Matrix
		gluPerspective(45.0,Float(ScreenWidth)/Float(ScreenHeight),0.1,100.0)	' Calculate The Aspect Ratio Of The Window
		glMatrixMode(GL_MODELVIEW)											' Select The Modelview Matrix
		glLoadIdentity()													' Reset The Modelview Matrix
	End Method
	
	Method LoadGlTextures()
		Local TextureImage:TPixmap[3]
		TextureImage:TPixmap[0]=LoadPixmap("Data/EnvWall.bmp")
		TextureImage:TPixmap[1]=LoadPixmap("Data/Ball.bmp")
		TextureImage:TPixmap[2]=LoadPixmap("Data/EnvRoll.bmp")
		
		glGenTextures(3, Varptr texture[0])									' Create Three Textures
		For Local loop=0 Until 3
			glBindTexture(GL_TEXTURE_2D, texture[loop])
			glTexImage2D(GL_TEXTURE_2D, 0, 3, TextureImage[loop].width, TextureImage[loop].height, 0, GL_RGB, GL_UNSIGNED_BYTE, TextureImage[loop].pixels)
			' Create Linear Filtered Texture
			glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR)
			glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR)
		Next
	End Method
	
	Method Loop()
		' Clip Plane Equations
		Local eqr:Double[]=[0.0!,-1.0!, 0.0!, 0.0!]							' Plane Equation To Use For The Reflected Objects
	
		If KeyHit(KEY_F1) Then ShowMenu=Not ShowMenu
		ProcessKeyboard()
	
		' Clear Screen, Depth Buffer & Stencil Buffer
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT)
		glLoadIdentity()													' Reset The Modelview Matrix
		glTranslatef(0.0, -1.6, zoom)										' Zoom And Raise Camera Above The Floor (Up 0.6 Units)
		glColorMask(0,0,0,0)												' Set Color Mask
		glEnable(GL_STENCIL_TEST)											' Enable Stencil Buffer For "marking" The Floor
		glStencilFunc(GL_ALWAYS, 1, 1)										' Always Passes, 1 Bit Plane, 1 As Mask
		glStencilOp(GL_KEEP, GL_KEEP, GL_REPLACE)
		
		' We Set The Stencil Buffer To 1 Where We Draw Any Polygon Keep If Test Fails, Keep If Test Passes But Buffer Test Fails
		' Replace If Test Passes
		glDisable(GL_DEPTH_TEST)											' Disable Depth Testing
		DrawFloor()														' Draw The Floor (Draws To The Stencil Buffer)
																		' We Only Want To Mark It In The Stencil Buffer
		glEnable(GL_DEPTH_TEST)											' Enable Depth Testing
		glColorMask(1,1,1,1)												' Set Color Mask To True, True, True, True
		glStencilFunc(GL_EQUAL, 1, 1)										' We Draw Only Where The Stencil Is 1
																		' (I.E. Where The Floor Was Drawn)
		glStencilOp(GL_KEEP, GL_KEEP, GL_KEEP)								' Don't Change The Stencil Buffer
		glEnable(GL_CLIP_PLANE0)											' Enable Clip Plane For Removing Artifacts
																		' (When The Object Crosses The Floor)
		glClipPlane(GL_CLIP_PLANE0, eqr)									' Equation For Reflected Objects
		
		glPushMatrix()													' Push The Matrix Onto The Stack
			glScalef(1.0, -1.0, 1.0)										' Mirror Y Axis
			glLightfv(GL_LIGHT0, GL_POSITION, LightPos)						' Set Up Light0
			glTranslatef(0.0, height, 0.0)									' Position The Object
			glRotatef(xrot, 1.0, 0.0, 0.0)									' Rotate Local Coordinate System On X Axis
			glRotatef(yrot, 0.0, 1.0, 0.0)									' Rotate Local Coordinate System On Y Axis
			DrawObject()													' Draw The Sphere (Reflection)
		glPopMatrix()														' Pop The Matrix Off The Stack
		glDisable(GL_CLIP_PLANE0)											' Disable Clip Plane For Drawing The Floor
		glDisable(GL_STENCIL_TEST)											' We Don't Need The Stencil Buffer Any More (Disable)
		glLightfv(GL_LIGHT0, GL_POSITION, LightPos)							' Set Up Light0 Position
		glEnable(GL_BLEND)												' Enable Blending (Otherwise The Reflected Object Wont Show)
		glDisable(GL_LIGHTING)												' Since We Use Blending, We Disable Lighting
		glColor4f(1.0, 1.0, 1.0, 0.8)										' Set Color To White With 80% Alpha
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)					' Blending Based On Source Alpha And 1 Minus Dest Alpha
		DrawFloor()														' Draw The Floor To The Screen
		glEnable(GL_LIGHTING)												' Enable Lighting
		glDisable(GL_BLEND)												' Disable Blending
		glTranslatef(0.0, height, 0.0)										' Position The Ball At Proper Height
		glRotatef(xrot, 1.0, 0.0, 0.0)										' Rotate On The X Axis
		glRotatef(yrot, 0.0, 1.0, 0.0)										' Rotate On The Y Axis
		DrawObject()														' Draw The Ball
		xrot:+xrotspeed													' Update X Rotation Angle By xrotspeed
		yrot:+yrotspeed													' Update Y Rotation Angle By yrotspeed
		DrawMenu()
	End Method
	
	Method DrawObject()													' Draw Our Ball
		glColor3f(1.0, 1.0, 1.0)											' Set Color To White
		glBindTexture(GL_TEXTURE_2D, texture[1])							' Select Texture 2 (1)
		gluSphere(q, 0.35, 32, 16)											' Draw First Sphere
	
		glBindTexture(GL_TEXTURE_2D, texture[2])							' Select Texture 3 (2)
		glColor4f(1.0, 1.0, 1.0, 0.4)										' Set Color To White With 40% Alpha
		glEnable(GL_BLEND)												' Enable Blending
		glBlendFunc(GL_SRC_ALPHA, GL_ONE)									' Set Blending Mode To Mix Based On SRC Alpha
		glEnable(GL_TEXTURE_GEN_S)											' Enable Sphere Mapping
		glEnable(GL_TEXTURE_GEN_T)											' Enable Sphere Mapping
	
		gluSphere(q, 0.35, 32, 16)											' Draw Another Sphere Using New Texture
		' Textures Will Mix Creating A MultiTexture Effect (Reflection)
		glDisable(GL_TEXTURE_GEN_S)										' Disable Sphere Mapping
		glDisable(GL_TEXTURE_GEN_T)										' Disable Sphere Mapping
		glDisable(GL_BLEND)												' Disable Blending
	End Method
	
	Method DrawFloor()													' Draws The Floor
		glBindTexture(GL_TEXTURE_2D, texture[0])							' Select Texture 1 (0)
		glBegin(GL_QUADS)													' Begin Drawing A Quad
			glNormal3f(0.0, 1.0, 0.0)										' Normal Pointing Up
			glTexCoord2f(0.0, 1.0)											' Bottom Left Of Texture
			glVertex3f(-2.0, 0.0, 2.0)										' Bottom Left Corner Of Floor
			glTexCoord2f(0.0, 0.0)											' Top Left Of Texture
			glVertex3f(-2.0, 0.0,-2.0)										' Top Left Corner Of Floor
			glTexCoord2f(1.0, 0.0)											' Top Right Of Texture
			glVertex3f( 2.0, 0.0,-2.0)										' Top Right Corner Of Floor
			glTexCoord2f(1.0, 1.0)											' Bottom Right Of Texture
			glVertex3f( 2.0, 0.0, 2.0)										' Bottom Right Corner Of Floor
		glEnd()															' Done Drawing The Quad
	End Method
	
	Method ProcessKeyboard()												' Process Keyboard Results
		If KeyDown(KEY_RIGHT) Then yrotspeed:+0.08							' Right Arrow Pressed (Increase yrotspeed)
		If KeyDown(KEY_LEFT) Then yrotspeed:- 0.08							' Left Arrow Pressed (Decrease yrotspeed)
		If KeyDown(KEY_DOWN) Then xrotspeed:+0.08							' Down Arrow Pressed (Increase xrotspeed)
		If KeyDown(KEY_UP) Then xrotspeed:-0.08								' Up Arrow Pressed (Decrease xrotspeed)
	
		If KeyDown(KEY_A) Then zoom:+0.05									' 'A' Key Pressed ... Zoom In
		If KeyDown(KEY_Z) Then zoom:-0.05									' 'Z' Key Pressed ... Zoom Out
	
		If KeyDown(KEY_PAGEUP) Then height:+0.03							' Page Up Key Pressed Move Ball Up
		If KeyDown(KEY_PAGEDOWN) Then height:-0.03							' Page Down Key Pressed Move Ball Down
	End Method
	
	Method DrawMenu()
		glDisable(GL_TEXTURE_2D)	
		glDisable(GL_DEPTH_TEST)	
		glDisable(GL_LIGHT1)
		glDisable(GL_LIGHTING)
		glColor3f(1.0,1.0,1.0)
		GLDrawText("F1 : Hide/Show menu",10,ScreenHeight-16-8)
		If ShowMenu Then
			GLDrawText("Banu Octavian & NeHe's Stencil & Reflection Tutorial (lesson 26)",10,24)
			GLDrawText("'PAGEUP'   Ball up",10,56)
			GLDrawText("'PAGEDOWN' Ball down",10,72)
			GLDrawText("'UP'       Decrease X speed",10,88)
			GLDrawText("'DOWN'     Increase X speed",10,104)	
			GLDrawText("'RIGHT'    Increase Y speed",10,120)
			GLDrawText("'LEFT'     Decrease Y speed",10,136)	
			GLDrawText("'A'        Zoom in",10,152)
			GLDrawText("'Z'        Zoom out",10,168)		
		EndIf
		glEnable(GL_LIGHTING)
		glEnable(GL_LIGHT1)
		glEnable(GL_DEPTH_TEST)
		glEnable(GL_TEXTURE_2D)
	End Method
End Type