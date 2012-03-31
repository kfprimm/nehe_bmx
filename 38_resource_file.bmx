Strict

Import "framework.bmx"

New TNeHe38.Run(38,"Resource File")


' ********************************************************************
' Use Incbin
' ********************************************************************
Incbin "data/Butterfly1.bmp"
Incbin "data/Butterfly2.bmp"
Incbin "data/Butterfly3.bmp"
'
' ********************************************************************
' STRUCTURE
' ********************************************************************
Type Objet													' Create A Structure Called Objet
	Field tex:Int												' Integer Used To Select Our Texture
	Field x:Float												' X Position
	Field y:Float												' Y Position
	Field z:Float												' Z Position
	Field yi:Float											' Y Increase Speed (Fall Speed)
	Field spinz:Float											' Z Axis Spin
	Field spinzi:Float										' Z Axis Spin Speed
	Field flap:Float											' Flapping Triangles :)
	Field fi:Float											' Flap Direction (Increase Value)
End Type

Type TNeHe38 Extends TNeHe
	Field texture:Int[3]											' Storage For 3 Textures
	Field obj:Objet[50]											' Create 50 Objects Using The Object Structure
	Field ShowMenu:Int
	
	Method Init()
		LoadGLTextures()											' Load The Textures From Our Resource File
		
		glClearColor(0.0, 0.0, 0.0, 0.5)							' Black Background
		glClearDepth(1.0)											' Depth Buffer Setup
		glDepthFunc(GL_LEQUAL)										' The Type Of Depth Testing (Less Or Equal)
		glDisable(GL_DEPTH_TEST)									' Disable Depth Testing
		glShadeModel(GL_SMOOTH)									' Select Smooth Shading
		glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST)			' Set Perspective Calculations To Most Accurate
		glEnable(GL_TEXTURE_2D)									' Enable Texture Mapping
		glBlendFunc(GL_ONE,GL_SRC_ALPHA)							' Set Blending Mode (Cheap / Quick)
		glEnable(GL_BLEND)										' Enable Blending
	
		For Local loop:Int=0 Until 50								' Loop To Initialize 50 Objects
			obj[loop]=New Objet
			SetObject(loop)										' Call SetObject To Assign New Random Values
		Next
	
		glViewport(0,0,ScreenWidth,ScreenHeight)							' Set viewport
		glMatrixMode(GL_PROJECTION)										' Select The Projection Matrix
		glLoadIdentity()													' Reset The Projection Matrix
		gluPerspective(45.0,Float(ScreenWidth)/Float(ScreenHeight),1.0,1000.0)	' Calculate The Aspect Ratio Of The Window
		glMatrixMode(GL_MODELVIEW)											' Select The Modelview Matrix
		glLoadIdentity()													' Reset The Modelview Matrix
	End Method
	
	Method Loop()
		If KeyHit(KEY_F1) Then ShowMenu=Not ShowMenu
		glClear (GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)					' Clear Screen And Depth Buffer
		For Local loop:Int=0 Until 50										' Loop Of 50 (Draw 50 Objects)
			glLoadIdentity()												' Reset The Modelview Matrix
			glBindTexture(GL_TEXTURE_2D, texture[obj[loop].tex])				' Bind Our Texture
			glTranslatef(obj[loop].x,obj[loop].y,obj[loop].z)				' Position The Object
			glRotatef(45.0,1.0,0.0,0.0)									' Rotate On The X-Axis
			glRotatef((obj[loop].spinz),0.0,0.0,1.0)						' Spin On The Z-Axis
	
			glBegin(GL_TRIANGLES)											' Begin Drawing Triangles
				' First Triangle			     								 _____
				glTexCoord2f(1.0,1.0) ; glVertex3f( 1.0, 1.0, 0.0)			' (2)     (1)
				glTexCoord2f(0.0,1.0) ; glVertex3f(-1.0, 1.0, obj[loop].flap)	'  |    /
				glTexCoord2f(0.0,0.0) ; glVertex3f(-1.0,-1.0, 0.0)			' (3)|/
	
				' Second Triangle
				glTexCoord2f(1.0,1.0) ; glVertex3f( 1.0, 1.0, 0.0)			'        /|(1)
				glTexCoord2f(0.0,0.0) ; glVertex3f(-1.0,-1.0, 0.0)			'      /  |
				glTexCoord2f(1.0,0.0) ; glVertex3f( 1.0,-1.0, obj[loop].flap)	' (2)/____|(3)
			glEnd()														' Done Drawing Triangles
	
			obj[loop].y:-obj[loop].yi										' Move Object Down The Screen
			obj[loop].spinz:+obj[loop].spinzi								' Increase Z Rotation By spinzi
			obj[loop].flap:+obj[loop].fi									' Increase flap Value By fi
			
			If obj[loop].y<-18.0 Then										' Is Object Off The Screen?
				SetObject(loop)											' If So, Reassign New Values
			EndIf
			If (obj[loop].flap>1.0) Or (obj[loop].flap<-1.0) Then				' Time To Change Flap Direction?
				obj[loop].fi=-obj[loop].fi									' Change Direction By Making fi = -fi
			EndIf
		Next
		DrawMenu()
	End Method
	
	' Sets The Initial Value Of Each Object (Random)
	Method SetObject(loop:Int)
		obj[loop].tex=Rand(0,2)									' Texture Can Be One Of 3 Textures
		obj[loop].x=Rand(0,34)-17									' Random x Value From -17.0 To 17.0
		obj[loop].y=18.0											' Set y Position To 18 (Off Top Of Screen)
		obj[loop].z=-Rand(10,40)									' z Is A Random Value From -10.0 To -40.0
		obj[loop].spinzi=RndFloat()+Float(Rand(0,1)-1)				' spinzi Is A Random Value From -1.0 To 1.0
		obj[loop].flap=0.0										' flap Starts Off At 0.0
		obj[loop].fi=0.05+(Float(Rand(0,100))/1000.0)				' fi Is A Random Value From 0.05f To 0.15f
		obj[loop].yi=0.001+(Float(Rand(0,10000))/100000.0)			' yi Is A Random Value From 0.001f To 0.101f
	End Method
	
	' Creates Textures From Bitmaps In The Resource File
	Method LoadGLTextures()
		Local hBMP:TPixmap										' Handle Of The Bitmap
	
		glGenTextures(3, Varptr texture[0])							' Generate 3 Textures
		glPixelStorei(GL_UNPACK_ALIGNMENT,4)						' Pixel Storage Mode (Word Alignment / 4 Bytes)
		
		hBMP=LoadPixmap("incbin::data/Butterfly1.bmp")
		hBMP=YFlipPixmap(hBMP)										' Swap image verticaly (font image)
		glBindTexture(GL_TEXTURE_2D, texture[0])					' Bind Our Texture
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR)					' Linear Filtering
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR_MIPMAP_LINEAR)	' Mipmap Linear Filtering
		' Generate Mipmapped Texture (3 Bytes, Width, Height And Data From The BMP)
		gluBuild2DMipmaps(GL_TEXTURE_2D, 3, hBMP.width, hBMP.height, GL_BGR_EXT, GL_UNSIGNED_BYTE, hBMP.pixels)
	
		hBMP=LoadPixmap("incbin::data/Butterfly2.bmp")
		hBMP=YFlipPixmap(hBMP)										' Swap image verticaly (font image)
		glBindTexture(GL_TEXTURE_2D, texture[1])					' Bind Our Texture
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR)					' Linear Filtering
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR_MIPMAP_LINEAR)	' Mipmap Linear Filtering
		' Generate Mipmapped Texture (3 Bytes, Width, Height And Data From The BMP)
		gluBuild2DMipmaps(GL_TEXTURE_2D, 3, hBMP.width, hBMP.height, GL_BGR_EXT, GL_UNSIGNED_BYTE, hBMP.pixels)
	
		hBMP=LoadPixmap("incbin::data/Butterfly3.bmp")
		hBMP=YFlipPixmap(hBMP)										' Swap image verticaly (font image)
		glBindTexture(GL_TEXTURE_2D, texture[2])					' Bind Our Texture
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR)					' Linear Filtering
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR_MIPMAP_LINEAR)	' Mipmap Linear Filtering
		' Generate Mipmapped Texture (3 Bytes, Width, Height And Data From The BMP)
		gluBuild2DMipmaps(GL_TEXTURE_2D, 3, hBMP.width, hBMP.height, GL_BGR_EXT, GL_UNSIGNED_BYTE, hBMP.pixels)
	End Method
	
	Method DrawMenu()
		glDisable(GL_TEXTURE_2D)	
		glColor3f(1.0,1.0,1.0)
		GLDrawText("F1 : Hide/Show menu",10,ScreenHeight-16-8)
		If ShowMenu Then
			GLDrawText("NeHe's Resource File Tutorial (lesson 38)",10,0)
		EndIf
		glEnable(GL_TEXTURE_2D)
	End Method

End Type
