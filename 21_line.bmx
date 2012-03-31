Strict
Import "framework.bmx"

New TNeHe21.Run(21,"Line")

Type Objet										' Create A Structure For Our Player
	Field fx:Int, fy:Int							' Fine Movement Position
	Field x:Int, y:Int							' Current Player Position
	Field spin:Float								' Spin Direction
End Type
	
Type TNeHe21 Extends TNeHe	

	Field vline:Byte[11,11]							' Keeps Track Of Verticle Lines
	Field hline:Byte[11,11]							' Keeps Track Of Horizontal Lines
	Field filled:Byte								' Done Filling In The Grid?
	Field gameover:Byte								' Is The Game Over?
	Field anti:Byte=True								' Antialiasing?
	Field active:Byte=True							' Window Active Flag Set To True By Default
	
	Field loop1:Int									' Generic Loop1
	Field loop2:Int									' Generic Loop2
	Field pause:Int									' Enemy Delay
	Field adjust:Int=3								' Speed Adjustment For Really Slow Video Cards
	Field lives:Int=5								' Player Lives
	Field level:Int=1								' Internal Game Level
	Field level2:Int=level							' Displayed Game Level
	Field stage:Int=1								' Game Stage
	
	Field player:objet=New objet						' Player Information
	Field enemy:objet[9]								' Enemy Information
	
	
	Field hourglass:objet=New objet					' Hourglass Information
	
	Field timer:TTImer									' Create a Timer (60 Hertz)
	Field steps:Int[]=[1, 2, 4, 5, 10, 20]				' Stepping Values For Slow Video Adjustment
	Field base:Int
	Field Texture:Int[2]								' Font Texture Storage Space
	
	Field channel:TChannel
	Field channel1:Tchannel	
	Field sound:TSound							' Channel for hourglass sound timer
	Field sound1:TSound

	Method Init()
		timer=CreateTimer(60)						' Create a Timer (60 Hertz)
		For loop1=0 To 8									' Init enneny
			enemy[loop1]=New objet
		Next
		LoadGlTextures()														' Load textures
		BuildFont()															' Build The Font
		ResetObjects()
		glShadeModel(GL_SMOOTH)												' Enable Smooth Shading
		glClearColor(0.0, 0.0, 0.0, 0.5)										' Black Background
		glClearDepth(1.0)														' Depth Buffer Setup
		glHint(GL_LINE_SMOOTH_HINT, GL_NICEST)									' Set Line Antialiasing
		glEnable(GL_BLEND)													' Enable Blending
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)						' Type Of Blending To Use
	
		glViewport(0,0,ScreenWidth,ScreenHeight)								' Set viewport
		glMatrixMode(GL_PROJECTION)											' Select The Projection Matrix
		glLoadIdentity()														' Reset The Projection Matrix
		glOrtho(0.0,ScreenWidth,ScreenHeight,0.0,-1.0,1.0)						' Create Ortho 640x480 View (0,0 At Top Left)
		glMatrixMode(GL_MODELVIEW)												' Select The Modelview Matrix
		glLoadIdentity()
	End Method
	
	Method LoadGlTextures()
		Local TextureImage:TPixmap[2]
		TextureImage:TPixmap[0]=LoadPixmap("Data/Font.bmp")
		TextureImage:TPixmap[0]=YFlipPixmap(TextureImage[0])						' Swap image verticaly (Font image)
		TextureImage:TPixmap[1]=LoadPixmap("Data/Image.bmp")
		
		glGenTextures(2, Varptr texture[0])										' Create Two Textures
		For loop1=0 To 1
			glBindTexture(GL_TEXTURE_2D, texture[loop1]);
			glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
			glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
			glTexImage2D(GL_TEXTURE_2D, 0, 3, TextureImage[loop1].width, TextureImage[loop1].height, 0, GL_RGB, GL_UNSIGNED_BYTE, TextureImage[loop1].pixels)
		Next
	End Method
	
	Method Loop()
		WaitTimer(timer)
	
		If KeyHit(KEY_A)														' If 'A' Key Is Pressed And Not Held
			anti=Not anti														' Toggle Antialiasing
		EndIf
		
		If Not gameover														' If Game Isn't Over : Active Move Objects
			For loop1=0 To (stage*level)-1										' Loop Through The Different Stages
				If (enemy[loop1].x<player.x) And (enemy[loop1].fy = enemy[loop1].y*40) Then
					enemy[loop1].x:+1											' Move The Enemy Right
				EndIf
				If (enemy[loop1].x>player.x) And (enemy[loop1].fy = enemy[loop1].y*40) Then
					enemy[loop1].x:-1											' Move The Enemy Left
				EndIf
				If (enemy[loop1].y<player.y) And (enemy[loop1].fx = enemy[loop1].x*60) Then
					enemy[loop1].y:+1											' Move The Enemy Down
				EndIf
				If (enemy[loop1].y>player.y) And (enemy[loop1].fx = enemy[loop1].x*60) Then
					enemy[loop1].y:-1											' Move The Enemy Up
				EndIf
	
				If (pause>(3-level)) And (hourglass.fx <> 2) Then				' If Our Delay Is Done And Player Doesn't Have Hourglass
					pause=0													' Reset The Delay Counter Back To Zero
					For loop2=0 To (stage*level)-1								' Loop Through All The Enemies
						If enemy[loop2].fx<enemy[loop2].x*60 Then 				' Is Fine Position On X Axis Lower Than Intended Position?
							enemy[loop2].fx:+steps[adjust]						' If So, Increase Fine Position On X Axis
							enemy[loop2].spin:+steps[adjust]					' Spin Enemy Clockwise
						EndIf
						If enemy[loop2].fx>enemy[loop2].x*60 Then				' Is Fine Position On X Axis Higher Than Intended Position?
							enemy[loop2].fx:-steps[adjust]						' If So, Decrease Fine Position On X Axis
							enemy[loop2].spin:-steps[adjust]					' Spin Enemy Counter Clockwise
						EndIf
						If enemy[loop2].fy<enemy[loop2].y*40 Then				' Is Fine Position On Y Axis Lower Than Intended Position?
							enemy[loop2].fy:+steps[adjust]						' If So, Increase Fine Position On Y Axis
							enemy[loop2].spin:+steps[adjust]					' Spin Enemy Clockwise
						EndIf
						If enemy[loop2].fy>enemy[loop2].y*40 Then				' Is Fine Position On Y Axis Higher Than Intended Position?
							enemy[loop2].fy:-steps[adjust]						' If So, Decrease Fine Position On Y Axis
							enemy[loop2].spin:-steps[adjust]					' Spin Enemy Counter Clockwise
						EndIf
					Next
				EndIf
	
				' Are Any Of The Enemies On Top Of The Player?
				If (enemy[loop1].fx=player.fx) And (enemy[loop1].fy=player.fy) Then
					lives:-1													' If So, Player Loses A Life
					If lives = 0 Then											' Are We Out Of Lives?
						gameover=True											' If So, gameover Becomes True
					EndIf
					ResetObjects()											' Reset Player / Enemy Positions
					sound=LoadSound("Data/Die.wav")
					PlaySound(sound)											' Play The Death Sound
				EndIf
			Next
	
			If (KeyDown(KEY_RIGHT)) And (player.x<10) And (player.fx=player.x*60) And (player.fy=player.y*40) Then
				hline[player.x,player.y]=True									' Mark The Current Horizontal Border As Filled
				player.x:+1													' Move The Player Right
			EndIf
			If (KeyDown(KEY_LEFT)) And (player.x>0) And (player.fx=player.x*60) And (player.fy=player.y*40) Then
				player.x:-1													' Move The Player Left
				hline[player.x,player.y]=True									' Mark The Current Horizontal Border As Filled
			EndIf
			If (KeyDown(KEY_DOWN)) And (player.y<10) And (player.fx=player.x*60) And (player.fy=player.y*40) Then
				vline[player.x,player.y]=True									' Mark The Current Verticle Border As Filled
				player.y:+1													' Move The Player Down
			EndIf
			If (KeyDown(KEY_UP)) And (player.y>0) And (player.fx=player.x*60) And (player.fy=player.y*40) Then
				player.y:-1													' Move The Player Up
				vline[player.x,player.y]=True									' Mark The Current Verticle Border As Filled
			EndIf
	
			If player.fx<player.x*60 Then										' Is Fine Position On X Axis Lower Than Intended Position?
				player.fx:+steps[adjust]										' If So, Increase The Fine X Position
			EndIf
			If player.fx>player.x*60 Then										' Is Fine Position On X Axis Greater Than Intended Position?
				player.fx:-steps[adjust]										' If So, Decrease The Fine X Position
			EndIf
			If player.fy<player.y*40 Then										' Is Fine Position On Y Axis Lower Than Intended Position?
				player.fy:+steps[adjust]										' If So, Increase The Fine Y Position
			EndIf
			If (player.fy>player.y*40) Then										' Is Fine Position On Y Axis Lower Than Intended Position?
				player.fy:-steps[adjust]										' If So, Decrease The Fine Y Position
			EndIf
				
			' If The Player Hits The Hourglass While It's Being Displayed On The Screen
			If (player.fx=hourglass.x*60) And (player.fy=hourglass.y*40) And (hourglass.fx=1) Then
				' Play Freeze Enemy Sound
				sound1=LoadSound("Data/freeze.wav",1)
				channel1=PlaySound(sound1)
				hourglass.fx=2												' Set The hourglass fx Variable To Two
				hourglass.fy=0												' Set The hourglass fy Variable To Zero
			EndIf
			player.spin:+0.5*steps[adjust]										' Spin The Player Clockwise
			If player.spin>360.0 Then											' Is The spin Value Greater Than 360?
				player.spin:-360												' If So, Subtract 360
			EndIf
			hourglass.spin:-0.25*steps[adjust]									' Spin The Hourglass Counter Clockwise
			If hourglass.spin<0.0 Then											' Is The spin Value Less Than 0?
				hourglass.spin:+360.0											' If So, Add 360
			EndIf
			hourglass.fy:+steps[adjust]										' Increase The hourglass fy Variable
			' Is The hourglass fx Variable Equal To 0 And The fy Variable Greater Than 6000 Divided By The Current Level?
			If (hourglass.fx=0) And (hourglass.fy>6000/level) Then
				sound=LoadSound("Data/hourglass.wav")
				PlaySound(sound)												' If So, Play The Hourglass Appears Sound
				hourglass.x=Rand(10)											' Give The Hourglass A Random X Value
				hourglass.y=Rand(10)											' Give The Hourglass A Random Y Value
				hourglass.fx=1												' Set hourglass fx Variable To One (Hourglass Stage)
				hourglass.fy=0												' Set hourglass fy Variable To Zero (Counter)
			EndIf
			' Is The hourglass fx Variable Equal To 1 And The fy Variable Greater Than 6000 Divided By The Current Level?
			If (hourglass.fx=1) And (hourglass.fy>6000/level) Then
				hourglass.fx=0												' If So, Set fx To Zero (Hourglass Will Vanish)
				hourglass.fy=0												' Set fy To Zero (Counter Is Reset)
			EndIf
			' Is The hourglass fx Variable Equal To 2 And The fy Variable Greater Than 500 Plus 500 Times The Current Level?
			If (hourglass.fx=2) And (hourglass.fy>500+(500*level)) Then
				StopChannel(channel1)											' If So, Kill The Freeze Sound
				hourglass.fx=0												' Set hourglass fx Variable To Zero
				hourglass.fy=0												' Set hourglass fy Variable To Zero
			EndIf
			pause:+1
		Else																	' Otherwise
			If KeyHit(KEY_SPACE) Then											' If Spacebar Is Being Pressed
				gameover=False												' gameover Becomes False
				filled=True													' filled Becomes True
				level=1														' Starting Level Is Set Back To One
				level2=1														' Displayed Level Is Also Set To One
				stage=0														' Game Stage Is Set To Zero
				lives=5														' Lives Is Set To Five
			EndIf
		EndIf
	
		If filled Then														' Is The Grid Filled In?
			sound=LoadSound("Data/Complete.wav")
			PlaySound(sound)													' If So, Play The Level Complete Sound
			stage:+1															' Increase The Stage
			If stage>3 Then													' Is The Stage Higher Than 3?
				stage=1														' If So, Set The Stage To One
				level:+1														' Increase The Level
				level2:+1													' Increase The Displayed Level
				If level>3 Then												' Is The Level Greater Than 3?
					level=3													' If So, Set The Level To 3
					lives:+1													' Give The Player A Free Life
					If lives>5 Then 											' Does The Player Have More Than 5 Lives?
						lives=5												' If So, Set Lives To Five
					EndIf
				EndIf
			EndIf
			ResetObjects()													' Reset Player / Enemy Positions
			For loop1=0 To 10													' Loop Through The Grid X Coordinates
				For loop2=0 To 10												' Loop Through The Grid Y Coordinates
					If loop1<10 Then											' If X Coordinate Is Less Than 10
						hline[loop1,loop2]=False								' Set The Current Horizontal Value To False
					EndIf
					If loop2<10 Then											' If Y Coordinate Is Less Than 10
						vline[loop1,loop2]=False								' Set The Current Vertical Value To False
					EndIf
				Next
			Next
		EndIf
		
		' Here we draw the game
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)						' Clear Screen And Depth Buffer
		glBindTexture(GL_TEXTURE_2D, texture[0])								' Select Our Font Texture
		glColor3f(1.0,0.5,1.0)													' Set Color To Purple
		glPrint(207,24,"GRID CRAZY",0)											' Write GRID CRAZY On The Screen
		glColor3f(1.0,1.0,0.0)													' Set Color To Yellow
		glPrint(20,24,"Level:" + "".FromInt(level2),1)							' Write Actual Level Stats
		glPrint(20,40,"Stage:" + "".FromInt(stage),1)							' Write Stage Stats
	
		If gameover															' Is The Game Over?
			glColor3ub(Rand(255),Rand(255),Rand(255))							' Pick A Random Color
			glPrint(472,24,"GAME OVER",1)										' Write GAME OVER To The Screen
			glPrint(456,44,"PRESS SPACE",1)										' Write PRESS SPACE To The Screen
		EndIf
	
		For loop1=0 To lives-2													' Loop Through Lives Minus Current Life
			glLoadIdentity()													' Reset The View
			glTranslatef(490.0+(loop1*40.0),40.0,0.0)							' Move To The Right Of Our Title Text
			glRotatef(-player.spin,0.0,0.0,1.0)									' Rotate Counter Clockwise
			glColor3f(0.0,1.0,0.0)												' Set Player Color To Light Green
			glBegin(GL_LINES)													' Start Drawing Our Player Using Lines
				glVertex2d(-5,-5)												' Top Left Of Player
				glVertex2d( 5, 5)												' Bottom Right Of Player
				glVertex2d( 5,-5)												' Top Right Of Player
				glVertex2d(-5, 5)												' Bottom Left Of Player
			glEnd()															' Done Drawing The Player
			glRotatef(-player.spin*0.5,0.0,0.0,1.0)								' Rotate Counter Clockwise
			glColor3f(0.0,0.75,0.0)											' Set Player Color To Dark Green
			glBegin(GL_LINES)													' Start Drawing Our Player Using Lines
				glVertex2d(-7, 0)												' Left Center Of Player
				glVertex2d( 7, 0)												' Right Center Of Player
				glVertex2d( 0,-7)												' Top Center Of Player
				glVertex2d( 0, 7)												' Bottom Center Of Player
			glEnd()															' Done Drawing The Player
		Next
	
		filled=True															' Set Filled To True Before Testing
		glLineWidth(2.0)														' Set Line Width For Cells To 2.0f
		glDisable(GL_LINE_SMOOTH)												' Disable Antialiasing
		glLoadIdentity()														' Reset The Current Modelview Matrix
		For loop1=0 To 10														' Loop From Left To Right
			For loop2=0 To 10													' Loop From Top To Bottom
				glColor3f(0.0,0.5,1.0)											' Set Line Color To Blue
				If hline[loop1,loop2]											' Has The Horizontal Line Been Traced
					glColor3f(1.0,1.0,1.0)										' If So, Set Line Color To White
				EndIf
	
				If loop1<10													' Dont Draw To Far Right
					If Not hline[loop1,loop2]									' If A Horizontal Line Isn't Filled
						filled=False											' filled Becomes False
					EndIf
					glBegin(GL_LINES)											' Start Drawing Horizontal Cell Borders
						glVertex2d(20+(loop1*60),70+(loop2*40))					' Left Side Of Horizontal Line
						glVertex2d(80+(loop1*60),70+(loop2*40))					' Right Side Of Horizontal Line
					glEnd()													' Done Drawing Horizontal Cell Borders
				EndIf
	
				glColor3f(0.0,0.5,1.0)											' Set Line Color To Blue
				If vline[loop1,loop2]											' Has The Horizontal Line Been Traced
					glColor3f(1.0,1.0,1.0)										' If So, Set Line Color To White
				EndIf
				If loop2<10													' Dont Draw To Far Down
					If Not vline[loop1,loop2]									' If A Verticle Line Isn't Filled
						filled=False											' filled Becomes False
					EndIf
					glBegin(GL_LINES)											' Start Drawing Verticle Cell Borders
						glVertex2d(20+(loop1*60),70+(loop2*40))					' Left Side Of Horizontal Line
						glVertex2d(20+(loop1*60),110+(loop2*40))				' Right Side Of Horizontal Line
					glEnd()													' Done Drawing Verticle Cell Borders
				EndIf
	
				glEnable(GL_TEXTURE_2D)										' Enable Texture Mapping
				glColor3f(1.0,1.0,1.0)											' Bright White Color
				glBindTexture(GL_TEXTURE_2D, texture[1])						' Select The Tile Image
				If (loop1<10) And (loop2<10)									' If In Bounds, Fill In Traced Boxes
					' Are All Sides Of The Box Traced?
					If (hline[loop1,loop2]) And (hline[loop1,loop2+1]) And (vline[loop1,loop2]) And (vline[loop1+1,loop2])
						glBegin(GL_QUADS)										' Draw A Textured Quad
							glTexCoord2f((Float(loop1)/10.0)+0.1,1.0-(Float(loop2)/10.0))
							glVertex2d(20+(loop1*60)+59,(70+loop2*40+1))					' Top Right
							glTexCoord2f(Float(loop1)/10.0,1.0-(Float(loop2)/10.0))
							glVertex2d(20+(loop1*60)+1,(70+loop2*40+1))					' Top Left
							glTexCoord2f(Float(loop1)/10.0,1.0-((Float(loop2)/10.0)+0.1))
							glVertex2d(20+(loop1*60)+1,(70+loop2*40)+39)					' Bottom Left
							glTexCoord2f((Float(loop1)/10.0)+0.1,1.0-((Float(loop2)/10.0)+0.1))
							glVertex2d(20+(loop1*60)+59,(70+loop2*40)+39)				' Bottom Right
						glEnd()												' Done Texturing The Box
					EndIf
				EndIf
				glDisable(GL_TEXTURE_2D)										' Disable Texture Mapping
			Next
		Next
		glLineWidth(1.0)														' Set The Line Width To 1.0f
	
		If anti Then															' Is Anti True?
			glEnable(GL_LINE_SMOOTH)											' If So, Enable Antialiasing
		EndIf
	
		If hourglass.fx=1 Then													' If fx=1 Draw The Hourglass
			glLoadIdentity()													' Reset The Modelview Matrix
			glTranslatef(20.0+(hourglass.x*60),70.0+(hourglass.y*40),0.0)			' Move To The Fine Hourglass Position
			glRotatef(hourglass.spin,0.0,0.0,1.0)								' Rotate Clockwise
			glColor3ub(Rand(255),Rand(255),Rand(255))							' Set Hourglass Color To Random Color
			glBegin(GL_LINES)													' Start Drawing Our Hourglass Using Lines
				glVertex2d(-5,-5)												' Top Left Of Hourglass
				glVertex2d( 5, 5)												' Bottom Right Of Hourglass
				glVertex2d( 5,-5)												' Top Right Of Hourglass
				glVertex2d(-5, 5)												' Bottom Left Of Hourglass
				glVertex2d(-5, 5)												' Bottom Left Of Hourglass
				glVertex2d( 5, 5)												' Bottom Right Of Hourglass
				glVertex2d(-5,-5)												' Top Left Of Hourglass
				glVertex2d( 5,-5)												' Top Right Of Hourglass
			glEnd()															' Done Drawing The Hourglass
		EndIf
	
		glLoadIdentity()														' Reset The Modelview Matrix
		glTranslatef(player.fx+20.0,player.fy+70.0,0.0)							' Move To The Fine Player Position
		glRotatef(player.spin,0.0,0.0,1.0)										' Rotate Clockwise
		glColor3f(0.0,1.0,0.0)													' Set Player Color To Light Green
		glBegin(GL_LINES)														' Start Drawing Our Player Using Lines
			glVertex2d(-5,-5)													' Top Left Of Player
			glVertex2d( 5, 5)													' Bottom Right Of Player
			glVertex2d( 5,-5)													' Top Right Of Player
			glVertex2d(-5, 5)													' Bottom Left Of Player
		glEnd()																' Done Drawing The Player
		glRotatef(player.spin*0.5,0.0,0.0,1.0)									' Rotate Clockwise
		glColor3f(0.0,0.75,0.0)												' Set Player Color To Dark Green
		glBegin(GL_LINES)														' Start Drawing Our Player Using Lines
			glVertex2d(-7, 0)													' Left Center Of Player
			glVertex2d( 7, 0)													' Right Center Of Player
			glVertex2d( 0,-7)													' Top Center Of Player
			glVertex2d( 0, 7)													' Bottom Center Of Player
		glEnd()																' Done Drawing The Player
	
		For loop1=0 To (stage*level)-1											' Loop To Draw Enemies
			glLoadIdentity()													' Reset The Modelview Matrix
			glTranslatef(enemy[loop1].fx+20.0,enemy[loop1].fy+70.0,0.0)
			glColor3f(1.0,0.5,0.5)												' Make Enemy Body Pink
			glBegin(GL_LINES)													' Start Drawing Enemy
				glVertex2d( 0,-7)												' Top Point Of Body
				glVertex2d(-7, 0)												' Left Point Of Body
				glVertex2d(-7, 0)												' Left Point Of Body
				glVertex2d( 0, 7)												' Bottom Point Of Body
				glVertex2d( 0, 7)												' Bottom Point Of Body
				glVertex2d( 7, 0)												' Right Point Of Body
				glVertex2d( 7, 0)												' Right Point Of Body
				glVertex2d( 0,-7)												' Top Point Of Body
			glEnd()															' Done Drawing Enemy Body
			glRotatef(enemy[loop1].spin,0.0,0.0,1.0)							' Rotate The Enemy Blade
			glColor3f(1.0,0.0,0.0)												' Make Enemy Blade Red
			glBegin(GL_LINES)													' Start Drawing Enemy Blade
				glVertex2d(-7,-7)												' Top Left Of Enemy
				glVertex2d( 7, 7)												' Bottom Right Of Enemy
				glVertex2d(-7, 7)												' Bottom Left Of Enemy
				glVertex2d( 7,-7)												' Top Right Of Enemy
			glEnd()															' Done Drawing Enemy Blade
		Next
	End Method 
	
	Method ResetObjects()													' Reset Player And Enemies
		player.x=0															' Reset Player X Position To Far Left Of The Screen
		player.y=0															' Reset Player Y Position To The Top Of The Screen
		player.fx=0															' Set Fine X Position To Match
		player.fy=0															' Set Fine Y Position To Match
		hourglass.fx=0														' If So, Set fx To Zero (Hourglass Will Vanish)
		hourglass.fy=0														' Set fy To Zero (Counter Is Reset)
		For loop1=0 To (stage*level)-1											' Loop Through All The Enemies
			enemy[loop1].x=5+Rand(5)											' Select A Random X Position
			enemy[loop1].y=Rand(10)											' Select A Random Y Position
			enemy[loop1].fx=enemy[loop1].x*60									' Set Fine X To Match
			enemy[loop1].fy=enemy[loop1].y*40									' Set Fine Y To Match
		Next
	End Method
	
	Method BuildFont()														' Build Our Font Display List
		Local cx:Float														' Holds Our X Character Coord
		Local cy:Float														' Holds Our Y Character Coord
		base=glGenLists(256)													' Creating 256 Display Lists
		glBindTexture(GL_TEXTURE_2D, texture[0])								' Select Our Font Texture
		For loop1=0 To 255													' Loop Through All 256 Lists
			cx=Float(loop1 Mod 16)/16.0										' X Position Of Current Character
			cy=Float(loop1/16)/16.0											' Y Position Of Current Character
			glNewList(base+loop1,GL_COMPILE)									' Start Building A List
				glBegin(GL_QUADS)												' Use A Quad For Each Character
					glTexCoord2f(cx,1.0-cy-0.0625)								' Texture Coord (Bottom Left)
					glVertex2d(0,16)											' Vertex Coord (Bottom Left)
					glTexCoord2f(cx+0.0625,1.0-cy-0.0625)						' Texture Coord (Bottom Right)
					glVertex2i(16,16)											' Vertex Coord (Bottom Right)
					glTexCoord2f(cx+0.0625,1.0-cy)								' Texture Coord (Top Right)
					glVertex2i(16,0)											' Vertex Coord (Top Right)
					glTexCoord2f(cx,1.0-cy)									' Texture Coord (Top Left)
					glVertex2i(0,0)											' Vertex Coord (Top Left)
				glEnd()														' Done Building Our Quad (Character)
				glTranslated(15,0,0)											' Move To The Right Of The Character
			glEndList()														' Done Building The Display List
		Next
	End Method
	
	Method glPrint(x:Int, y:Int, phrase:String, set:Int)						' Where The Printing Happens
		If (set>1) Then set=1
		glEnable(GL_TEXTURE_2D)												' Enable Texture Mapping
		glLoadIdentity()														' Reset The Modelview Matrix
		glTranslated(x,y,0)													' Position The Text (0,0 - Bottom Left)
		glListBase(base-32 + (128 * set))										' Choose The Font Set (0 Or 1)
		If set=0 Then glScalef(1.5,2.0,1.0)										' Enlarge Font Width And Height
		glCallLists(phrase.length, GL_UNSIGNED_BYTE, Byte Ptr phrase.ToCString())				' Write The Text To The Screen
		glDisable(GL_TEXTURE_2D)												' Disable Texture Mapping
	End Method
End Type