Strict
Import "framework.bmx"

'****************************************************************************************************************
'*                                                      *                                                       *
'*  Lesson 42: Multiple Viewports                       *  Created:  05/17/2003                                 *
'*                                                      *                                                       *
'*  This Program Was Written By Jeff Molofee (NeHe)     *  Runs Much Faster (Many Useless Loops Removed)        *
'*  From http://nehe.gamedev.net.                       *                                                       *
'*                                                      *  Maze Code Is Still Very Unoptimized.  Speed Can Be   *
'*  I Wanted To Create A Maze, And Was Able To Find     *  Increased Considerably By Keeping Track Of Cells     *
'*  Example Code, But Most Of It Was Uncommented And    *  That Have Been Visited Rather Than Randomly          *
'*  Difficult To Figure Out.                            *  Searching For Cells That Still Need To Be Visited.   *
'*                                                      *                                                       *
'*  This Is A Direct Conversion Of Basic Code I Wrote   *  This Tutorial Demonstrates Multiple Viewports In A   *
'*  On The Atari XE Many Years Ago.                     *  Single Window With Both Ortho And Perspective Modes  *
'*                                                      *  Used At The Same Time.  As Well, Two Of The Views    *
'*  It Barely Resembles The Basic Code, But The Idea    *  Have Lighting Enabled, While The Other Two Do Not.   *
'*  Is Exactly The Same.                                *                                                       *
'*                                                      *********************************************************
'*  Branches Are Always Made From An Existing Path      *
'*  So There Should Always Be A Path Through The Maze   *
'*  Although It Could Be Quite Short :)                 *
'*                                                      *
'*  Do Whatever You Want With This Code.  If You Found  *
'*  It Useful Or Have Made Some Nice Changes To It,     *
'*  Send Me An Email: nehe@connect.ab.ca                *
'*                                                      *
'********************************************************
'
' ********************************************************************
' Globals vars
' ********************************************************************
'

New TNeHe42.Run(42,"Multi-Viewport")

