Strict

Import "framework.bmx"

New TNeHe22.Run(22,"Bump Mapping")

Type TNeHe22 Extends TNeHe
	Const MAX_EMBOSS:Float=0.01						' Maximum Emboss-Translate. Increase To Get Higher Immersion
													' At A Cost Of Lower Quality (More Artifacts Will Occur!)
	' Here Comes The ARB-Multitexture Support.
	' There Are (Optimally) 6 New Commands To The OpenGL Set:
	' glMultiTexCoordifARB i=1..4	: Sets Texture-Coordinates For Texel-Pipeline #i
	' glActiveTextureARB			: Sets Active Texel-Pipeline
	' glClientActiveTextureARB	: Sets Active Texel-Pipeline For The Pointer-Array-Commands
	'
	'There Are Even More For The Various Formats Of glMultiTexCoordi{f,fv,d,i}, But We Don't Need Them.
	
	Field __ARB_ENABLE=True							' Used To Disable ARB Extensions Entirely
	Field EXT_INFO=False								' Do You Want To See Your Extensions At Start-Up?
	
	Const MAX_EXTENSION_SPACE=10240						' Characters For Extension-Strings
	Const MAX_EXTENSION_LENGTH=256						' Maximum Of Characters In One Extension-String
	Field multitextureSupported:Byte=True				' Flag Indicating Whether Multitexturing Is Supported
	Field useMultitexture:Byte=True					' Use It If It Is Supported?
	Field maxTexelUnits:Int=1							' Number Of Texel-Pipelines. This Is At Least 1.
	
	Field emboss:Byte=False							' Emboss Only, No Basetexture?
	Field bumps:Byte=True								' Do Bumpmapping?
	
	Field xrot:Float									' X Rotation
	Field yrot:Float									' Y Rotation
	Field xspeed:Float								' X Rotation Speed
	Field yspeed:Float								' Y Rotation Speed
	Field z:Float=-5.0								' Depth Into The Screen
	
	Field filter:Int=1								' Which Filter To Use
	Field texture:Int[3]								' Storage For 3 Textures
	Field bump:Int[3]								' Our Bumpmappings
	Field invbump:Int[3]								' Inverted Bumpmaps
	Field glLogo:Int									' Handle For OpenGL-Logo
	Field multiLogo:Int								' Handle For Multitexture-Enabled-Logo
	
	Field LightAmbient:Float[]=[0.2, 0.2, 0.2]			' Ambient Light is 20% white
	Field LightDiffuse:Float[]=[1.0, 1.0, 1.0]			' Diffuse Light is white
	Field LightPosition:Float[]=[0.0, 0.0, 2.0]			' Position is somewhat in front of screen
	
	Field Gray:Float[]=[0.5,0.5,0.5,1.0]
	
	' Data Contains The Faces For The Cube In Format 2xTexCoord, 3xVertex;
	' Note That The Tesselation Of The Cube Is Only Absolute Minimum.
	
	Field data:Float[]=	[0.0, 0.0,	-1.0, -1.0, +1.0,..
						 1.0, 0.0,	+1.0, -1.0, +1.0,..
						 1.0, 1.0,	+1.0, +1.0, +1.0,..
						 0.0, 1.0,	-1.0, +1.0, +1.0,..
						 1.0, 0.0,	-1.0, -1.0, -1.0,..
						 1.0, 1.0,	-1.0, +1.0, -1.0,..
						 0.0, 1.0,	+1.0, +1.0, -1.0,..
						 0.0, 0.0,	+1.0, -1.0, -1.0,..
						 0.0, 1.0,	-1.0, +1.0, -1.0,..
						 0.0, 0.0,	-1.0, +1.0, +1.0,..
						 1.0, 0.0,	+1.0, +1.0, +1.0,..
						 1.0, 1.0,	+1.0, +1.0, -1.0,..
						 1.0, 1.0,	-1.0, -1.0, -1.0,..
						 0.0, 1.0,	+1.0, -1.0, -1.0,..
						 0.0, 0.0,	+1.0, -1.0, +1.0,..
						 1.0, 0.0,	-1.0, -1.0, +1.0,..
						 1.0, 0.0,	+1.0, -1.0, -1.0,..
						 1.0, 1.0,	+1.0, +1.0, -1.0,..
						 0.0, 1.0,	+1.0, +1.0, +1.0,..
						 0.0, 0.0,	+1.0, -1.0, +1.0,..
						 0.0, 0.0,	-1.0, -1.0, -1.0,..
						 1.0, 0.0,	-1.0, -1.0,  1.0,..
						 1.0, 1.0,	-1.0,  1.0,  1.0,..
						 0.0, 1.0,	-1.0,  1.0, -1.0]
	
	Method Init()
		glewInit()
		multitextureSupported=initMultitexture()
	
		LoadGlTextures()
		glEnable(GL_TEXTURE_2D)											' Enable Texture Mapping
		glShadeModel(GL_SMOOTH)											' Enable Smooth Shading
		glClearColor(0.0,0.0,0.0,0.5)										' Black Background
		glClearDepth(1.0)													' Depth Buffer Setup
		glEnable(GL_DEPTH_TEST)											' Enables Depth Testing
		glDepthFunc(GL_LEQUAL)												' The Type Of Depth Testing To Do
		glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST)					' Really Nice Perspective Calculations
		initLights()														' Initialize OpenGL Light	
	
		glViewport(0,0,ScreenWidth,ScreenHeight)							' Set viewport
		glMatrixMode(GL_PROJECTION)										' Select The Projection Matrix
		glLoadIdentity()													' Reset The Projection Matrix
		gluPerspective(45.0,Float(ScreenWidth)/Float(ScreenHeight),0.5,100.0)	' Calculate The Aspect Ratio Of The Window
		glMatrixMode(GL_MODELVIEW)											' Select The Modelview Matrix
		glLoadIdentity()
	End Method
	
	' isMultitextureSupported() Checks At Run-Time If Multitexturing Is Supported
	Method initMultitexture()
		Local extensions:String	
	
	'	extensions= String(glGetString(GL_EXTENSIONS))							' Fetch Extension String
	'	If EXT_INFO And extensions Then
	'		Notify("Supported GL extensions")
	'	EndIf
	
		If (extensions.Find("GL_ARB_multitexture")) And (__ARB_ENABLE) And (extensions.Find("GL_EXT_texture_env_combine")) Then
			glGetIntegerv(GL_MAX_TEXTURE_UNITS_ARB,Varptr maxTexelUnits)
			If EXT_INFO Then
				Notify("The GL_ARB_multitexture extension will be used."+Chr(13)+Chr(9)+"Feature supported!")
			EndIf
			Return True
		Else
			useMultitexture=False										' We Can't Use It If It Isn't Supported!
		Return False
		EndIf
	End Method
	
	Method Loop()
		
		If KeyHit(KEY_E) Then
			emboss=Not emboss
		EndIf
		If KeyHit(KEY_M) Then
			useMultitexture=((Not useMultitexture) And multitextureSupported)
		EndIf				
		If KeyHit(KEY_B) Then
			bumps=Not bumps
		EndIf			
		If KeyHit(KEY_F) Then
			filter:+1
			filter:Mod 3
		EndIf			
		If KeyDown(KEY_PAGEUP) Then
			z:-0.02
		EndIf
		If KeyDown(KEY_PAGEDOWN) Then
			z:+0.02
		EndIf
		If KeyDown(KEY_UP) Then
			xspeed:-0.01
		EndIf
		If KeyDown(KEY_DOWN) Then
			xspeed:+0.01
		EndIf
		If KeyDown(KEY_RIGHT) Then
			yspeed:+0.01
		EndIf
		If KeyDown(KEY_LEFT) Then
			yspeed:-0.01
		EndIf
		
		If bumps Then
			If (useMultitexture) And (maxTexelUnits>1) Then
				doMesh2TexelUnits()
			Else
				doMesh1TexelUnits()
			EndIf
		Else
			doMeshNoBumps()
		EndIf
		glDisable(GL_TEXTURE_2D)	
		glDisable(GL_DEPTH_TEST)	
		glDisable(GL_LIGHT1)
		glDisable(GL_LIGHTING)
		glColor3f(1.0,1.0,1.0)
	
		'--------------------------------------------------------
		GLDrawText("NeHe's GL_ARB_multitexture & Bump Mapping Tutorial (lesson 22)",10,24)
		GLDrawText("'F' Texture filter",10,56)
		GLDrawText("'B' Bump          ",10,72)
		GLDrawText("'M' Multitexturing",10,88)
		GLDrawText("'E' Emboss        ",10,104)
		glEnable(GL_TEXTURE_2D	)
		glEnable(GL_DEPTH_TEST)	
		glEnable(GL_LIGHT1)
		glEnable(GL_LIGHTING)
	
	End Method
	
	Method initLights()
		glLightfv( GL_LIGHT1, GL_AMBIENT, LightAmbient)					' Load Light-Parameters Into GL_LIGHT1
		glLightfv( GL_LIGHT1, GL_DIFFUSE, LightDiffuse)	
		glLightfv( GL_LIGHT1, GL_POSITION, LightPosition)
		glEnable(GL_LIGHT1)	
	End Method
	
	Method LoadGLTextures()											' Load Bitmaps And Convert To Textures
		Local alpha:String
		Local TextureImage:TPixmap
		Local TextureImage2:TPixmap
		Local AlphaImage:TPixmap
		Local x:Int
		Local y:Int
		Local PixSource:Byte Ptr
		Local PixSource2:Byte Ptr
		Local PixDest:Byte Ptr
	
		' Load The Tile-Bitmap For Base-Texture
		TextureImage:TPixmap=LoadPixmap("data\Base.bmp")
		glGenTextures(3, Varptr texture[0])								' Create Three Textures
		' Create Nearest Filtered Texture
		glBindTexture(GL_TEXTURE_2D, texture[0])
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_NEAREST)
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST)
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB8, TextureImage.width, TextureImage.height, 0, GL_RGB, GL_UNSIGNED_BYTE, TextureImage.pixels)
		' ========
		' Use GL_RGB8 Instead Of "3" In glTexImage2D. Also Defined By GL: GL_RGBA8 Etc.
		' New: Now Creating GL_RGBA8 Textures, Alpha Is 1.0f Where Not Specified By Format.
		' Create Linear Filtered Texture
		glBindTexture(GL_TEXTURE_2D, texture[1])
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR)
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR)
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB8, TextureImage.width, TextureImage.height, 0, GL_RGB, GL_UNSIGNED_BYTE, TextureImage.pixels)
		' Create MipMapped Texture
		glBindTexture(GL_TEXTURE_2D, texture[2])
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR)
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR_MIPMAP_NEAREST)
		gluBuild2DMipmaps(GL_TEXTURE_2D, GL_RGB8, TextureImage.width, TextureImage.height, GL_RGB, GL_UNSIGNED_BYTE, TextureImage.pixels)
		
		' Load The Bumpmaps
		TextureImage:TPixmap=LoadPixmap("data\Bump.bmp")
		glPixelTransferf(GL_RED_SCALE,0.5)								' Scale RGB By 50%, So That We Have Only			
		glPixelTransferf(GL_GREEN_SCALE,0.5)							' Half Intenstity
		glPixelTransferf(GL_BLUE_SCALE,0.5)
	
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_CLAMP)			' No Wrapping, Please!
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_CLAMP)
		glTexParameterfv(GL_TEXTURE_2D,GL_TEXTURE_BORDER_COLOR,Gray)
	
		glGenTextures(3, Varptr bump[0])								' Create Three Textures
		' Create Nearest Filtered Texture
		glBindTexture(GL_TEXTURE_2D, bump[0])
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_NEAREST)
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST)
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB8, TextureImage.width, TextureImage.height, 0, GL_RGB, GL_UNSIGNED_BYTE, TextureImage.pixels)
		' Create Linear Filtered Texture
		glBindTexture(GL_TEXTURE_2D, bump[1])
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR)
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR)
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB8, TextureImage.width, TextureImage.height, 0, GL_RGB, GL_UNSIGNED_BYTE, TextureImage.pixels)
		' Create MipMapped Texture
		glBindTexture(GL_TEXTURE_2D, bump[2])
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR)
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR_MIPMAP_NEAREST)
		gluBuild2DMipmaps(GL_TEXTURE_2D, GL_RGB8, TextureImage.width, TextureImage.height, GL_RGB, GL_UNSIGNED_BYTE, TextureImage.pixels)
		
		For y=0 Until TextureImage.height								' Invert The Bumpmap
			PixSource=TextureImage.PixelPtr(0,y)
			For x=0 Until TextureImage.width
				PixSource[0]=255-PixSource[0]
				PixSource[1]=255-PixSource[1]
				PixSource[2]=255-PixSource[2]
				PixSource:+3
			Next
		Next
	
		glGenTextures(3, Varptr invbump[0])								' Create Three Textures
		' Create Nearest Filtered Texture
		glBindTexture(GL_TEXTURE_2D, invbump[0])
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_NEAREST)
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST)
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB8, TextureImage.width, TextureImage.height, 0, GL_RGB, GL_UNSIGNED_BYTE, TextureImage.pixels)
		' Create Linear Filtered Texture
		glBindTexture(GL_TEXTURE_2D, invbump[1])
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB8, TextureImage.width, TextureImage.height, 0, GL_RGB, GL_UNSIGNED_BYTE, TextureImage.pixels)
		' Create MipMapped Texture
		glBindTexture(GL_TEXTURE_2D, invbump[2])
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR)
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR_MIPMAP_NEAREST)
		gluBuild2DMipmaps(GL_TEXTURE_2D, GL_RGB8, TextureImage.width, TextureImage.height, GL_RGB, GL_UNSIGNED_BYTE, TextureImage.pixels)
			
		glPixelTransferf(GL_RED_SCALE,1.0)									' Scale RGB Back To 100% Again		
		glPixelTransferf(GL_GREEN_SCALE,1.0)			
		glPixelTransferf(GL_BLUE_SCALE,1.0)
	
		' Load The Logo-Bitmaps
		TextureImage:TPixmap=LoadPixmap("data\OpenGL_Alpha.bmp")
		TextureImage2:TPixmap=LoadPixmap("data\OpenGL.bmp")
		TextureImage=YFlipPixmap(TextureImage)								' Flip image verticaly
		TextureImage2=YFlipPixmap(TextureImage2)							' Flip image verticaly
		' Create AlphaImage For RGBA8-Texture
		AlphaImage:TPixmap=CreatePixmap(TextureImage.width,TextureImage.height,PF_RGBA8888) 'PixmapFormat(TextureImage))
		For y=0 Until TextureImage.height
			PixSource=TextureImage.PixelPtr(0,y)
			PixSource2=TextureImage2.PixelPtr(0,y)
			PixDest=AlphaImage.PixelPtr(0,y)
			For x=0 Until TextureImage.width
				PixDest[0]=PixSource2[0]									' Copy Red value of source2
				PixDest[1]=PixSource2[1]									' Copy Green value of source2
				PixDest[2]=PixSource2[2]									' Copy Blue value of source2
				PixDest[3]=PixSource[0]									' Pick Only Red Value As Alpha of source
				PixSource:+3
				PixSource2:+3
				PixDest:+4
			Next
		Next
		glGenTextures(1, Varptr glLogo)										' Create One Textures
		' Create Linear Filtered RGBA8-Texture
		glBindTexture(GL_TEXTURE_2D, glLogo)
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR)
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR)
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8, TextureImage.width, TextureImage.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, AlphaImage.pixels)
	
		' Load The "Extension Enabled"-Logo
		TextureImage:TPixmap=LoadPixmap("data\multi_on_alpha.bmp")
		TextureImage2:TPixmap=LoadPixmap("data\multi_on.bmp")
		TextureImage=YFlipPixmap(TextureImage)								' Flip image verticaly
		TextureImage2=YFlipPixmap(TextureImage2)							' Flip image verticaly
		' Create AlphaImage For RGBA8-Texture
		AlphaImage:TPixmap=CreatePixmap(TextureImage.width,TextureImage.height,PF_RGBA8888) 'PixmapFormat(TextureImage))
		For y=0 Until AlphaImage.height	
			PixSource=TextureImage.PixelPtr(0,y)
			PixSource2=TextureImage2.PixelPtr(0,y)
			PixDest=AlphaImage.PixelPtr(0,y)
			For x=0 Until AlphaImage.width
				PixDest[0]=PixSource2[0]									' Copy Red value of source2
				PixDest[1]=PixSource2[1]									' Copy Green value of source2
				PixDest[2]=PixSource2[2]									' Copy Blue value of source2
				PixDest[3]=PixSource[0]									' Pick Only Red Value As Alpha of source
				PixSource:+3
				PixSource2:+3
				PixDest:+4
			Next
		Next
		glGenTextures(1, Varptr multiLogo)									' Create One Textures
		' Create Linear Filtered RGBA8-Texture
		glBindTexture(GL_TEXTURE_2D, multiLogo)
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR)
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR)
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8, TextureImage.width, TextureImage.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, AlphaImage.pixels)
	End Method
	
	Method doCube()
		Local i:Int
		glBegin(GL_QUADS);
			' Front Face
			glNormal3f( 0.0, 0.0, +1.0)
			For i=0 To 3
				glTexCoord2f(data[5*i],data[5*i+1])
				glVertex3f(data[5*i+2],data[5*i+3],data[5*i+4])
			Next
			' Back Face
			glNormal3f( 0.0, 0.0,-1.0)
			For i=4 To 7
				glTexCoord2f(data[5*i],data[5*i+1])
				glVertex3f(data[5*i+2],data[5*i+3],data[5*i+4])
			Next
			' Top Face
			glNormal3f( 0.0, 1.0, 0.0)
			For i=8 To 11
				glTexCoord2f(data[5*i],data[5*i+1])
				glVertex3f(data[5*i+2],data[5*i+3],data[5*i+4])
			Next
			' Bottom Face
			glNormal3f( 0.0,-1.0, 0.0)
			For i=12 To 15
				glTexCoord2f(data[5*i],data[5*i+1])
				glVertex3f(data[5*i+2],data[5*i+3],data[5*i+4])
			Next
			' Right face
			glNormal3f( 1.0, 0.0, 0.0)
			For i=16 To 19
				glTexCoord2f(data[5*i],data[5*i+1])
				glVertex3f(data[5*i+2],data[5*i+3],data[5*i+4])
			Next
			' Left Face
			glNormal3f(-1.0, 0.0, 0.0)
			For i=20 To 23
				glTexCoord2f(data[5*i],data[5*i+1])
				glVertex3f(data[5*i+2],data[5*i+3],data[5*i+4])
			Next
		glEnd()
	End Method
	
	' Calculates v=vM, M Is 4x4 In Column-Major, v Is 4dim. Row (i.e. "Transposed")
	Method VMatMult(M:Float Ptr, v:Float Ptr)
		Local res:Float[3]
		res[0]=M[ 0]*v[0]+M[ 1]*v[1]+M[ 2]*v[2]+M[ 3]*v[3]
		res[1]=M[ 4]*v[0]+M[ 5]*v[1]+M[ 6]*v[2]+M[ 7]*v[3]
		res[2]=M[ 8]*v[0]+M[ 9]*v[1]+M[10]*v[2]+M[11]*v[3]
		v[0]=res[0]
		v[1]=res[1]
		v[2]=res[2]
		v[3]=M[15]													' Homogenous Coordinate
	End Method
	
	Rem
	Okay, Here Comes The Important Stuff:
	
	On http://www.nvidia.com/marketing/Developer/DevRel.nsf/TechnicalDemosFrame?OpenPage
	You Can Find A Demo Called GL_BUMP That Is A Little Bit More Complicated.
	GL_BUMP:   Copyright Diego Tártara, 1999.			
		-  diego_tartara@ciudad.com.ar  -
	
	The Idea Behind GL_BUMP Is, That You Compute The Texture-Coordinate Offset As Follows:
		0) All Coordinates Either In Object Or In World Space.
		1) Calculate Vertex v From Actual Position (The Vertex You're At) To The Lightposition
		2) Normalize v
		3) Project This v Into Tangent Space.
			Tangent Space Is The Plane "Touching" The Object In Our Current Position On It.
			Typically, If You're Working With Flat Surfaces, This Is The Surface Itself.
		4) Offset s,t-Texture-Coordinates By The Projected v's x And y-Component.
	
	* This Would Be Called Once Per Vertex In Our Geometry, If Done Correctly.
	* This Might Lead To Incoherencies In Our Texture Coordinates, But Is Ok As Long As You Did Not
	* Wrap The Bumpmap.
			
	Basically, We Do It The Same Way With Some Exceptions:
		ad 0) We'll Work In Object Space All Time. This Has The Advantage That We'll Only
		      Have To Transform The Lightposition From Frame To Frame. This Position Obviously
			  Has To Be Transformed Using The Inversion Of The Modelview Matrix. This Is, However,
			  A Considerable Drawback, If You Don't Know How Your Modelview Matrix Was Built, Since
			  Inverting A Matrix Is Costly And Complicated.
		ad 1) Do It Exactly That Way.
		ad 2) Do It Exactly That Way.
		ad 3) To Project The Lightvector Into Tangent Space, We'll Support The Setup-Routine
			  With Two Directions: One Of Increasing s-Texture-Coordinate Axis, The Other In
			  Increasing t-Texture-Coordinate Axis. The Projection Simply Is (Assumed Both
			  texCoord Vectors And The Lightvector Are Normalized) The Dotproduct Between The
			  Respective texCoord Vector And The Lightvector. 
		ad 4) The Offset Is Computed By Taking The Result Of Step 3 And Multiplying The Two
			  Numbers With MAX_EMBOSS, A Constant That Specifies How Much Quality We're Willing To
			  Trade For Stronger Bump-Effects. Just Temper A Little Bit With MAX_EMBOSS!
	
	WHY THIS IS COOL:
		* Have A Look!
		* Very Cheap To Implement (About One Squareroot And A Couple Of MULs)!
		* Can Even Be Further Optimized!
		* SetUpBump Doesn't Disturb glBegin()/glEnd()
		* THIS DOES ALWAYS WORK - Not Only With XY-Tangent Spaces!!
	
	DRAWBACKS:
		* Must Know "Structure" Of Modelview-Matrix Or Invert It. Possible To Do The Whole Thing
		* In World Space, But This Involves One Transformation For Each Vertex!
	End Rem
	
	Method SetUpBumps(n:Float Ptr, c:Float Ptr, l:Float Ptr, s:Float Ptr, t:Float Ptr)
		Local v:Float[3]											' Vertex From Current Position To Light	
		Local lenQ:Float											' Used To Normalize		
			
		' Calculate v From Current Vector c To Lightposition And Normalize v	
		v[0]=l[0]-c[0]	
		v[1]=l[1]-c[1]		
		v[2]=l[2]-c[2]		
		lenQ=Float(Sqr(v[0]*v[0]+v[1]*v[1]+v[2]*v[2]))
		v[0]:/lenQ;		v[1]:/lenQ;		v[2]:/lenQ
		' Project v Such That We Get Two Values Along Each Texture-Coordinat Axis.
		c[0]=(s[0]*v[0]+s[1]*v[1]+s[2]*v[2])*MAX_EMBOSS
		c[1]=(t[0]*v[0]+t[1]*v[1]+t[2]*v[2])*MAX_EMBOSS
	End Method
	
	Method doLogo()												' MUST CALL THIS LAST!!!, Billboards The Two Logos.
		glDepthFunc(GL_ALWAYS)		
		glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA)
		glEnable(GL_BLEND)
		glDisable(GL_LIGHTING)
		glLoadIdentity();
		glBindTexture(GL_TEXTURE_2D,glLogo)
		glBegin(GL_QUADS)
			glTexCoord2f(0.0,0.0);		glVertex3f(0.23, -0.4,-1.0)
			glTexCoord2f(1.0,0.0);		glVertex3f(0.53, -0.4,-1.0)
			glTexCoord2f(1.0,1.0);		glVertex3f(0.53, -0.25,-1.0)
			glTexCoord2f(0.0,1.0);		glVertex3f(0.23, -0.25,-1.0)
		glEnd()		
		If (useMultitexture) Then
			glBindTexture(GL_TEXTURE_2D,multiLogo)
			glBegin(GL_QUADS)
				glTexCoord2f(0.0,0.0);		glVertex3f(-0.53, -0.4,-1.0)
				glTexCoord2f(1.0,0.0);		glVertex3f(-0.33, -0.4,-1.0)
				glTexCoord2f(1.0,1.0);		glVertex3f(-0.33, -0.3,-1.0)
				glTexCoord2f(0.0,1.0);		glVertex3f(-0.53, -0.3,-1.0)
			glEnd()	
		EndIf
		glDepthFunc(GL_LEQUAL)
	End Method
	
	Method doMesh1TexelUnits()
		Local c:Float[]=[0.0,0.0,0.0,1.0]							' Holds Current Vertex
		Local n:Float[]=[0.0,0.0,0.0,1.0]							' Normalized Normal Of Current Surface		
		Local s:Float[]=[0.0,0.0,0.0,1.0]							' s-Texture Coordinate Direction, Normalized
		Local t:Float[]=[0.0,0.0,0.0,1.0]							' t-Texture Coordinate Direction, Normalized
		Local l:Float[4]											' Holds Our Lightposition To Be Transformed Into Object Space
		Local Minv:Float[16]										' Holds The Inverted Modelview Matrix To Do So.
		Local i:Int								
	
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)			' Clear The Screen And The Depth Buffer
			
		' Build Inverse Modelview Matrix First. This Substitutes One Push/Pop With One glLoadIdentity();
		' Simply Build It By Doing All Transformations Negated And In Reverse Order.
		glLoadIdentity()							
		glRotatef(-yrot,0.0,1.0,0.0)
		glRotatef(-xrot,1.0,0.0,0.0)
		glTranslatef(0.0,0.0,-z)
		glGetFloatv(GL_MODELVIEW_MATRIX,Minv)
		glLoadIdentity()
		glTranslatef(0.0,0.0,z)
	
		glRotatef(xrot,1.0,0.0,0.0)
		glRotatef(yrot,0.0,1.0,0.0)	
		
		' Transform The Lightposition Into Object Coordinates:
		l[0]=LightPosition[0]
		l[1]=LightPosition[1]
		l[2]=LightPosition[2]
		l[3]=1.0													' Homogenous Coordinate
		VMatMult(Varptr Minv[0], Varptr l[0])
		
		Rem
		PASS#1:
		Use Texture "Bump"
		No Blend
		No Lighting
		No Offset Texture-Coordinates
		End Rem
		glBindTexture(GL_TEXTURE_2D, bump[filter])
		glDisable(GL_BLEND)
		glDisable(GL_LIGHTING)
		doCube()
	
		Rem 
		PASS#2:
		Use Texture "Invbump"
		Blend GL_ONE To GL_ONE
		No Lighting
		Offset Texture Coordinates 
		End Rem
		glBindTexture(GL_TEXTURE_2D,invbump[filter])
		glBlendFunc(GL_ONE,GL_ONE)
		glDepthFunc(GL_LEQUAL)
		glEnable(GL_BLEND)	
	
		glBegin(GL_QUADS)	
			' Front Face	
			n[0]=0.0;		n[1]=0.0;		n[2]=1.0			
			s[0]=1.0;		s[1]=0.0;		s[2]=0.0
			t[0]=0.0;		t[1]=1.0;		t[2]=0.0
			For i=0 To 3	
				c[0]=data[5*i+2]
				c[1]=data[5*i+3]
				c[2]=data[5*i+4]
				SetUpBumps(Varptr n[0], Varptr c[0], Varptr l[0], Varptr s[0], Varptr t[0])
				glTexCoord2f(data[5*i]+c[0], data[5*i+1]+c[1])
				glVertex3f(data[5*i+2], data[5*i+3], data[5*i+4])
			Next
			' Back Face	
			n[0]=0.0;		n[1]=0.0;		n[2]=-1.0
			s[0]=-1.0;		s[1]=0.0;		s[2]=0.0
			t[0]=0.0;		t[1]=1.0;		t[2]=0.0
			For i=4 To 7	
				c[0]=data[5*i+2]
				c[1]=data[5*i+3]
				c[2]=data[5*i+4]
				SetUpBumps(Varptr n[0], Varptr c[0], Varptr l[0], Varptr s[0], Varptr t[0])
				glTexCoord2f(data[5*i]+c[0], data[5*i+1]+c[1])
				glVertex3f(data[5*i+2], data[5*i+3], data[5*i+4])
			Next
			' Top Face	
			n[0]=0.0;		n[1]=1.0;		n[2]=0.0		
			s[0]=1.0;		s[1]=0.0;		s[2]=0.0
			t[0]=0.0;		t[1]=0.0;		t[2]=-1.0
			For i=8 To 11	
				c[0]=data[5*i+2]	
				c[1]=data[5*i+3]
				c[2]=data[5*i+4]
				SetUpBumps(Varptr n[0], Varptr c[0], Varptr l[0], Varptr s[0], Varptr t[0])
				glTexCoord2f(data[5*i]+c[0], data[5*i+1]+c[1])
				glVertex3f(data[5*i+2], data[5*i+3], data[5*i+4])
			Next
			' Bottom Face
			n[0]=0.0;		n[1]=-1.0;		n[2]=0.0		
			s[0]=-1.0;		s[1]=0.0;		s[2]=0.0
			t[0]=0.0;		t[1]=0.0;		t[2]=-1.0
			For i=12 To 15	
				c[0]=data[5*i+2]	
				c[1]=data[5*i+3]
				c[2]=data[5*i+4]
				SetUpBumps(Varptr n[0], Varptr c[0], Varptr l[0], Varptr s[0], Varptr t[0])
				glTexCoord2f(data[5*i]+c[0], data[5*i+1]+c[1])
				glVertex3f(data[5*i+2], data[5*i+3], data[5*i+4])
			Next
			' Right Face	
			n[0]=1.0;		n[1]=0.0;		n[2]=0.0		
			s[0]=0.0;		s[1]=0.0;		s[2]=-1.0
			t[0]=0.0;		t[1]=1.0;		t[2]=0.0
			For i=16 To 19	
				c[0]=data[5*i+2]	
				c[1]=data[5*i+3]
				c[2]=data[5*i+4]
				SetUpBumps(Varptr n[0], Varptr c[0], Varptr l[0], Varptr s[0], Varptr t[0])
				glTexCoord2f(data[5*i]+c[0], data[5*i+1]+c[1])
				glVertex3f(data[5*i+2], data[5*i+3], data[5*i+4])
			Next
			' Left Face
			n[0]=-1.0;		n[1]=0.0;		n[2]=0.0		
			s[0]=0.0;		s[1]=0.0;		s[2]=1.0
			t[0]=0.0;		t[1]=1.0;		t[2]=0.0
			For i=20 To 23	
				c[0]=data[5*i+2]	
				c[1]=data[5*i+3]
				c[2]=data[5*i+4]
				SetUpBumps(Varptr n[0], Varptr c[0], Varptr l[0], Varptr s[0], Varptr t[0])
				glTexCoord2f(data[5*i]+c[0], data[5*i+1]+c[1])
				glVertex3f(data[5*i+2], data[5*i+3], data[5*i+4])
			Next		
		glEnd()
		
		Rem
		PASS#3:
		Use Texture "Base"
		Blend GL_DST_COLOR To GL_SRC_COLOR (Multiplies By 2)
		Lighting Enabled
		No Offset Texture-Coordinates
		End Rem
		If Not emboss Then
			glTexEnvf (GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE)
			glBindTexture(GL_TEXTURE_2D,texture[filter])
			glBlendFunc(GL_DST_COLOR,GL_SRC_COLOR)
			glEnable(GL_LIGHTING)
			doCube()
		EndIf
	
		xrot:+xspeed
		yrot:+yspeed
		If xrot>360.0 Then xrot:-360.0
		If xrot<0.0 Then xrot:+360.0
		If yrot>360.0 Then yrot:-360.0
		If yrot<0.0 Then yrot:+360.0
	
		' LAST PASS:	Do The Logos!
		doLogo()
	End Method
	
	Method doMesh2TexelUnits()
		Local c:Float[]=[0.0,0.0,0.0,1.0]							' Holds Current Vertex
		Local n:Float[]=[0.0,0.0,0.0,1.0]							' Normalized Normal Of Current Surface		
		Local s:Float[]=[0.0,0.0,0.0,1.0]							' s-Texture Coordinate Direction, Normalized
		Local t:Float[]=[0.0,0.0,0.0,1.0]							' t-Texture Coordinate Direction, Normalized
		Local l:Float[4]											' Holds Our Lightposition To Be Transformed Into Object Space
		Local Minv:Float[16]										' Holds The Inverted Modelview Matrix To Do So.
		Local i:Int
	
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)			' Clear The Screen And The Depth Buffer
			
		' Build Inverse Modelview Matrix First. This Substitutes One Push/Pop With One glLoadIdentity();
		' Simply Build It By Doing All Transformations Negated And In Reverse Order.
		glLoadIdentity()								
		glRotatef(-yrot,0.0,1.0,0.0)
		glRotatef(-xrot,1.0,0.0,0.0)
		glTranslatef(0.0,0.0,-z)
		glGetFloatv(GL_MODELVIEW_MATRIX, Minv)
		glLoadIdentity()
		glTranslatef(0.0,0.0,z)
	
		glRotatef(xrot,1.0,0.0,0.0)
		glRotatef(yrot,0.0,1.0,0.0)
	
		' Transform The Lightposition Into Object Coordinates:
		l[0]=LightPosition[0]
		l[1]=LightPosition[1]
		l[2]=LightPosition[2]
		l[3]=1.0													' Homogenous Coordinate
		VMatMult(Varptr Minv[0], Varptr l[0])
	
		Rem
		PASS#1:
		Texel-Unit 0:	Use Texture "Bump"
			No Blend
			No Lighting
			No Offset Texture-Coordinates 
			Texture-Operation "Replace"
		Texel-Unit 1:	Use Texture "Invbump"
			No Lighting
			Offset Texture Coordinates 
			Texture-Operation "Replace"
		End Rem
		' TEXTURE-UNIT #0		
		glActiveTexture(GL_TEXTURE0_ARB)
		glEnable(GL_TEXTURE_2D)
		glBindTexture(GL_TEXTURE_2D, bump[filter])
		glTexEnvf (GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_COMBINE_EXT)
		glTexEnvf (GL_TEXTURE_ENV, GL_COMBINE_RGB_EXT, GL_REPLACE)	
		' TEXTURE-UNIT #1:
		glActiveTextureARB(GL_TEXTURE1_ARB)
		glEnable(GL_TEXTURE_2D)
		glBindTexture(GL_TEXTURE_2D, invbump[filter])
		glTexEnvf (GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_COMBINE_EXT)
		glTexEnvf (GL_TEXTURE_ENV, GL_COMBINE_RGB_EXT, GL_ADD)
		' General Switches:
		glDisable(GL_BLEND)
		glDisable(GL_LIGHTING)	
		glBegin(GL_QUADS)	
			' Front Face	
			n[0]=0.0;		n[1]=0.0;		n[2]=1.0
			s[0]=1.0;		s[1]=0.0;		s[2]=0.0
			t[0]=0.0;		t[1]=1.0;		t[2]=0.0
			For i=0 To 3	
				c[0]=data[5*i+2]
				c[1]=data[5*i+3]
				c[2]=data[5*i+4]
				SetUpBumps(Varptr n[0], Varptr c[0], Varptr l[0], Varptr s[0], Varptr t[0])
				glMultiTexCoord2fARB(GL_TEXTURE0_ARB,data[5*i],data[5*i+1]) 
				glMultiTexCoord2fARB(GL_TEXTURE1_ARB,data[5*i]+c[0], data[5*i+1]+c[1])
				glVertex3f(data[5*i+2],data[5*i+3],data[5*i+4])
			Next
			' Back Face	
			n[0]=0.0;		n[1]=0.0;		n[2]=-1.0	
			s[0]=-1.0;		s[1]=0.0;		s[2]=0.0
			t[0]=0.0;		t[1]=1.0;		t[2]=0.0
			For i=4 To 7	
				c[0]=data[5*i+2]	
				c[1]=data[5*i+3]
				c[2]=data[5*i+4]
				SetUpBumps(Varptr n[0], Varptr c[0], Varptr l[0], Varptr s[0], Varptr t[0])
				glMultiTexCoord2fARB(GL_TEXTURE0_ARB,data[5*i], data[5*i+1])
				glMultiTexCoord2fARB(GL_TEXTURE1_ARB,data[5*i]+c[0],data[5*i+1]+c[1])
				glVertex3f(data[5*i+2],data[5*i+3],data[5*i+4])
			Next
			' Top Face	
			n[0]=0.0;		n[1]=1.0;		n[2]=0.0;		
			s[0]=1.0;		s[1]=0.0;		s[2]=0.0;
			t[0]=0.0;		t[1]=0.0;		t[2]=-1.0;
			For i=8 To 11	
				c[0]=data[5*i+2]
				c[1]=data[5*i+3]
				c[2]=data[5*i+4]
				SetUpBumps(Varptr n[0], Varptr c[0], Varptr l[0], Varptr s[0], Varptr t[0])
				glMultiTexCoord2fARB(GL_TEXTURE0_ARB,data[5*i],data[5*i+1]     )
				glMultiTexCoord2fARB(GL_TEXTURE1_ARB,data[5*i]+c[0],data[5*i+1]+c[1])
				glVertex3f(data[5*i+2],data[5*i+3],data[5*i+4])
			Next
			' Bottom Face
			n[0]=0.0;		n[1]=-1.0;		n[2]=0.0;		
			s[0]=-1.0;		s[1]=0.0;		s[2]=0.0;
			t[0]=0.0;		t[1]=0.0;		t[2]=-1.0;
			For i=12 To 15	
				c[0]=data[5*i+2]
				c[1]=data[5*i+3]
				c[2]=data[5*i+4]
				SetUpBumps(Varptr n[0], Varptr c[0], Varptr l[0], Varptr s[0], Varptr t[0])
				glMultiTexCoord2fARB(GL_TEXTURE0_ARB,data[5*i],data[5*i+1]     ) 
				glMultiTexCoord2fARB(GL_TEXTURE1_ARB,data[5*i]+c[0],data[5*i+1]+c[1])
				glVertex3f(data[5*i+2],data[5*i+3],data[5*i+4])
			Next
			' Right Face	
			n[0]=1.0;		n[1]=0.0;		n[2]=0.0	
			s[0]=0.0;		s[1]=0.0;		s[2]=-1.0
			t[0]=0.0;		t[1]=1.0;		t[2]=0.0
			For i=16 To 19	
				c[0]=data[5*i+2]	
				c[1]=data[5*i+3]
				c[2]=data[5*i+4]
				SetUpBumps(Varptr n[0], Varptr c[0], Varptr l[0], Varptr s[0], Varptr t[0])
				glMultiTexCoord2fARB(GL_TEXTURE0_ARB,data[5*i],data[5*i+1]     )
				glMultiTexCoord2fARB(GL_TEXTURE1_ARB,data[5*i]+c[0],data[5*i+1]+c[1])
				glVertex3f(data[5*i+2],data[5*i+3],data[5*i+4])
			Next
			' Left Face
			n[0]=-1.0;		n[1]=0.0;		n[2]=0.0;		
			s[0]=0.0;		s[1]=0.0;		s[2]=1.0;
			t[0]=0.0;		t[1]=1.0;		t[2]=0.0;
			For i=20 To 23	
				c[0]=data[5*i+2]
				c[1]=data[5*i+3]
				c[2]=data[5*i+4]
				SetUpBumps(Varptr n[0], Varptr c[0], Varptr l[0], Varptr s[0], Varptr t[0])
				glMultiTexCoord2fARB(GL_TEXTURE0_ARB,data[5*i],data[5*i+1]     )
				glMultiTexCoord2fARB(GL_TEXTURE1_ARB,data[5*i]+c[0],data[5*i+1]+c[1])
				glVertex3f(data[5*i+2],data[5*i+3],data[5*i+4])
			Next		
		glEnd()
		
		Rem
		PASS#2:
		Use Texture "Base"
			Blend GL_DST_COLOR To GL_SRC_COLOR (Multiplies By 2)
			Lighting Enabled
			No Offset Texture-Coordinates
		End Rem	
		glActiveTextureARB(GL_TEXTURE1_ARB)	
		glDisable(GL_TEXTURE_2D)
		glActiveTextureARB(GL_TEXTURE0_ARB)
		If Not emboss Then
			glTexEnvf (GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE)
			glBindTexture(GL_TEXTURE_2D,texture[filter])
			glBlendFunc(GL_DST_COLOR,GL_SRC_COLOR)
			glEnable(GL_BLEND)
			glEnable(GL_LIGHTING)
			doCube()
		EndIf
	
		xrot:+xspeed
		yrot:+yspeed
		If xrot>360.0 Then xrot:-360.0
		If xrot<0.0 Then xrot:+360.0
		If yrot>360.0 Then yrot:-360.0
		If yrot<0.0 Then yrot:+360.0
	
		' LAST PASS: Do The Logos!	
		doLogo()
	End Method
	
	Method doMeshNoBumps()
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)					' Clear The Screen And The Depth Buffer
		glLoadIdentity()													' Reset The View
		glTranslatef(0.0,0.0,z)
	
		glRotatef(xrot,1.0,0.0,0.0)
		glRotatef(yrot,0.0,1.0,0.0)
		If useMultitexture Then
			glActiveTextureARB(GL_TEXTURE1_ARB)		
			glDisable(GL_TEXTURE_2D)
			glActiveTextureARB(GL_TEXTURE0_ARB)
		EndIf
		glDisable(GL_BLEND)
		glBindTexture(GL_TEXTURE_2D,texture[filter])	
		glBlendFunc(GL_DST_COLOR,GL_SRC_COLOR)
		glEnable(GL_LIGHTING)
		doCube()
		
		xrot:+xspeed
		yrot:+yspeed
		If xrot>360.0 Then xrot:-360.0
		If xrot<0.0 Then xrot:+360.0
		If yrot>360.0 Then yrot:-360.0
		If yrot<0.0 Then yrot:+360.0
	
	' LAST PASS: Do The Logos!	
		doLogo()
	End Method
End Type	
