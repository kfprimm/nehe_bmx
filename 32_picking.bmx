Strict
Import "framework.bmx"'

New TNeHe32.Run(32,"Picking")

'
'***************************************************************************************************************
' Modified to use TGA Loader
'***************************************************************************************************************
'
' ********************************************************************
' STRUCTURE
' ********************************************************************
Type objects
	Field rot:Int										' Rotation (0-None, 1-Clockwise, 2-Counter Clockwise)
	Field hit:Byte									' Object Hit?
	Field frame:Int									' Current Explosion Frame
	Field dir:Int										' Object Direction (0-Left, 1-Right, 2-Up, 3-Down)
	Field texid:Int									' Object Texture ID
	Field x:Float, y:Float								' Object X/Y Position
	Field spin:Float									' Object Spin
	Field distance:Float								' Object Distance

	Method Compare(other:Object)						' Override default Compare method
		Return Sgn(distance-objects(other).distance)
	End Method
End Type

Type dimensions										' Object Dimensions
	Field w:Float										' Object Width
	Field h:Float										' Object Height
	
	Function Init:dimensions(Width:Float, Height:Float)
		Local result:dimensions=New dimensions
		result.w=Width ; result.h=Height
		Return result
	End Function
End Type

	Type TNehe32 Extends TNehe
	' ********************************************************************
	' fields vars
	' ********************************************************************
	
	Field base:Int										' Font Display List
	Field roll:Float										' Rolling Clouds
	Field level:Int=1									' Current Level
	Field miss:Int										' Missed Targets
	Field kills:Int										' Level Kill Counter
	Field score:Int										' Current Score
	Field game:Byte=1									' Game Over?
	Field textures[10]									' Storage For 10 Textures
	Field Objet:objects[30]								' Storage For 30 Objects
	' Size Of Each Object
	Field size:dimensions[5]
	
	Field sound:TSound
	Field Time:Int

	Method Init()
		Time=MilliSecs()
	
		For Local t:Int=0 Until 30
			Objet:objects[t]=New objects
		Next
		SeedRnd MilliSecs()									' Randomize Things
		'
		' Blueface
		size[0]=dimensions.Init(1.0, 1.0)
		' Bucket
		size[1]=dimensions.Init(1.0, 1.0)
		' Target
		size[2]=dimensions.Init(1.0, 1.0)
		' Coke
		size[3]=dimensions.Init(0.5, 1.0)
		' Vase
		size[4]=dimensions.Init(0.75, 1.5)

		sound = LoadSound("data/shot.wav")
		If Not LoadTGA(Varptr textures[0],"Data/BlueFace.tga") Or ..	' Load The BlueFace Texture
		Not LoadTGA(Varptr textures[1],"Data/Bucket.tga") Or ..		' Load The Bucket Texture
		Not LoadTGA(Varptr textures[2],"Data/Target.tga") Or ..		' Load The Target Texture
		Not LoadTGA(Varptr textures[3],"Data/Coke.tga") Or ..			' Load The Coke Texture
		Not LoadTGA(Varptr textures[4],"Data/Vase.tga") Or ..			' Load The Vase Texture
		Not LoadTGA(Varptr textures[5],"Data/Explode.tga") Or ..		' Load The Explosion Texture
		Not LoadTGA(Varptr textures[6],"Data/Ground.tga") Or ..		' Load The Ground Texture
		Not LoadTGA(Varptr textures[7],"Data/Sky.tga") Or ..			' Load The Sky Texture
		Not LoadTGA(Varptr textures[8],"Data/Crosshair.tga") Or ..	' Load The Crosshair Texture
		Not LoadTGA(Varptr textures[9],"Data/Font1.tga") Then			' Load The Crosshair Texture
			Return False
		EndIf
		BuildFont()											' Build Our Font Display List
	
		glClearColor(0.0, 0.0, 0.0, 0.0)						' Black Background
		glClearDepth(1.0)										' Depth Buffer Setup
		glDepthFunc(GL_LEQUAL)									' Type Of Depth Testing
		glEnable(GL_DEPTH_TEST)								' Enable Depth Testing
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)		' Enable Alpha Blending (disable alpha testing)
		glEnable(GL_BLEND)									' Enable Blending       (disable alpha testing)
		'glAlphaFunc(GL_GREATER,0.1)							' Set Alpha Testing     (disable blending)
		'glEnable(GL_ALPHA_TEST)								' Enable Alpha Testing  (disable blending)
		glEnable(GL_TEXTURE_2D)								' Enable Texture Mapping
		glEnable(GL_CULL_FACE)									' Remove Back Face
	
		For Local loop:Int=0 Until 30							' Loop Through 30 Objects
			InitObject(loop)									' Initialize Each Object
		Next
	
		glViewport(0,0,ScreenWidth,ScreenHeight)							' Set viewport
		glMatrixMode(GL_PROJECTION)										' Select The Projection Matrix
		glLoadIdentity()													' Reset The Projection Matrix
		gluPerspective(45.0,Float(ScreenWidth)/Float(ScreenHeight),1.0,100.0)	' Calculate The Aspect Ratio Of The Window
		glMatrixMode(GL_MODELVIEW)											' Select The Modelview Matrix
		glLoadIdentity()
		Return True														' Return True (Initialization Successful)
	End Method
	
	Function LoadTGA(Tex:Int Ptr, file:String)
		Local Bpp:Int														' Store bit per pixel and GL mode
		Local TextureImage:TPixmap
		
		Local In:TStream=OpenFile(file)													' Open TGA file
		If Not In Then Return False										' File not opened return Error
		SeekStream(In, 16)												' Set file pointer to position 16
		Bpp=ReadByte(In)													' Read bit per pixel
		CloseStream(In)													' Close the file
		' Check GL mode
		If Bpp=24 Then
			Bpp=Gl_RGB
		ElseIf Bpp=32
			Bpp=GL_RGBA
		Else
			Return False
		EndIf
		
		TextureImage:TPixmap=LoadPixmap(file)
		If file="Data/Font1.tga" Then
			TextureImage:TPixmap=YFlipPixmap(TextureImage)					' Swap image verticaly (font image)
		EndIf
	
		glGenTextures(1, Tex)												' Generate OpenGL texture IDs
		glBindTexture(GL_TEXTURE_2D, Tex[0])								' Bind Our Texture
		glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR)		' Linear Filtered
		glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR)		' Linear Filtered
		glTexImage2D(GL_TEXTURE_2D, 0, Bpp, TextureImage.width, TextureImage.height, 0, Bpp, GL_UNSIGNED_BYTE, TextureImage.pixels)
		Return True
	End Function
	
	Method BuildFont()													' Build Our Font Display List
		Local cx:Float													' Holds Our X Character Coord
		Local cy:Float													' Holds Our Y Character Coord
		base=glGenLists(95)												' Creating 256 Display Lists
		glBindTexture(GL_TEXTURE_2D, textures[9])							' Select Our Font Texture
		For Local loop=0 Until 95											' Loop Through All 256 Lists
			cx=Float(loop Mod 16)/16.0										' X Position Of Current Character
			cy=Float(loop/16)/8.0											' Y Position Of Current Character
			glNewList(base+loop,GL_COMPILE)									' Start Building A List
				glBegin(GL_QUADS)											' Use A Quad For Each Character
					glTexCoord2f(cx,1.0-cy-0.120)							' Texture Coord (Bottom Left)
					glVertex2i(0,0)										' Vertex Coord (Bottom Left)
					glTexCoord2f(cx+0.0625,1.0-cy-0.120)					' Texture Coord (Bottom Right)
					glVertex2i(16,0)										' Vertex Coord (Bottom Right)
					glTexCoord2f(cx+0.0625,1.0-cy)							' Texture Coord (Top Right)
					glVertex2i(16,16)										' Vertex Coord (Top Right)
					glTexCoord2f(cx,1.0-cy)								' Texture Coord (Top Left)
					glVertex2i(0,16)										' Vertex Coord (Top Left)
				glEnd()													' Done Building Our Quad (Character)
				glTranslated(10,0,0)										' Move To The Right Of The Character
			glEndList()													' Done Building The Display List
		Next
	End Method
	
	Method glPrint(x:Int, y:Int, phrase:String)							' Where The Printing Happens
		glBindTexture(GL_TEXTURE_2D, textures[9])							' Select Our Font Texture
		glPushMatrix()													' Store The Modelview Matrix
		glLoadIdentity()													' Reset The Modelview Matrix
		glTranslated(x,y,0)												' Position The Text (0,0 - Bottom Left)
		glListBase(base-32)												' Choose The Font Set
		glCallLists(phrase.length, GL_UNSIGNED_BYTE, Byte Ptr phrase.ToCString())			' Write The Text To The Screen
		glPopMatrix()														' Restore The Old Projection Matrix	
	End Method
	
	Method SortArrayType(This:objects[], level:Int)						' Sort an array of type
		Local temp:objects=New objects
		Local Sorted:Int=1
		If level=1 Then Return	
		While Sorted=1
			sorted=0
			For Local t=1 Until level
				If This[t-1].Compare(This[t]) = 1 Then
					temp=This[t-1]
					This[t-1]=This[t]
					This[t]=temp
					Sorted=1		
				EndIf
			Next
		Wend
	End Method
	
	Method InitObject(num:Int)											' Initialize An Object
		Objet[num].rot=1													' Clockwise Rotation
		Objet[num].frame=0												' Reset The Explosion Frame To Zero
		Objet[num].hit=False												' Reset Object Has Been Hit Status To False
		Objet[num].texid=Rand(4)											' Assign A New Texture
		Objet[num].distance=-Float(Rand(4000))/100.0							' Random Distance
		Objet[num].y=-1.5+(Float(Rand(450))/100.0)							' Random Y Position
		' Random Starting X Position Based On Distance Of Object And Random Amount For A Delay (Positive Value)
		Objet[num].x=((Objet[num].distance-15.0)/2.0)-Float(5*level)-Float(Rand(5*level))
		Objet[num].dir=Rand(0,1)												' Pick A Random Direction
	
		If Objet[num].dir=0 Then											' Is Random Direction Right
			Objet[num].rot=2												' Counter Clockwise Rotation
			Objet[num].x=-Objet[num].x										' Start On The Left Side (Negative Value)
		EndIf
		
		If Objet[num].texid=0 Then											' Blue Face
			Objet[num].y=-2.0												' Always Rolling On The Ground
		EndIf
		
		If Objet[num].texid=1 Then											' Bucket
			Objet[num].dir=3												' Falling Down
			Objet[num].x=Float(Rand(Int(Objet[num].distance-9.0)))-((Objet[num].distance-9.0)/2.0)
			Objet[num].y=4.5												' Random X, Start At Top Of The Screen
		EndIf
	
		If Objet[num].texid=2 Then											' Target
			Objet[num].dir=2												' Start Off Flying Up
			Objet[num].x=Float(Rand(Int(Objet[num].distance-9.0)))-((Objet[num].distance-9.0)/2.0)
			Objet[num].y=-3.0-Float(Rand(5*level))							' Random X, Start Under Ground + Random Value
		EndIf
	
		SortArrayType(Objet, level)
	
	End Method
	
	Method Selection()													' This Is Where Selection Is Done
		Local buffer:Int[512]												' Set Up A Selection Buffer
		Local hits:Int													' The Number Of Objects That We Selected
	
		' Is Game Over? If So, Don't Bother Checking For Hits
		If game Then Return
		
		PlaySound sound													' Play Gun Shot Sound
	
		' The Size Of The Viewport. [0] Is <x>, [1] Is <y>, [2] Is <length>, [3] Is <width>
		Local viewport:Int[4]
	
		' This Sets The Array <viewport> To The Size And Location Of The Screen Relative To The Window
		glGetIntegerv(GL_VIEWPORT, viewport)
		glSelectBuffer(512, Varptr buffer[0])										' Tell OpenGL To Use Our Array For Selection
	
		' Puts OpenGL In Selection Mode. Nothing Will Be Drawn.  Object ID's and Extents Are Stored In The Buffer.
		glRenderMode(GL_SELECT)
		glInitNames()														' Initializes The Name Stack
		glPushName(0)														' Push 0 (At Least One Entry) Onto The Stack
	
		glMatrixMode(GL_PROJECTION)										' Selects The Projection Matrix
		glPushMatrix()													' Push The Projection Matrix
		glLoadIdentity()													' Resets The Matrix
	
		' This Creates A Matrix That Will Zoom Up To A Small Portion Of The Screen, Where The Mouse Is.
		gluPickMatrix( Double(MouseX()), Double(viewport[3]-MouseY()), 1.0, 1.0, viewport)
	
		' Apply The Perspective Matrix
		gluPerspective(45.0, Float(viewport[2]-viewport[0]) / Float(viewport[3]-viewport[1]), 0.1, 100.0)
		glMatrixMode(GL_MODELVIEW)											' Select The Modelview Matrix
		DrawTargets()														' Render The Targets To The Selection Buffer
		glMatrixMode(GL_PROJECTION)										' Select The Projection Matrix
		glPopMatrix()														' Pop The Projection Matrix
		glMatrixMode(GL_MODELVIEW)											' Select The Modelview Matrix
		' Switch To Render Mode, Find Out How Many Objects Were Drawn Where The Mouse Was
		hits=glRenderMode(GL_RENDER)
		If hits>0 Then													' If There Were More Than 0 Hits
			Local choose:Int=buffer[3]										' Make Our Selection The First Object
			Local depth:Int=buffer[1]										' Store How Far Away It Is 
	
			For Local loop=1 Until hits									' Loop Through All The Detected Hits
				' If This Object Is Closer To Us Than The One We Have Selected
				If buffer[loop*4+1] < depth Then
					choose=buffer[loop*4+3]								' Select The Closer Object
					depth = buffer[loop*4+1]								' Store How Far Away It Is
				EndIf       
			Next
	
			If Not Objet[choose].hit Then									' If The Object Hasn't Already Been Hit
				Objet[choose].hit=True										' Mark The Object As Being Hit
				score:+1													' Increase Score
				kills:+1													' Increase Level Kills
				If kills>level*5											' New Level Yet?
					miss=0												' Misses Reset Back To Zero
					kills=0												' Reset Level Kills
					level:+1												' Increase Level
					If (level>30)	 Then level=30							' Higher Than 30?
				EndIf
			EndIf
	    EndIf
	End Method
	
	Method Update(milliseconds:Int)										' Perform Motion Updates Here
		Local loop:Int
		
		If KeyHit(KEY_SPACE) And game										' Space Bar Being Pressed After Game Has Ended?
			For loop=0 Until 30											' Loop Through 30 Objects
				InitObject(loop)											' Initialize Each Object
			Next
			game=False													' Set game (Game Over) To False
			score=0														' Set score To 0
			level=1														' Set level Back To 1
			kills=0														' Zero Player Kills
			miss=0														' Set miss (Missed Shots) To 0
		EndIf
	
		roll:-milliseconds*0.00005											' Roll The Clouds
	
		For loop=0 Until level												' Loop Through The Objects
			If Objet[loop].rot=1 Then										' If Rotation Is Clockwise
				Objet[loop].spin:-0.2*Float(loop+milliseconds)				' Spin Clockwise
			EndIf
			If Objet[loop].rot=2 Then										' If Rotation Is Counter Clockwise
				Objet[loop].spin:+0.2*Float(loop+milliseconds)				' Spin Counter Clockwise
			EndIf
			If Objet[loop].dir=1 Then										' If Direction Is Right
				Objet[loop].x:+0.012*Float(milliseconds)					' Move Right
			EndIf
			If Objet[loop].dir=0 Then										' If Direction Is Left
				Objet[loop].x:-0.012*Float(milliseconds)					' Move Left
			EndIf
			If Objet[loop].dir=2 Then										' If Direction Is Up
				Objet[loop].y:+(0.012*Float(milliseconds))					' Move Up
			EndIf
			If Objet[loop].dir=3 Then										' If Direction Is Down
				Objet[loop].y:-(0.0025*Float(milliseconds))					' Move Down
			EndIf
			
			' If We Are To Far Left, Direction Is Left And The Object Was Not Hit
			If (Objet[loop].x<(Objet[loop].distance-15.0)/2.0) And Objet[loop].dir=0 And (Not Objet[loop].hit) Then
				miss:+1													' Increase miss (Missed Object)
				Objet[loop].hit=True										' Set hit To True To Manually Blow Up The Object
			EndIf
	
			' If We Are To Far Right, Direction Is Left And The Object Was Not Hit
			If (Objet[loop].x>-(Objet[loop].distance-15.0)/2.0) And Objet[loop].dir=1 And (Not Objet[loop].hit) Then
				miss:+1													' Increase miss (Missed Object)
				Objet[loop].hit=True										' Set hit To True To Manually Blow Up The Object
			EndIf
	
			' If We Are To Far Down, Direction Is Down And The Object Was Not Hit
			If Objet[loop].y<-2.0 And Objet[loop].dir=3 And (Not Objet[loop].hit) Then
				miss:+1													' Increase miss (Missed Object)
				Objet[loop].hit=True										' Set hit To True To Manually Blow Up The Object
			EndIf
	
			If Objet[loop].y>4.5 And Objet[loop].dir=2 Then					' If We Are To Far Up And The Direction Is Up
				Objet[loop].dir=3											' Change The Direction To Down
			EndIf
		Next
	End Method
	
	Method DrawObject(width:Float, height:Float, texid:Int)					' Draw Object Using Requested Width, Height And Texture
		glBindTexture(GL_TEXTURE_2D, textures[texid])						' Select The Correct Texture
		glBegin(GL_QUADS)													' Start Drawing A Quad
			glTexCoord2f(0.0,0.0) ; glVertex3f(-width,-height,0.0)			' Bottom Left
			glTexCoord2f(1.0,0.0) ; glVertex3f( width,-height,0.0)			' Bottom Right
			glTexCoord2f(1.0,1.0) ; glVertex3f( width, height,0.0)			' Top Right
			glTexCoord2f(0.0,1.0) ; glVertex3f(-width, height,0.0)			' Top Left
		glEnd()															' Done Drawing Quad
	End Method
	
	Method Explosion(num:Int)											' Draws An Animated Explosion For Object "num"
		Local ex:Float=Float((Objet[num].frame/4) Mod 4)/4.0					' Calculate Explosion X Frame (0.0f - 0.75f)
		Local ey:Float=Float((Objet[num].frame/4) / 4)/4.0					' Calculate Explosion Y Frame (0.0f - 0.75f)
	
		glBindTexture(GL_TEXTURE_2D, textures[5])							' Select The Explosion Texture
		glBegin(GL_QUADS)													' Begin Drawing A Quad
			glTexCoord2f(ex     , 1.0-(ey)     ) ; glVertex3f(-1.0,-1.0,0.0)	' Bottom Left
			glTexCoord2f(ex+0.25, 1.0-(ey)     ) ; glVertex3f( 1.0,-1.0,0.0)	' Bottom Right
			glTexCoord2f(ex+0.25, 1.0-(ey+0.25)) ; glVertex3f( 1.0, 1.0,0.0)	' Top Right
			glTexCoord2f(ex     , 1.0-(ey+0.25)) ; glVertex3f(-1.0, 1.0,0.0)	' Top Left
		glEnd()															' Done Drawing Quad
	
		Objet[num].frame:+1												' Increase Current Explosion Frame
		If Objet[num].frame>63 Then										' Have We Gone Through All 16 Frames?
			InitObject(num)												' Init The Object (Assign New Values)
		EndIf
	End Method
	
	Method DrawTargets()													' Draws The Targets (Needs To Be Seperate)
		glLoadIdentity()													' Reset The Modelview Matrix
		glTranslatef(0.0,0.0,-10.0)										' Move Into The Screen 20 Units
		For Local loop=0 Until level										' Loop Through 9 Objects
			glLoadName(loop)												' Assign Object A Name (ID)
			glPushMatrix()												' Push The Modelview Matrix
			glTranslatef(Objet[loop].x,Objet[loop].y,Objet[loop].distance)		' Position The Object (x,y)
			If Objet[loop].hit Then										' If Object Has Been Hit
				Explosion(loop)											' Draw An Explosion
			Else															' Otherwise
				glRotatef(Objet[loop].spin,0.0,0.0,1.0)						' Rotate The Object
				DrawObject(size[Objet[loop].texid].w,size[Objet[loop].texid].h,Objet[loop].texid)	' Draw The Object
			EndIf
			glPopMatrix()													' Pop The Modelview Matrix
		Next
	End Method
	
	Method loop()														' Draw Our Scene
		glClear (GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)					' Clear Screen And Depth Buffer
		glLoadIdentity()													' Reset The Modelview Matrix
	
		glPushMatrix()													' Push The Modelview Matrix
		glBindTexture(GL_TEXTURE_2D, textures[7])							' Select The Sky Texture
		glBegin(GL_QUADS)													' Begin Drawing Quads
			glTexCoord2f(1.0,roll/1.5+1.0) ; glVertex3f( 28.0,+7.0,-50.0)		' Top Right
			glTexCoord2f(0.0,roll/1.5+1.0) ; glVertex3f(-28.0,+7.0,-50.0)		' Top Left
			glTexCoord2f(0.0,roll/1.5+0.0) ; glVertex3f(-28.0,-3.0,-50.0)		' Bottom Left
			glTexCoord2f(1.0,roll/1.5+0.0) ; glVertex3f( 28.0,-3.0,-50.0)		' Bottom Right
	
			glTexCoord2f(1.5,roll+1.0) ; glVertex3f( 28.0,+7.0,-50.0)			' Top Right
			glTexCoord2f(0.5,roll+1.0) ; glVertex3f(-28.0,+7.0,-50.0)			' Top Left
			glTexCoord2f(0.5,roll+0.0) ; glVertex3f(-28.0,-3.0,-50.0)			' Bottom Left
			glTexCoord2f(1.5,roll+0.0) ; glVertex3f( 28.0,-3.0,-50.0)			' Bottom Right
	
			glTexCoord2f(1.0,roll/1.5+1.0) ; glVertex3f( 28.0,+7.0,0.0)		' Top Right
			glTexCoord2f(0.0,roll/1.5+1.0) ; glVertex3f(-28.0,+7.0,0.0)		' Top Left
			glTexCoord2f(0.0,roll/1.5+0.0) ; glVertex3f(-28.0,+7.0,-50.0)		' Bottom Left
			glTexCoord2f(1.0,roll/1.5+0.0) ; glVertex3f( 28.0,+7.0,-50.0)		' Bottom Right
	
			glTexCoord2f(1.5,roll+1.0) ; glVertex3f( 28.0,+7.0,0.0)			' Top Right
			glTexCoord2f(0.5,roll+1.0) ; glVertex3f(-28.0,+7.0,0.0)			' Top Left
			glTexCoord2f(0.5,roll+0.0) ; glVertex3f(-28.0,+7.0,-50.0)			' Bottom Left
			glTexCoord2f(1.5,roll+0.0) ; glVertex3f( 28.0,+7.0,-50.0)			' Bottom Right
		glEnd()															' Done Drawing Quads
	
		glBindTexture(GL_TEXTURE_2D, textures[6])							' Select The Ground Texture
		glBegin(GL_QUADS)													' Draw A Quad
			glTexCoord2f(7.0,4.0-roll) ; glVertex3f( 27.0,-3.0,-50.0)			' Top Right
			glTexCoord2f(0.0,4.0-roll) ; glVertex3f(-27.0,-3.0,-50.0)			' Top Left
			glTexCoord2f(0.0,0.0-roll) ; glVertex3f(-27.0,-3.0,0.0)			' Bottom Left
			glTexCoord2f(7.0,0.0-roll) ; glVertex3f( 27.0,-3.0,0.0)			' Bottom Right
		glEnd()															' Done Drawing Quad
	
		DrawTargets()														' Draw Our Targets
		glPopMatrix()														' Pop The Modelview Matrix
		
		' Ortho mode X0/Y0 coordinate is bottom/left 
		' Crosshair (In Ortho View)
		glMatrixMode(GL_PROJECTION)										' Select The Projection Matrix
		glPushMatrix()													' Store The Projection Matrix
		glLoadIdentity()													' Reset The Projection Matrix
		glOrtho(0,ScreenWidth,0,ScreenHeight,-1,1)							' Set Up An Ortho Screen
		glMatrixMode(GL_MODELVIEW)											' Select The Modelview Matrix
		glTranslated(MouseX(),ScreenHeight-MouseY(),0.0)						' Move To The Current Mouse Position
		DrawObject(16,16,8)												' Draw The Crosshair
	
		' Game Stats / Title
		glPrint((ScreenWidth/2)-((35*10)/2),ScreenHeight-50,"NeHe's Picking Tutorial (lesson 32)")
		glPrint((ScreenWidth/2)-((16*10)/2),ScreenHeight-50-16,"NeHe Productions")		' Print Title
		glPrint(10,10,"Level: " + "".FromInt(level))							' Print Level
		glPrint((ScreenWidth/2)-((7*10)/2),10,"Score: " + "".FromInt(score))	' Print Score
	
		If miss>9 Then													' Have We Missed 10 Objects?
			miss=9														' Limit Misses To 10
			game=True													' Game Over True
		EndIf
	
		If game Then														' Is Game Over?
			glPrint(ScreenWidth-10-(11*10),10,"GAME OVER")					' Game Over Message
			glprint((ScreenWidth/2)-((20*10)/2),(ScreenHeight/2)-8,"Press space to Start")
		Else
			glPrint(ScreenWidth-10-(11*10),10,"Morale: " + "".FromInt(10-miss))	' Print Morale #/10
		EndIf
		
		glMatrixMode(GL_PROJECTION)										' Select The Projection Matrix
		glPopMatrix()														' Restore The Old Projection Matrix
		glMatrixMode(GL_MODELVIEW)
		Update(MilliSecs()-Time)										' Update The Counter
		Time=MilliSecs()
		If MouseHit(1) Then
			Selection()
		EndIf
	End Method

End Type