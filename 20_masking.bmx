Strict

Import "framework.bmx"

New TNehe20.Run(20,"Masking")

Type TNehe20 Extends TNehe
	Field masking:Byte=True				' Masking On/Off
	Field scene:Byte						' Which Scene To Draw
	Field loops:Int						' Generic Loop Variable
	Field roll:Float						' Rolling Texture
	Field Texture:Int[5]					' Storage For Our Five Textures
	
	Field MaskingMode:String[]=["OFF","ON"]
	Field SceneNotifi:String[]=["Scene 1","Scene 2"]
	
	Method Init()
		LoadGlTextures()
		glEnable(GL_TEXTURE_2D)												' Enable Texture Mapping
		glShadeModel(GL_SMOOTH)												' Enable Smooth Shading
		glClearColor(0.0, 0.0, 0.0, 0.0)										' Black Background
		glClearDepth(1.0)														' Depth Buffer Setup
		glDisable(GL_DEPTH_TEST)												' Disable Depth Testing
	
		glViewport(0,0,ScreenWidth,ScreenHeight)								' Set viewport
		glMatrixMode(GL_PROJECTION)											' Select The Projection Matrix
		glLoadIdentity()														' Reset The Projection Matrix
		gluPerspective(45.0,Float(ScreenWidth)/Float(ScreenHeight),0.1,100.0)		' Calculate The Aspect Ratio Of The Window
		glMatrixMode(GL_MODELVIEW)												' Select The Modelview Matrix
		glLoadIdentity()
	End Method

	Method LoadGlTextures()
		Local TextureImage:TPixmap[5]
		TextureImage:TPixmap[0]=LoadPixmap("data\logo.bmp")
		TextureImage:TPixmap[0]=YFlipPixmap(TextureImage[0])						' Swap image verticaly (logo image)
		TextureImage:TPixmap[1]=LoadPixmap("data\mask1.bmp")
		TextureImage:TPixmap[2]=LoadPixmap("data\image1.bmp")
		TextureImage:TPixmap[3]=LoadPixmap("data\mask2.bmp")	
		TextureImage:TPixmap[4]=LoadPixmap("data\image2.bmp")
		
		glGenTextures(5, Varptr texture[0])										' Create Five Textures
		For loops=0 To 4
			glBindTexture(GL_TEXTURE_2D, texture[loops]);
			glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
			glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
			glTexImage2D(GL_TEXTURE_2D, 0, 3, TextureImage[loops].width, TextureImage[loops].height, 0, GL_RGB, GL_UNSIGNED_BYTE, TextureImage[loops].pixels)
		Next
	End Method
	
	Method loop()
		If KeyHit(KEY_SPACE) Then												' Is Space Being Pressed?
			scene=Not scene													' Toggle From One Scene To The Other
		EndIf
		If KeyHit(KEY_M) Then													' Is M Being Pressed?
			masking=Not masking												' Toggle Masking Mode OFF/ON
		EndIf
		
		glClear GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT						' Clear The Screen And The Depth Buffer
		glLoadIdentity()														' Reset The Current Modelview Matrix
		glTranslatef(0.0,0.0,-2.0)												' Move Into The Screen 2 Units
	
		glBindTexture(GL_TEXTURE_2D, texture[0])								' Select Our Logo Texture
		glBegin(GL_QUADS)														' Start Drawing A Textured Quad
			glTexCoord2f(0.0, -roll+0.0); glVertex3f(-1.1, -1.1,  0.0)			' Bottom Left
			glTexCoord2f(3.0, -roll+0.0); glVertex3f( 1.1, -1.1,  0.0)			' Bottom Right
			glTexCoord2f(3.0, -roll+3.0); glVertex3f( 1.1,  1.1,  0.0)			' Top Right
			glTexCoord2f(0.0, -roll+3.0); glVertex3f(-1.1,  1.1,  0.0)			' Top Left
		glEnd()																' Done Drawing The Quad
	
		glEnable(GL_BLEND)													' Enable Blending
		glDisable(GL_DEPTH_TEST)												' Disable Depth Testing
	
		If masking Then														' Is Masking Enabled?
			glBlendFunc(GL_DST_COLOR,GL_ZERO)									' Blend Screen Color With Zero (Black)
		EndIf
		If scene Then															' Are We Drawing The Second Scene?
			glTranslatef(0.0,0.0,-1.0)											' Translate Into The Screen One Unit
			glRotatef(roll*360,0.0,0.0,1.0)										' Rotate On The Z Axis 360 Degrees.
			If masking Then													' Is Masking On?
				glBindTexture(GL_TEXTURE_2D, texture[3])						' Select The Second Mask Texture
				glBegin(GL_QUADS)												' Start Drawing A Textured Quad
					glTexCoord2f(0.0, 0.0); glVertex3f(-1.1, -1.1,  0.0)			' Bottom Left
					glTexCoord2f(1.0, 0.0); glVertex3f( 1.1, -1.1,  0.0)			' Bottom Right
					glTexCoord2f(1.0, 1.0); glVertex3f( 1.1,  1.1,  0.0)			' Top Right
					glTexCoord2f(0.0, 1.0); glVertex3f(-1.1,  1.1,  0.0)			' Top Left
				glEnd()														' Done Drawing The Quad
			EndIf
			glBlendFunc(GL_ONE, GL_ONE)										' Copy Image 2 Color To The Screen
			glBindTexture(GL_TEXTURE_2D, texture[4])							' Select The Second Image Texture
			glBegin(GL_QUADS)													' Start Drawing A Textured Quad
				glTexCoord2f(0.0, 0.0); glVertex3f(-1.1, -1.1,  0.0)				' Bottom Left
				glTexCoord2f(1.0, 0.0); glVertex3f( 1.1, -1.1,  0.0)				' Bottom Right
				glTexCoord2f(1.0, 1.0); glVertex3f( 1.1,  1.1,  0.0)				' Top Right
				glTexCoord2f(0.0, 1.0); glVertex3f(-1.1,  1.1,  0.0)				' Top Left
			glEnd()															' Done Drawing The Quad
		Else																	' Otherwise
			If masking Then													' Is Masking On?
				glBindTexture(GL_TEXTURE_2D, texture[1])						' Select The First Mask Texture
				glBegin(GL_QUADS)												' Start Drawing A Textured Quad
					glTexCoord2f(roll+0.0, 0.0); glVertex3f(-1.1, -1.1,  0.0)		' Bottom Left
					glTexCoord2f(roll+4.0, 0.0); glVertex3f( 1.1, -1.1,  0.0)		' Bottom Right
					glTexCoord2f(roll+4.0, 4.0); glVertex3f( 1.1,  1.1,  0.0)		' Top Right
					glTexCoord2f(roll+0.0, 4.0); glVertex3f(-1.1,  1.1,  0.0)		' Top Left
				glEnd()														' Done Drawing The Quad
			EndIf
			glBlendFunc(GL_ONE, GL_ONE)										' Copy Image 1 Color To The Screen
			glBindTexture(GL_TEXTURE_2D, texture[2])							' Select The First Image Texture
			glBegin(GL_QUADS)													' Start Drawing A Textured Quad
				glTexCoord2f(roll+0.0, 0.0); glVertex3f(-1.1, -1.1,  0.0)			' Bottom Left
				glTexCoord2f(roll+4.0, 0.0); glVertex3f( 1.1, -1.1,  0.0)			' Bottom Right
				glTexCoord2f(roll+4.0, 4.0); glVertex3f( 1.1,  1.1,  0.0)			' Top Right
				glTexCoord2f(roll+0.0, 4.0); glVertex3f(-1.1,  1.1,  0.0)			' Top Left
			glEnd()															' Done Drawing The Quad
		EndIf
	
		glEnable(GL_DEPTH_TEST)												' Enable Depth Testing
		glDisable(GL_BLEND)													' Disable Blending
	
		roll:+0.002															' Increase Our Texture Roll Variable
		If roll>1.0 Then roll:-1.0												' Is Roll Greater Than One Subtract 1 From Roll
		glDisable(GL_TEXTURE_2D)	
		glColor3f(1.0,1.0,1.0)
		'--------------------------------------------------------
		GLDrawText("NeHe's Masking Tutorial (lesson 20)",10,24)
		
		GLDrawText("'M'     Masking mode : " + MaskingMode[masking],10,56)
		GLDrawText("'SPACE' Scene        : " + SceneNotifi[scene],10,72)
	
		glEnable(GL_TEXTURE_2D)
	End Method
 End Type