Strict
Import "framework.bmx"

New TNeHe19.Run(19,"Particle")

Type particles						' Create A Structure For Particle
	Field active:Byte					' Active (Yes/No)
	Field life:Float					' Particle Life
	Field fade:Float					' Fade Speed
	Field r:Float						' Red Value
	Field g:Float						' Green Value
	Field b:Float						' Blue Value
	Field x:Float						' X Position
	Field y:Float						' Y Position
	Field z:Float						' Z Position
	Field xi:Float					' X Direction
	Field yi:Float					' Y Direction
	Field zi:Float					' Z Direction
	Field xg:Float					' X Gravity
	Field yg:Float					' Y Gravity
	Field zg:Float					' Z Gravity
End Type

Type TNeHe19 Extends TNehe
	Field ScreenWidth:Int=800
	Field ScreenHeight:Int=600
	Field ScreenDepth:Int=32
	
	Const MAX_PARTICLES=1000				' Number Of Particles To Create
	
	Field rainbow:Byte=True				' Rainbow Mode?
	Field slowdown:Float=2.0				' Slow Down Particles
	Field xspeed:Float					' Base X Speed (To Allow Keyboard Direction Of Tail)
	Field yspeed:Float					' Base Y Speed (To Allow Keyboard Direction Of Tail)
	Field zoom:Float=-40.0				' Used To Zoom Out
	Field loops:Int						' Misc Loop Variable
	Field col:Int						' Current Color Selection
	Field pause:Int						' Rainbow Effect Delay
	
	
	Field particle:particles[]			' Particle Array (Room For Particle Info)
	
	Field colors:Float[12,3]
	
	Field Texname:Int					' Storage For Our Particle Texture

	Method Init()
	
		colors[0,0]=1.0 ; colors[0,1]=0.5 ; colors[0,2]=0.5
		colors[1,0]=1.0 ; colors[1,1]=0.75 ; colors[1,2]=0.5
		colors[2,0]=1.0 ; colors[2,1]=1.0 ; colors[2,2]=0.5
		colors[3,0]=0.75 ; colors[3,1]=1.0 ; colors[3,2]=0.5
		colors[4,0]=0.5 ; colors[4,1]=1.0 ; colors[4,2]=0.5
		colors[5,0]=0.5 ; colors[5,1]=1.0 ; colors[5,2]=0.75
		colors[6,0]=0.5 ; colors[6,1]=1.0 ; colors[6,2]=1.0
		colors[7,0]=0.5 ; colors[7,1]=0.75 ; colors[7,2]=1.0
		colors[8,0]=0.5 ; colors[8,1]=0.5 ; colors[8,2]=1.0
		colors[9,0]=0.75 ; colors[9,1]=0.5 ; colors[9,2]=1.0
		colors[10,0]=1.0 ; colors[10,1]=0.5 ; colors[10,2]=1.0
		colors[11,0]=1.0 ; colors[11,1]=0.5 ; colors[11,2]=0.75
	
		LoadGlTextures()
		glEnable(GL_TEXTURE_2D)											' Enable Texture Mapping
		glShadeModel(GL_SMOOTH)											' Enable Smooth Shading
		glClearColor(0.0, 0.0, 0.0, 0.0)									' Black Background
		glClearDepth(1.0)													' Depth Buffer Setup
		glDisable(GL_DEPTH_TEST)											' Disable Depth Testing
		glEnable(GL_BLEND)												' Enable Blending
		glBlendFunc(GL_SRC_ALPHA,GL_ONE)									' Type Of Blending To Perform
		glDepthFunc(GL_LEQUAL)												' The Type Of Depth Testing To Do
		glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST)					' Really Nice Perspective Calculations
		glHint(GL_POINT_SMOOTH_HINT,GL_NICEST)								' Really Nice Point Smoothing
		glBindTexture(GL_TEXTURE_2D,Texname)								' Select Our Texture
	
		For loops=0 To MAX_PARTICLES-1										' Initials All The Textures
			particle=particle:particles[..loops+1]
			particle[loops]=New particles
			particle[loops].active=True										' Make All The Particles Active
			particle[loops].life=1.0										' Give All The Particles Full Life
			particle[loops].fade=Float(Rand(100) Mod 100)/1000.0+0.003			' Random Fade Speed
			Local index:Int=Int(Float(loops)*(12.0/Float(MAX_PARTICLES)))
			particle[loops].r=colors[index,0]								' Select Red Rainbow Color
			particle[loops].g=colors[index,1]								' Select Red Rainbow Color
			particle[loops].b=colors[index,2]								' Select Red Rainbow Color
			particle[loops].xi=Float((Rand(1000) Mod 50)-26.0)*10.0			' Random Speed On X Axis
			particle[loops].yi=Float((Rand(1000) Mod 50)-25.0)*10.0			' Random Speed On Y Axis
			particle[loops].zi=Float((Rand(1000) Mod 50)-25.0)*10.0			' Random Speed On Z Axis
			particle[loops].xg=0.0											' Set Horizontal Pull To Zero
			particle[loops].yg=-0.8											' Set Vertical Pull Downward
			particle[loops].zg=0.0											' Set Pull On Z Axis To Zero
		Next
	
		glViewport(0,0,ScreenWidth,ScreenHeight)							' Set viewport
		glMatrixMode(GL_PROJECTION)										' Select The Projection Matrix
		glLoadIdentity()													' Reset The Projection Matrix
		gluPerspective(45.0,Float(ScreenWidth)/Float(ScreenHeight),0.1,100.0)	' Calculate The Aspect Ratio Of The Window
		glMatrixMode(GL_MODELVIEW)											' Select The Modelview Matrix
		glLoadIdentity()
	End Method
	
	Method LoadGlTextures()
		Local TextureImage:TPixmap
		TextureImage:TPixmap=LoadPixmap("Data/Particle.bmp")					' Load Particle Texture
		glGenTextures(1, Varptr Texname)									' Create One Texture
		glBindTexture(GL_TEXTURE_2D, Texname)
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
		glTexImage2D(GL_TEXTURE_2D, 0, 3, TextureImage.width, TextureImage.height, 0, GL_RGB, GL_UNSIGNED_BYTE, TextureImage.pixels)
	End Method
	
	Method loop()
		Local x:Float
		Local y:Float
		Local z:Float
	
		If (KeyDown(KEY_NUMADD)) And (slowdown>1.0) Then slowdown:-0.01			' Speed Up Particles
		If (KeyDown(KEY_NUMSUBTRACT)) And (slowdown<4.0) Then slowdown:+0.01		' Slow Down Particles
	
		If KeyDown(KEY_PAGEUP) Then zoom:+0.1									' Zoom In
		If KeyDown(KEY_PAGEDOWN) Then zoom:-0.1									' Zoom Out
	
		If KeyHit(KEY_RETURN) Then												' Return Key Pressed
			rainbow=Not rainbow												' Toggle Rainbow Mode On / Off
		EndIf
		If (KeyHit(KEY_SPACE)) Or (rainbow And (pause>25)) Then					' Space Or Rainbow Mode
			If KeyHit(KEY_SPACE) Then	rainbow=False								' If Spacebar Is Pressed Disable Rainbow Mode
			pause=0															' Reset The Rainbow Color Cycling Delay
			col:+1															' Change The Particle Color
			If col>11 Then col=0												' If Color Is To High Reset It
		EndIf
		' If Up Arrow And Y Speed Is Less Than 200 Increase Upward Speed
		If (KeyDown(KEY_UP)) And (yspeed<200.0) Then yspeed:+1.0
		' If Down Arrow And Y Speed Is Greater Than -200 Increase Downward Speed
		If (KeyDown(KEY_DOWN)) And (yspeed>-200.0) Then yspeed:-1.0
		' If Right Arrow And X Speed Is Less Than 200 Increase Speed To The Right
		If (KeyDown(KEY_RIGHT)) And (xspeed<200.0) Then xspeed:+1.0
		' If Left Arrow And X Speed Is Greater Than -200 Increase Speed To The Left
		If (KeyDown(KEY_LEFT)) And (xspeed>-200.0) Then xspeed:-1.0
		pause:+1																' Increase Rainbow Mode Color Cycling Delay Counter
	
