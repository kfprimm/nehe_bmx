Strict

Import "framework.bmx"

New TNeHe41.Run(41,"Volumetric Fog")	

Type TNeHe41 Extends TNeHe	 
	Field fogColor:Float[]=[0.6, 0.3, 0.0, 1.0]					' Fog Colour 
	Field camz:Float											' Camera Z Depth
	Field texture:Int										' One Texture (For The Walls)
	Field ShowMenu:Int
	Field TickCount:Int
	
	Method Init()
		glewInit()
		If Not Extension_Init() Then											' Check And Enable Fog Extension If Available
			End														' Return False If Extension Not Supported
		EndIf
		If Not BuildTexture("data/wall1.bmp", Varptr texture) Then				' Load The Wall Texture
			End														' Return False If Loading Failed
		EndIf
	
		glEnable(GL_TEXTURE_2D)												' Enable Texture Mapping
		glClearColor(0.0, 0.0, 0.0, 0.5)										' Black Background
		glClearDepth(1.0)														' Depth Buffer Setup
		glDepthFunc(GL_LEQUAL)													' The Type Of Depth Testing
		glEnable(GL_DEPTH_TEST)												' Enable Depth Testing
		glShadeModel(GL_SMOOTH)												' Select Smooth Shading
		glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST)						' Set Perspective Calculations To Most Accurate
	
		' Set Up Fog 
		glEnable(GL_FOG)														' Enable Fog
		glFogi(GL_FOG_MODE, GL_LINEAR)											' Fog Fade Is Linear
		glFogfv(GL_FOG_COLOR, fogColor)											' Set The Fog Color
		glFogf(GL_FOG_START,  0.0)												' Set The Fog Start
		glFogf(GL_FOG_END,    1.0)												' Set The Fog End
		glHint(GL_FOG_HINT, GL_NICEST)											' Per-Pixel Fog Calculation
		glFogi(GL_FOG_COORDINATE_SOURCE_EXT, GL_FOG_COORDINATE_EXT)				' Set Fog Based On Vertice Coordinates
		camz=-19.0															' Set Camera Z Position To -19.0
	
		glViewport(0,0,ScreenWidth,ScreenHeight)								' Set viewport
		glMatrixMode(GL_PROJECTION)											' Select The Projection Matrix
		glLoadIdentity()														' Reset The Projection Matrix
		gluPerspective(45.0,Float(ScreenWidth)/Float(ScreenHeight),1.0,100.0)		' Calculate The Aspect Ratio Of The Window
		glMatrixMode(GL_MODELVIEW)												' Select The Modelview Matrix
		glLoadIdentity()														' Reset The Current Modelview Matrix
		HideMouse
		TickCount=MilliSecs()
	End Method
	
	Method Loop()
		If KeyHit(KEY_F1) Then ShowMenu=Not ShowMenu
	
		glClear (GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)						' Clear Screen And Depth Buffer
		glLoadIdentity()														' Reset The Modelview Matrix
		glTranslatef(0.0, 0.0, camz)											' Move To Our Camera Z Position
		' Back Wall
		glBegin(GL_QUADS)
		 	glFogCoordfEXT(1.0) ; glTexCoord2f(0.0, 0.0) ; glVertex3f(-2.5,-2.5,-15.0)
			glFogCoordfEXT(1.0) ; glTexCoord2f(1.0, 0.0) ; glVertex3f( 2.5,-2.5,-15.0)
			glFogCoordfEXT(1.0) ; glTexCoord2f(1.0, 1.0) ; glVertex3f( 2.5, 2.5,-15.0)
			glFogCoordfEXT(1.0) ; glTexCoord2f(0.0, 1.0) ; glVertex3f(-2.5, 2.5,-15.0)
		glEnd()
		' Floor
		glBegin(GL_QUADS)
		 	glFogCoordfEXT(1.0) ; glTexCoord2f(0.0, 0.0) ; glVertex3f(-2.5,-2.5,-15.0)
			glFogCoordfEXT(1.0) ; glTexCoord2f(1.0, 0.0) ; glVertex3f( 2.5,-2.5,-15.0)
			glFogCoordfEXT(0.0) ; glTexCoord2f(1.0, 1.0) ; glVertex3f( 2.5,-2.5, 15.0)
			glFogCoordfEXT(0.0) ; glTexCoord2f(0.0, 1.0) ; glVertex3f(-2.5,-2.5, 15.0)
		glEnd()
		' Roof
		glBegin(GL_QUADS)
			glFogCoordfEXT(1.0) ; glTexCoord2f(0.0, 0.0) ; glVertex3f(-2.5, 2.5,-15.0)
			glFogCoordfEXT(1.0) ; glTexCoord2f(1.0, 0.0) ; glVertex3f( 2.5, 2.5,-15.0)
			glFogCoordfEXT(0.0) ; glTexCoord2f(1.0, 1.0) ; glVertex3f( 2.5, 2.5, 15.0)
			glFogCoordfEXT(0.0) ; glTexCoord2f(0.0, 1.0) ; glVertex3f(-2.5, 2.5, 15.0)
		glEnd()
		' Right Wall
		glBegin(GL_QUADS)
			glFogCoordfEXT(0.0) ; glTexCoord2f(0.0, 0.0) ; glVertex3f( 2.5,-2.5, 15.0)
			glFogCoordfEXT(0.0) ; glTexCoord2f(0.0, 1.0) ; glVertex3f( 2.5, 2.5, 15.0)
			glFogCoordfEXT(1.0) ; glTexCoord2f(1.0, 1.0) ; glVertex3f( 2.5, 2.5,-15.0)
			glFogCoordfEXT(1.0) ; glTexCoord2f(1.0, 0.0) ; glVertex3f( 2.5,-2.5,-15.0)
		glEnd()
		' Left Wall
		glBegin(GL_QUADS)
		 	glFogCoordfEXT(0.0) ; glTexCoord2f(0.0, 0.0) ; glVertex3f(-2.5,-2.5, 15.0)
			glFogCoordfEXT(0.0) ; glTexCoord2f(0.0, 1.0) ; glVertex3f(-2.5, 2.5, 15.0)
			glFogCoordfEXT(1.0) ; glTexCoord2f(1.0, 1.0) ; glVertex3f(-2.5, 2.5,-15.0)
			glFogCoordfEXT(1.0) ; glTexCoord2f(1.0, 0.0) ; glVertex3f(-2.5,-2.5,-15.0)
		glEnd()
		Update(MilliSecs()-TickCount)
		TickCount=MilliSecs()
		DrawMenu()
	End Method
	
	' Load Image And Convert To A Texture
	Method BuildTexture(file:String, texid:Int Ptr)
		Local glMaxTexDim:Int													' Holds Maximum Texture Size
		Local TextureImage:TPixmap
		Local WidthPixels:Int													' Width In Pixels
		Local HeightPixels:Int													' Height In Pixels
		Local FormatPixels:Int													' Pixel format
		
		Local In:TStream=ReadFile(file)														' File exist?
		If Not In Then
			Return False
		Else
			CloseStream(In)
		EndIf
	
		glGetIntegerv(GL_MAX_TEXTURE_SIZE, Varptr glMaxTexDim)					' Get Maximum Texture Size Supported
		
		TextureImage:TPixmap=LoadPixmap(file)									' Load Pixmap
		WidthPixels=PixmapWidth(TextureImage)									' Find Pixmap width
		HeightPixels=PixmapHeight(TextureImage)									' Find Pixmap height
		FormatPixels=PixmapFormat(TextureImage)									' Find Pixmap format
	
		' Resize Image To Closest Power Of Two
		If WidthPixels<=glMaxTexDim Then										' Is Image Width Less Than Or Equal To Cards Limit
			WidthPixels = 1 Shl Int( Floor((Log(Double(WidthPixels))/Log(2.0)) + 0.5) ) 
		Else																	' Otherwise  Set Width To "Max Power Of Two" That The Card Can Handle
			WidthPixels = glMaxTexDim
	 	EndIf
		If HeightPixels <= glMaxTexDim Then										' Is Image Height Greater Than Cards Limit
			HeightPixels = 1 Shl Int( Floor((Log(Double(HeightPixels))/Log(2.0)) + 0.5) )
		Else																	' Otherwise  Set Height To "Max Power Of Two" That The Card Can Handle
			HeightPixels = glMaxTexDim
		EndIf
	
		' If the Pixmap format = RGB convert to RGBA
		If FormatPixels = PF_RGB888 Then
			TextureImage=ConvertPixmap(TextureImage,PF_RGBA8888)
		EndIf
		TextureImage=ResizePixmap(TextureImage, WidthPixels, HeightPixels)
	
		glGenTextures(1, texid)												' Create The Texture
		' Typical Texture Generation Using Data From The Bitmap
		glBindTexture(GL_TEXTURE_2D, texid[0])									' Bind To The Texture ID
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR)				' (Modify This For The Type Of Filtering You Want)
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR)				' (Modify This For The Type Of Filtering You Want)
		' (Modify This If You Want Mipmaps)
		glTexImage2D(GL_TEXTURE_2D, 0, 3, TextureImage.width, TextureImage.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, TextureImage.pixels)
		Return True
	End Method
	
	
	' ************************************** need to fix this *******************
	Method Extension_Init()
	'	Local extensions:String=glGetString(GL_EXTENSIONS)					' Fetch Extension String
	'	If Not extensions.Find("EXT_fog_coord") Then								' Check To See If The Extension Is Supported
	'		Return False														' If not, return False
	'	EndIf
		Return True
	End Method
	'******************************************
	
	' Perform Motion Updates Here
	Method Update(milliseconds:Int)
		If KeyDown(KEY_UP) And camz<13.0 Then									' Is UP Arrow Being Pressed?
			camz:+(Float(milliseconds)/100.0)									' Move Object Closer (Move Forwards Through Hallway)
		EndIf
		If KeyDown(KEY_DOWN) And camz>-19.0 Then								' Is DOWN Arrow Being Pressed?
			camz:-(Float(milliseconds)/100.0)									' Move Object Further (Move Backwards Through Hallway)
		EndIf
	End Method
	
	Method DrawMenu()
		glDisable(GL_TEXTURE_2D)
		glDisable(GL_FOG)	
		glColor3f(1.0,1.0,1.0)
		GLDrawText("F1 : Hide/Show menu",10,ScreenHeight-16-8)
		If ShowMenu Then
			GLDrawText("NeHe's Volumetric Fog Tutorial (lesson 41)",10,0)
			GLDrawText("'UP'    Move Forwards",10,32)
			GLDrawText("'DOWN'  Move Backwards",10,48)
		EndIf
		glEnable(GL_FOG)
		glEnable(GL_TEXTURE_2D)
	End Method
End Type