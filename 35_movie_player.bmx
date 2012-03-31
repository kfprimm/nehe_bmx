Strict
Import "framework.bmx"

New TNeHe35.Run(35,"Movie Player")
' Some explanation :
' We can't actually play an AVI file.
' BMF file means for "Blitmax Movie File", basically it's just a collection of a jpeg file
' encapsuled in a single file.
' Formatting :
' 0000-0003	Total number of frame (Int)
' Frame 0 :
' 0000-0003	Length of the frame (lenght of the jpeg file)
' 0004-XXXX	Frame (jpeg file)
' Frame 1 :
' 0000-0003	Length of the frame (lenght of the jpeg file)
' 0004-XXXX	Frame (jpeg file)
' Etc...
'
' ************************************************************************
' CLASS
' ************************************************************************
' MOVIE
' ************************************************************************
Type MOVIE
	Field Handle:TStream					' Stream handle
	Field MovieName:String					' Name of this movie
	Field TotalFrame:Int					' Total frame in this movie
	Field ActualFrame:Int					' Frame playing
	Field FrameSize:Int					' Frame playing size 
	Field FramePos:Int					' Frame pointer in the stream
	Field FrameRate:Int					' Playing framerate for this movie
	Field Time:Int						' Time passed
	Field TextureName:Int					' Save texture name attached to this movie
	
	' Initialize movie stream
	Method OpenMovie(file:String)
		Handle=OpenStream(file)
		MovieName=file
		TotalFrame=ReadInt(Handle)
		ActualFrame=0
		FrameSize=ReadInt(Handle)
		FramePos=StreamPos(Handle)
		Framerate=1000.0/30.0
		Time=MilliSecs()
		
		Local Temp:TStream=WriteStream("data/Temp.bmf")
		CopyBytes(Handle,Temp,FrameSize)
		FlushStream(Temp)
		CloseStream(Temp)
		SeekStream(Handle,4)
		Local Tex:TPixmap=LoadPixmap("data/Temp.bmf")
		Tex:TPixmap=YFlipPixmap(Tex)
		'Tex=ResizePixmap(Tex,256,256)
		DeleteFile("data/Temp.bmf")

		glBindTexture(GL_TEXTURE_2D, TextureName)
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST)		' Set Texture Max Filter
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST)		' Set Texture Min Filter
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, tex.width, tex.height, 0, GL_RGB, GL_UNSIGNED_BYTE, tex.pixels)
	End Method
	
	' Close this movie
	Method CloseMovie()
		CloseStream(Handle)
	End Method

	' Update movie frame
	Method UpdateMovie()
		Local InstantTime:Int=MilliSecs()
		If InstantTime-Time<Framerate Then Return
		ActualFrame:+1
		If ActualFrame>=TotalFrame Then
			SeekStream(Handle,4)
			ActualFrame=0
		Else
			SeekStream(Handle,FramePos+FrameSize)
		EndIf
		FrameSize=ReadInt(Handle)
		FramePos=StreamPos(Handle)
		
		Local Temp:TStream=WriteFile("data/Temp.bmf")
		CopyBytes(Handle,Temp,FrameSize)
		FlushStream(Temp)
		CloseStream(Temp)
		SeekStream(Handle,4)
		Local Tex:TPixmap=LoadPixmap("data/Temp.bmf")
		Tex:TPixmap=YFlipPixmap(Tex)
		DeleteFile("data/Temp.bmf")

		glBindTexture(GL_TEXTURE_2D, TextureName)
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, tex.width, tex.height, 0, GL_RGB, GL_UNSIGNED_BYTE, tex.pixels)
		Time=InstantTime
	End Method
	
	' Change the framerate movie
	Method ChangeFrameRate(Rate:Float)
		Framerate=1000.0/Rate
	End Method
End Type