'		If KeyHit(KEY_S) Then SaveBmp("Toto.bmp")
		
		
		glClear GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT						' Clear The Screen And The Depth Buffer
		glLoadIdentity()														' Reset The Current Modelview Matrix
			
		For loops=0 To MAX_PARTICLES-1											' Loop Through All The Particles
			If particle[loops].active Then 										' If The Particle Is Active
				x=particle[loops].x											' Grab Our Particle X Position
				y=particle[loops].y											' Grab Our Particle Y Position
				z=particle[loops].z+zoom										' Particle Z Pos + Zoom
				
				' Draw The Particle Using Our RGB Values, Fade The Particle Based On It's Life
				glColor4f(particle[loops].r,particle[loops].g,particle[loops].b,particle[loops].life)
				
				glBegin(GL_TRIANGLE_STRIP)										' Build Quad From A Triangle Strip
					glTexCoord2d(1,1); glVertex3f(x+0.5,y+0.5,z)					' Top Right
					glTexCoord2d(0,1); glVertex3f(x-0.5,y+0.5,z)					' Top Left
					glTexCoord2d(1,0); glVertex3f(x+0.5,y-0.5,z)					' Bottom Right
					glTexCoord2d(0,0); glVertex3f(x-0.5,y-0.5,z)					' Bottom Left
				glEnd()														' Done Building Triangle Strip
	
				particle[loops].x:+particle[loops].xi/(slowdown*1000.0)				' Move On The X Axis By X Speed
				particle[loops].y:+particle[loops].yi/(slowdown*1000.0)				' Move On The Y Axis By Y Speed
				particle[loops].z:+particle[loops].zi/(slowdown*1000.0)				' Move On The Z Axis By Z Speed
	
				particle[loops].xi:+particle[loops].xg							' Take Pull On X Axis Into Account
				particle[loops].yi:+particle[loops].yg							' Take Pull On Y Axis Into Account
				particle[loops].zi:+particle[loops].zg							' Take Pull On Z Axis Into Account
				particle[loops].life:-particle[loops].fade						' Reduce Particles Life By 'Fade'
	
				If particle[loops].life<0.0 Then									' If Particle Is Burned Out
					particle[loops].life=1.0									' Give It New Life
					particle[loops].fade=Float(Rand(1000) Mod 100)/1000.0+0.003	' Random Fade Value
					particle[loops].x=0.0										' Center On X Axis
					particle[loops].y=0.0										' Center On Y Axis
					particle[loops].z=0.0										' Center On Z Axis
					particle[loops].xi=xspeed+Float(Rand(1000) Mod 60)-32.0		' X Axis Speed And Direction
					particle[loops].yi=yspeed+Float(Rand(1000) Mod 60)-30.0		' Y Axis Speed And Direction
					particle[loops].zi=Float(Rand(1000) Mod 60)-30.0				' Z Axis Speed And Direction
					particle[loops].r=colors[col,0]								' Select Red From Color Table
					particle[loops].g=colors[col,1]								' Select Green From Color Table
					particle[loops].b=colors[col,2]								' Select Blue From Color Table
				EndIf
				
				' If Number Pad 8 And Y Gravity Is Less Than 1.5 Increase Pull Upwards
				If (KeyDown(KEY_NUM8)) And (particle[loops].yg<1.5) Then particle[loops].yg:+0.01
				' If Number Pad 2 And Y Gravity Is Greater Than -1.5 Increase Pull Downwards
				If (KeyDown(Key_NUM2)) And (particle[loops].yg>-1.5) Then particle[loops].yg:-0.01
				' If Number Pad 6 And X Gravity Is Less Than 1.5 Increase Pull Right
				If (KeyDown(KEY_NUM6)) And (particle[loops].xg<1.5) Then particle[loops].xg:+0.01
				' If Number Pad 4 And X Gravity Is Greater Than -1.5 Increase Pull Left
				If (KeyDown(KEY_NUM4)) And (particle[loops].xg>-1.5) Then particle[loops].xg:-0.01
	
				If KeyDown(KEY_TAB) Then										' Tab Key Causes A Burst
					particle[loops].x=0.0										' Center On X Axis
					particle[loops].y=0.0										' Center On Y Axis
					particle[loops].z=0.0										' Center On Z Axis
					particle[loops].xi=Float((Rand(1000) Mod 50)-26.0)*10.0		' Random Speed On X Axis
					particle[loops].yi=Float((Rand(1000) Mod 50)-25.0)*10.0		' Random Speed On Y Axis
					particle[loops].zi=Float((Rand(1000) Mod 50)-25.0)*10.0		' Random Speed On Z Axis
				EndIf
			EndIf
	    Next
		glDisable(GL_TEXTURE_2D)	
		glColor3f(1.0,1.0,1.0)
		'--------------------------------------------------------
		GLDrawText("NeHe's Particle Tutorial (lesson 19)",10,24)
		
		GLDrawText("Pad -     Speed up",10,56)
		GLDrawText("Pad +     Speed down",10,72)
		GLDrawText("PAGEUP    Zoom in",10,88)
		GLDrawText("PAGEDOWN  Zoom out",10,104)
		GLDrawText("RETURN    Rainbow On/Off",10,120)
		GLDrawText("SPACE     Change color",10,136)
		GLDrawText("UP        Y speed +",10,152)
		GLDrawText("DOWN      Y speed -",10,168)
		GLDrawText("RIGHT     X speed +",10,184)
		GLDrawText("LEFT      X speed -",10,200)
		GLDrawText("Pad 8     Y gravity -",10,216)
		GLDrawText("Pad 2     Y gravity +",10,232)
		GLDrawText("Pad 6     X gravity -",10,248)
		GLDrawText("Pad 4     X gravity +",10,264)	
		
		glEnable(GL_TEXTURE_2D)
	End Method
End Type