Type TNeHe42 Extends TNeHe	
	Global mx:Int, my:Int										' General Loops (Used For Seeking)
	
	Global done:Byte											' Flag To Let Us Know When It's Done
	Global r:Byte[4], g:Byte[4], b:Byte[4]						' Random Colors (4 Red, 4 Green, 4 Blue)
	Global tex_data:Byte Ptr									' Holds Our Texture Data
	
	Global xrot:Float, yrot:Float, zrot:Float					' Use For Rotation Of Objects
	Global quadric:Int Ptr										' The Quadric Object
	Global ShowMenu:Int
	Global tickCount:Int
	
	Const width:Int=128										' Maze Width  (Must Be A Power Of 2)
	Const height:Int=128										' Maze Height (Must Be A Power Of 2)
	
	Method Init()
		tex_data=MemAlloc(width*height*3)								' Allocate Space For Our Texture
		Reset()														' Call Reset To Build Our Initial Texture, Etc.
	
		' Start Of User Initialization
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP)
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP)
		glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR)
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR)
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, width, height, 0, GL_RGB, GL_UNSIGNED_BYTE, tex_data)
	
		glClearColor(0.0, 0.0, 0.0, 0.0)								' Black Background
		glClearDepth(1.0)												' Depth Buffer Setup
		glDepthFunc(GL_LEQUAL)											' The Type Of Depth Testing
		glEnable(GL_DEPTH_TEST)										' Enable Depth Testing
		glEnable(GL_COLOR_MATERIAL)									' Enable Color Material (Allows Us To Tint Textures)
		glEnable(GL_TEXTURE_2D)										' Enable Texture Mapping
	
		quadric=Int Ptr gluNewQuadric()									' Create A Pointer To The Quadric Object
		gluQuadricNormals(quadric, GL_SMOOTH)							' Create Smooth Normals 
		gluQuadricTexture(quadric, GL_TRUE)								' Create Texture Coords
	
		glEnable(GL_LIGHT0)											' Enable Light0 (Default GL Light)
		
		glViewport(0,0,ScreenWidth,ScreenHeight)						' Set viewport
		TickCount=MilliSecs()
	End Method
	
	Method Loop()

		If KeyHit(KEY_F1) Then ShowMenu=Not ShowMenu
		' Update Our Texture... This Is The Key To The Programs Speed... Much Faster Than Rebuilding The Texture Each Time
		glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, width, height, GL_RGB, GL_UNSIGNED_BYTE, tex_data)
	
		glClear(GL_COLOR_BUFFER_BIT)									' Clear Screen
	
		For Local loop:Int=0 Until 4									' Loop To Draw Our 4 Views
			glColor3ub(r[loop],g[loop],b[loop])							' Assign Color To Current View
			If loop=0 Then											' If We Are Drawing The First Scene
				' Set The Viewport To The Top Left.  It Will Take Up Half The Screen Width And Height
				glViewport(0, ScreenHeight/2, ScreenWidth/2, ScreenHeight/2)
				glMatrixMode(GL_PROJECTION)							' Select The Projection Matrix
				glLoadIdentity()										' Reset The Projection Matrix
				' Set Up Ortho Mode To Fit 1/4 The Screen (Size Of A Viewport)
				gluOrtho2D(0, ScreenWidth/2, ScreenHeight/2, 0)
			EndIf
	
			If loop=1 Then											' If We Are Drawing The Second Scene
				' Set The Viewport To The Top Right.  It Will Take Up Half The Screen Width And Height
				glViewport(ScreenWidth/2, ScreenHeight/2, ScreenWidth/2, ScreenHeight/2)
				glMatrixMode(GL_PROJECTION)							' Select The Projection Matrix
				glLoadIdentity()										' Reset The Projection Matrix
				' Set Up Perspective Mode To Fit 1/4 The Screen (Size Of A Viewport)
				gluPerspective( 45.0, Float(ScreenWidth)/Float(ScreenHeight), 0.1, 500.0 )
			EndIf
	
			If loop=2 Then											' If We Are Drawing The Third Scene
				' Set The Viewport To The Bottom Right.  It Will Take Up Half The Screen Width And Height
				glViewport(ScreenWidth/2, 0, ScreenWidth/2, ScreenHeight/2)
				glMatrixMode(GL_PROJECTION)							' Select The Projection Matrix
				glLoadIdentity()										' Reset The Projection Matrix
				' Set Up Perspective Mode To Fit 1/4 The Screen (Size Of A Viewport)
				gluPerspective( 45.0, Float(ScreenWidth)/Float(ScreenHeight), 0.1, 500.0 )
			EndIf
	
			If loop=3 Then											' If We Are Drawing The Fourth Scene
				' Set The Viewport To The Bottom Left.  It Will Take Up Half The Screen Width And Height
				glViewport(0, 0, ScreenWidth/2, ScreenHeight/2)
				glMatrixMode(GL_PROJECTION)							' Select The Projection Matrix
				glLoadIdentity()										' Reset The Projection Matrix
				' Set Up Perspective Mode To Fit 1/4 The Screen (Size Of A Viewport)
				gluPerspective( 45.0, Float(ScreenWidth)/Float(ScreenHeight), 0.1, 500.0 )
			EndIf
	
			glMatrixMode(GL_MODELVIEW)									' Select The Modelview Matrix
			glLoadIdentity()											' Reset The Modelview Matrix
			glClear(GL_DEPTH_BUFFER_BIT)								' Clear Depth Buffer
	
			If loop=0 Then											' Are We Drawing The First Image?  (Original Texture... Ortho)
				glBegin(GL_QUADS)										' Begin Drawing A Single Quad
					' We Fill The Entire 1/4 Section With A Single Textured Quad.
					glTexCoord2f(1.0, 0.0) ; glVertex2i(ScreenWidth/2, 0             )
					glTexCoord2f(0.0, 0.0) ; glVertex2i(0,             0             )
					glTexCoord2f(0.0, 1.0) ; glVertex2i(0,             ScreenHeight/2)
					glTexCoord2f(1.0, 1.0) ; glVertex2i(ScreenWidth/2, ScreenHeight/2)
				glEnd()												' Done Drawing The Textured Quad
			EndIf
	
			If loop=1 Then											' Are We Drawing The Second Image?  (3D Texture Mapped Sphere... Perspective)
				glTranslatef(0.0,0.0,-14.0)							' Move 14 Units Into The Screen
				glRotatef(xrot,1.0,0.0,0.0)							' Rotate By xrot On The X-Axis
				glRotatef(yrot,0.0,1.0,0.0)							' Rotate By yrot On The Y-Axis
				glRotatef(zrot,0.0,0.0,1.0)							' Rotate By zrot On The Z-Axis
				glEnable(GL_LIGHTING)									' Enable Lighting
				gluSphere(quadric,4.0,32,32)							' Draw A Sphere
				glDisable(GL_LIGHTING)									' Disable Lighting
			EndIf
			
			If loop=2 Then											' Are We Drawing The Third Image?  (Texture At An Angle... Perspective)
				glTranslatef(0.0,0.0,-2.0)								' Move 2 Units Into The Screen
				glRotatef(-45.0,1.0,0.0,0.0)							' Tilt The Quad Below Back 45 Degrees.
				glRotatef(zrot/1.5,0.0,0.0,1.0)							' Rotate By zrot/1.5 On The Z-Axis
				glBegin(GL_QUADS)										' Begin Drawing A Single Quad
					glTexCoord2f(1.0, 1.0) ; glVertex3f( 1.0,  1.0, 0.0)
					glTexCoord2f(0.0, 1.0) ; glVertex3f(-1.0,  1.0, 0.0)
					glTexCoord2f(0.0, 0.0) ; glVertex3f(-1.0, -1.0, 0.0)
					glTexCoord2f(1.0, 0.0) ; glVertex3f( 1.0, -1.0, 0.0)
				glEnd()												' Done Drawing The Textured Quad
			EndIf
	
			If loop=3 Then											' Are We Drawing The Fourth Image?  (3D Texture Mapped Cylinder... Perspective)
				glTranslatef(0.0,0.0,-7.0)								' Move 7 Units Into The Screen
				glRotatef(-xrot/2,1.0,0.0,0.0)							' Rotate By -xrot/2 On The X-Axis
				glRotatef(-yrot/2,0.0,1.0,0.0)							' Rotate By -yrot/2 On The Y-Axis
				glRotatef(-zrot/2,0.0,0.0,1.0)							' Rotate By -zrot/2 On The Z-Axis
				glEnable(GL_LIGHTING)									' Enable Lighting
				glTranslatef(0.0,0.0,-2.0)								' Translate -2 On The Z-Axis (To Rotate Cylinder Around The Center, Not An End)
				gluCylinder(quadric,1.5,1.5,4.0,32,16)					' Draw A Cylinder
				glDisable(GL_LIGHTING)									' Disable Lighting
			EndIf
		Next
		Update(MilliSecs()-TickCount)
		TickCount=MilliSecs()
		DrawMenu()
	End Method
	
	' Update Pixel dmx, dmy On The Texture
	Method UpdateTex(dmx:Int, dmy:Int)
		tex_data[0+((dmx+(width*dmy))*3)]=255							' Set Red Pixel To Full Bright
		tex_data[1+((dmx+(width*dmy))*3)]=255							' Set Green Pixel To Full Bright
		tex_data[2+((dmx+(width*dmy))*3)]=255							' Set Blue Pixel To Full Bright
	End Method
	
	' Reset The Maze, Colors, Start Point, Etc
	Method Reset()
		MemClear(tex_data, width * height * 3)							' Clear Out The Texture Memory With 0's
		Rand(MilliSecs())												' Try To Get More Randomness
		For Local loop:Int=0 Until 4									' Loop So We Can Assign 4 Random Colors
			r[loop]=Byte(Rand(0,128)+128)								' Pick A Random Red Color (Bright)
			g[loop]=Byte(Rand(0,128)+128)								' Pick A Random Green Color (Bright)
			b[loop]=Byte(Rand(0,128)+128)								' Pick A Random Blue Color (Bright)
		Next
		mx=Rand(0,(width/2)-1)*2										' Pick A New Random X Position
		my=Rand(0,(height/2)-1)*2										' Pick A New Random Y Position
	End Method
	
	' Perform Motion Updates Here
	Method Update(milliseconds:Float)
		Local dir:Int													' Will Hold Current Direction
	
		If KeyHit(KEY_SPACE) Then										' Check To See If Spacebar Is Pressed
			Reset()													' If So, Call Reset And Start A New Maze
		EndIf
	
		xrot:+(Float(milliseconds)*0.02)								' Increase Rotation On The X-Axis
		yrot:+(Float(milliseconds)*0.03)								' Increase Rotation On The Y-Axis
		zrot:+(Float(milliseconds)*0.015)								' Increase Rotation On The Z-Axis
	
		done=True													' Set done To True
		For Local x:Int=0 Until width Step 2							' Loop Through All The Rooms
			For Local y:Int=0 Until height Step 2						' On X And Y Axis
				If tex_data[((x+(width*y))*3)]=0 Then					' If Current Texture Pixel (Room) Is Blank
					done=False										' We Have To Set done To False (Not Finished Yet)
				EndIf
			Next
		Next
		If done Then Wait()											' If done Is True Then There Were No Unvisited Rooms
	
		' Check To Make Sure We Are Not Trapped (Nowhere Else To Move)
		If (((mx>(width-4) Or tex_data[(((mx+2)+(width*my))*3)]=255)) And ((mx<2 Or tex_data[(((mx-2)+(width*my))*3)]=255)) And ..
			((my>(height-4) Or tex_data[((mx+(width*(my+2)))*3)]=255)) And ((my<2 Or tex_data[((mx+(width*(my-2)))*3)]=255))) Then
			Repeat													' If We Are Trapped
				mx=Rand(0,(width/2)-1)*2								' Pick A New Random X Position
				my=Rand(0,(height/2)-1)*2								' Pick A New Random Y Position
			Until tex_data[((mx+(width*my))*3)]<>0						' Keep Picking A Random Position Until We Find
		EndIf														' One That Has Already Been Tagged (Safe Starting Point)
	
		dir=Rand(0,3)													' Pick A Random Direction
	
		If dir=0 And mx<=width-4 Then									' If The Direction Is 0 (Right) And We Are Not At The Far Right
			If tex_data[(((mx+2)+(width*my))*3)]=0 Then					' And If The Room To The Right Has Not Already Been Visited
				UpdateTex(mx+1,my)									' Update The Texture To Show Path Cut Out Between Rooms
				mx:+2												' Move To The Right (Room To The Right)
			EndIf
		EndIf
	
		If dir=1 And my<=(height-4) Then								' If The Direction Is 1 (Down) And We Are Not At The Bottom
			If tex_data[((mx+(width*(my+2)))*3)]=0 Then					' And If The Room Below Has Not Already Been Visited
				UpdateTex(mx,my+1)									' Update The Texture To Show Path Cut Out Between Rooms
				my:+2												' Move Down (Room Below)
			EndIf
		EndIf
	
		If dir=2 And mx>=2 Then										' If The Direction Is 2 (Left) And We Are Not At The Far Left
			If tex_data[(((mx-2)+(width*my))*3)]=0 Then					' And If The Room To The Left Has Not Already Been Visited
				UpdateTex(mx-1,my)									' Update The Texture To Show Path Cut Out Between Rooms
				mx:-2												' Move To The Left (Room To The Left)
			EndIf
		EndIf
	
		If dir=3 And my>=2 Then										' If The Direction Is 3 (Up) And We Are Not At The Top
			If tex_data[((mx+(width*(my-2)))*3)]=0 Then					' And If The Room Above Has Not Already Been Visited
				UpdateTex(mx,my-1)									' Update The Texture To Show Path Cut Out Between Rooms
				my:-2												' Move Up (Room Above)
			EndIf
		EndIf
		UpdateTex(mx,my)												' Update Current Room
	End Method
	
	Method DrawMenu()
		glViewport(0,0,ScreenWidth,ScreenHeight)
		glDisable(GL_LIGHT0)
		glDisable(GL_TEXTURE_2D)
		glDisable(GL_COLOR_MATERIAL)
		glDisable(GL_DEPTH_TEST)
		glColor3f(1.0,1.0,1.0)
		If Not done Then
			GLDrawText("Lesson 42: Multiple Viewports... 2003 NeHe Productions... Building Maze!",10,0)
		EndIf
		GLDrawText("F1 : Hide/Show menu",10,ScreenHeight-16-8)
		If ShowMenu Then
			GLDrawText("'SPACE'   Reset maze",10,32)
		EndIf
		glEnable(GL_DEPTH_TEST)
		glEnable(GL_COLOR_MATERIAL)
		glEnable(GL_TEXTURE_2D)
		glEnable(GL_LIGHT0)
	End Method
	
	Method Wait()
		' Display A Message At The Top Of The Window, Pause For A Bit And Then Start Building A New Maze!
		glViewport(0,0,ScreenWidth,ScreenHeight)		
		glColor3f(1.0,1.0,1.0)
		glDisable(GL_LIGHT0)
		glDisable(GL_TEXTURE_2D)
		glDisable(GL_COLOR_MATERIAL)
		glDisable(GL_DEPTH_TEST)
		GLDrawText("Lesson 42: Multiple Viewports... 2003 NeHe Productions... Maze Complete!",10,0)
		Flip()
		Delay(5000)
		glEnable(GL_DEPTH_TEST)
		glEnable(GL_COLOR_MATERIAL)
		glEnable(GL_TEXTURE_2D)
		glEnable(GL_LIGHT0)
		Reset()
	End Method
End Type