Type TNeHe35 Extends TNeHe
	Field quadratic:Int Ptr									' Storage For Our Quadratic Objects
	Field Movie1:MOVIE=New MOVIE								' Create one movie
	
	Field angle:Float										' Used For Rotation
	Field next1:Int											' Used For Animation
	Field effect:Int											' Current Effect
	Field env:Byte=True										' Environment Mapping (Default On)
	Field bg:Byte=True										' Background (Default On)
	Field Time:Int
	
	Field ShowMenu:Int
	
	'
	'*************************************************************************************
	' methodS
	'*************************************************************************************
	'
	Method Init()
		' Start Of User Initialization
		angle=0.0												' Set Starting Angle To Zero
		glClearColor(0.0, 0.0, 0.0, 0.5)							' Black Background
		glClearDepth(1.0)											' Depth Buffer Setup
		glDepthFunc(GL_LEQUAL)										' The Type Of Depth Testing (Less Or Equal)
		glEnable(GL_DEPTH_TEST)									' Enable Depth Testing
		glShadeModel(GL_SMOOTH)									' Select Smooth Shading
		glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST)			' Set Perspective Calculations To Most Accurate
		
		quadratic=Int Ptr gluNewQuadric()							' Create A Pointer To The Quadric Object
		gluQuadricNormals(quadratic, GL_SMOOTH)					' Create Smooth Normals 
		gluQuadricTexture(quadratic, GL_TRUE)						' Create Texture Coords 
	
		glEnable(GL_TEXTURE_2D)									' Enable Texture Mapping
		glTexGeni(GL_S, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP)			' Set The Texture Generation Mode For S To Sphere Mapping
		glTexGeni(GL_T, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP)			' Set The Texture Generation Mode For T To Sphere Mapping
	
		glGenTextures(1, Varptr Movie1.TextureName)					' Generate one texturename for movie
		Movie1.OpenMovie("data/Face2.bmf")							' Open movie
	
		glViewport(0,0,ScreenWidth,ScreenHeight)							' Set The Current Viewport
		glMatrixMode(GL_PROJECTION)										' Select The Projection Matrix
		glLoadIdentity()													' Reset The Projection Matrix
		gluPerspective(45.0,Float(ScreenWidth)/Float(ScreenHeight),1.0,100.0)	' Calculate The Aspect Ratio Of The Window
		glMatrixMode(GL_MODELVIEW)											' Select The Modelview Matrix
		glLoadIdentity()													' Reset The Modelview Matrix
	End Method
	
	Method Loop()
		Local milliseconds:Int = MilliSecs()-Time
		If KeyHit(KEY_F1) Then ShowMenu=Not ShowMenu
		If KeyHit(KEY_SPACE) Then											' Is Space Being Pressed And Not Held?
			effect:+1													' Change Effects (Increase effect)
			If effect>3 Then effect=0										' Over Our Limit? Reset Back To 0
		EndIf
		If KeyHit(KEY_B) Then												' Is 'B' Being Pressed And Not Held?
			bg=Not bg													' Toggle Background Off/On
		EndIf
		If KeyHit(KEY_E) Then												' Is 'E' Being Pressed And Not Held?
			env=Not env													' Toggle Environment Mapping Off/On
		EndIf
		angle:+Float(milliseconds)/60.0										' Update angle
	
		glClear (GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)				' Clear Screen And Depth Buffer
		Movie1.UpdateMovie()											' Update movie frame
		If bg Then													' Is Background Visible?
			glLoadIdentity()											' Reset The Modelview Matrix
			glBegin(GL_QUADS)											' Begin Drawing The Background (One Quad)
				' Front Face
				glTexCoord2f(1.0, 1.0) ; glVertex3f( 11.0,  8.3, -20.0)
				glTexCoord2f(0.0, 1.0) ; glVertex3f(-11.0,  8.3, -20.0)
				glTexCoord2f(0.0, 0.0) ; glVertex3f(-11.0, -8.3, -20.0)
				glTexCoord2f(1.0, 0.0) ; glVertex3f( 11.0, -8.3, -20.0)
			glEnd()													' Done Drawing The Background
		EndIf
	
		glLoadIdentity()												' Reset The Modelview Matrix
		glTranslatef(0.0, 0.0, -10.0)									' Translate 10 Units Into The Screen
		If env Then													' Is Environment Mapping On?
			glEnable(GL_TEXTURE_GEN_S)									' Enable Texture Coord Generation For S (New)
			glEnable(GL_TEXTURE_GEN_T)									' Enable Texture Coord Generation For T (New)
		EndIf
		
		glRotatef(angle*2.3,1.0,0.0,0.0)								' Throw In Some Rotations To Move Things Around A Bit
		glRotatef(angle*1.8,0.0,1.0,0.0)								' Throw In Some Rotations To Move Things Around A Bit
		glTranslatef(0.0,0.0,2.0)										' After Rotating Translate To New Position
	
		Select effect													' Which Effect?
			Case 0													' Effect 0 - Cube
			glRotatef(angle*1.3, 1.0, 0.0, 0.0)							' Rotate On The X-Axis By angle
			glRotatef(angle*1.1, 0.0, 1.0, 0.0)							' Rotate On The Y-Axis By angle
			glRotatef(angle*1.2, 0.0, 0.0, 1.0)							' Rotate On The Z-Axis By angle
			glBegin(GL_QUADS)											' Begin Drawing A Cube
				' Front Face
				glNormal3f( 0.0, 0.0, 0.5)
				glTexCoord2f(0.0, 0.0) ; glVertex3f(-1.0, -1.0,  1.0)
				glTexCoord2f(1.0, 0.0) ; glVertex3f( 1.0, -1.0,  1.0)
				glTexCoord2f(1.0, 1.0) ; glVertex3f( 1.0,  1.0,  1.0)
				glTexCoord2f(0.0, 1.0) ; glVertex3f(-1.0,  1.0,  1.0)
				' Back Face
				glNormal3f( 0.0, 0.0,-0.5)
				glTexCoord2f(1.0, 0.0) ; glVertex3f(-1.0, -1.0, -1.0)
				glTexCoord2f(1.0, 1.0) ; glVertex3f(-1.0,  1.0, -1.0)
				glTexCoord2f(0.0, 1.0) ; glVertex3f( 1.0,  1.0, -1.0)
				glTexCoord2f(0.0, 0.0) ; glVertex3f( 1.0, -1.0, -1.0)
				' Top Face
				glNormal3f( 0.0, 0.5, 0.0)
				glTexCoord2f(0.0, 1.0) ; glVertex3f(-1.0,  1.0, -1.0)
				glTexCoord2f(0.0, 0.0) ; glVertex3f(-1.0,  1.0,  1.0)
				glTexCoord2f(1.0, 0.0) ; glVertex3f( 1.0,  1.0,  1.0)
				glTexCoord2f(1.0, 1.0) ; glVertex3f( 1.0,  1.0, -1.0)
				' Bottom Face
				glNormal3f( 0.0,-0.5, 0.0)
				glTexCoord2f(1.0, 1.0) ; glVertex3f(-1.0, -1.0, -1.0)
				glTexCoord2f(0.0, 1.0) ; glVertex3f( 1.0, -1.0, -1.0)
				glTexCoord2f(0.0, 0.0) ; glVertex3f( 1.0, -1.0,  1.0)
				glTexCoord2f(1.0, 0.0) ; glVertex3f(-1.0, -1.0,  1.0)
				' Right Face
				glNormal3f( 0.5, 0.0, 0.0)
				glTexCoord2f(1.0, 0.0) ; glVertex3f( 1.0, -1.0, -1.0)
				glTexCoord2f(1.0, 1.0) ; glVertex3f( 1.0,  1.0, -1.0)
				glTexCoord2f(0.0, 1.0) ; glVertex3f( 1.0,  1.0,  1.0)
				glTexCoord2f(0.0, 0.0) ; glVertex3f( 1.0, -1.0,  1.0)
				' Left Face
				glNormal3f(-0.5, 0.0, 0.0)
				glTexCoord2f(0.0, 0.0) ; glVertex3f(-1.0, -1.0, -1.0)
				glTexCoord2f(1.0, 0.0) ; glVertex3f(-1.0, -1.0,  1.0)
				glTexCoord2f(1.0, 1.0) ; glVertex3f(-1.0,  1.0,  1.0)
				glTexCoord2f(0.0, 1.0) ; glVertex3f(-1.0,  1.0, -1.0)
			glEnd()													' Done Drawing Our Cube
		
			Case 1													' Effect 1 - Sphere
			glRotatef(angle*1.3, 1.0, 0.0, 0.0)							' Rotate On The X-Axis By angle
			glRotatef(angle*1.1, 0.0, 1.0, 0.0)							' Rotate On The Y-Axis By angle
			glRotatef(angle*1.2, 0.0, 0.0, 1.0)							' Rotate On The Z-Axis By angle
			gluSphere(quadratic,1.3,20,20)								' Draw A Sphere
	
			Case 2													' Effect 2 - Cylinder
			glRotatef(angle*1.3, 1.0, 0.0, 0.0)							' Rotate On The X-Axis By angle
			glRotatef(angle*1.1, 0.0, 1.0, 0.0)							' Rotate On The Y-Axis By angle
			glRotatef(angle*1.2, 0.0, 0.0, 1.0)							' Rotate On The Z-Axis By angle
			glTranslatef(0.0,0.0,-1.5)									' Center The Cylinder
			gluCylinder(quadratic,1.0,1.0,3.0,32,32)					' Draw A Cylinder
		End Select
		
		If env Then													' Environment Mapping Enabled?
			glDisable(GL_TEXTURE_GEN_S)								' Disable Texture Coord Generation For S (New)
			glDisable(GL_TEXTURE_GEN_T)								' Disable Texture Coord Generation For T (New)
		EndIf

		Time=MilliSecs()
		glColor3f(1.0,1.0,1.0)
		DrawMenu()
	End Method
	
	' Draw menu
	Method DrawMenu()
		glDisable(GL_TEXTURE_2D)	
		glDisable(GL_DEPTH_TEST)
		glColor3f(1.0,1.0,1.0)
		GLDrawText("F1 : Hide/Show menu",10,ScreenHeight-16-8)
		If ShowMenu Then
			GLDrawText("NeHe's movie player: (lesson 35)",10,0)
			GLDrawText("'SPACE'  Change Effects",10,32)
			GLDrawText("'B'      Toggle Background Off/On",10,48)
			GLDrawText("'E'      Toggle Environment Mapping Off/On",10,64)
		EndIf
		glEnable(GL_TEXTURE_2D	)
		glEnable(GL_DEPTH_TEST)
	End Method
End Type