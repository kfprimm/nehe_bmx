Strict
Import "framework.bmx"

New TNeHe24.Run(24,"Scissor Tga")

Type TNeHe24 Extends TNeHe	
	'
	'***************************************************************************************************************
	' Modified to use TGA Loader
	'***************************************************************************************************************
	'
	Field ScreenWidth:Int=640
	Field ScreenHeight:Int=480
	Field ScreenDepth:Int=32
	
	Field scroll:Int					' Used For Scrolling The Screen
	Field maxtokens:Int=0				' Keeps Track Of The Number Of Extensions Supported
	Field base:Int					' Base Display List For The Font
	
	Field textureload:Int
	
	Method Init()
		LoadGlTextures()
		BuildFont()														' Build The Font
		glShadeModel(GL_SMOOTH)											' Enable Smooth Shading
		glClearColor(0.0, 0.0, 0.0, 0.5)									' Black Background
		glClearDepth(1.0)													' Depth Buffer Setup
		glBindTexture(GL_TEXTURE_2D, textureload)'texturebase.texID)						' Select Our Font Texture
			
		glViewport(0,0,ScreenWidth,ScreenHeight)							' Set viewport
		glMatrixMode(GL_PROJECTION)										' Select The Projection Matrix
		glLoadIdentity()													' Reset The Projection Matrix
		glOrtho(0.0,ScreenWidth,ScreenHeight,0.0,-1.0,1.0)					' Create Ortho Width*Height View (0,0 At Top Left)
		glMatrixMode(GL_MODELVIEW)											' Select The Modelview Matrix
		glLoadIdentity()
	End Method
	
	Method LoadGlTextures()
		Local TextureImage1:TPixmap
		TextureImage1:TPixmap=LoadPixmap("Data\Font.TGA")
		TextureImage1:TPixmap=YFlipPixmap(TextureImage1)						' Swap image verticaly (font image)
	
		glGenTextures(1, Varptr textureload)								' Generate OpenGL texture IDs
		glBindTexture(GL_TEXTURE_2D, textureload)							' Bind Our Texture
		glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR)		' Linear Filtered
		glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR)		' Linear Filtered
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, TextureImage1.width, TextureImage1.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, TextureImage1.pixels)
	End Method
	
	Method loop()
		Local text:String=""												' Allocate string For Our Extension String
		Local StartPos:Int=0												' Start position of 'Space' string
		Local EndPos:Int=0												' End pos
		Local token:String												' Storage For Our Token
		Local cnt:Int=0													' Local Counter Variable
	
		If KeyDown(KEY_UP) And scroll>0 Then								' Is Up Arrow Being Pressed?
			scroll:-2													' If So, Decrease 'scroll' Moving Screen Down
		EndIf
		If KeyDown(KEY_DOWN) And scroll<32*(maxtokens-9)						' Is Down Arrow Being Pressed?
			scroll:+2													' If So, Increase 'scroll' Moving Screen Up
		EndIf
	
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)					' Clear The Screen And The Depth Buffer
		glColor3f(1.0,0.5,0.5)												' Set Color To Bright Red
		glPrint(50,16+4,"Renderer",1)										' Display Renderer
		glPrint(80,48+4,"Vendor",1)										' Display Vendor Name
		glPrint(66,80+4,"Version",1)										' Display Version
	
		glColor3f(1.0,0.7,0.4)												' Set Color To Orange
		glPrint(200,16+4,"".FromCString(Byte Ptr glGetString(GL_RENDERER)),1)	' Display Renderer
		glPrint(200,48+4,"".FromCString(Byte Ptr glGetString(GL_VENDOR)),1)	' Display Vendor Name
		glPrint(200,80+4,"".FromCString(Byte Ptr glGetString(GL_VERSION)),1)	' Display Version
	
		glColor3f(0.5,0.5,1.0)												' Set Color To Bright Blue
		glPrint(192,432+4,"NeHe Productions",1)								' Write NeHe Productions At The Bottom Of The Screen
	
		glLoadIdentity()													' Reset The ModelView Matrix
		glColor3f(1.0,1.0,1.0)												' Set The Color To White
		glBegin(GL_LINE_STRIP)												' Start Drawing Line Strips (Something New)
			glVertex2d(639,417)											' Top Right Of Bottom Box
			glVertex2d(  0,417)											' Top Left Of Bottom Box
			glVertex2d(  0,480)											' Lower Left Of Bottom Box
			glVertex2d(639,480)											' Lower Right Of Bottom Box
			glVertex2d(639,128)											' Up To Bottom Right Of Top Box
		glEnd()															' Done First Line Strip
		glBegin(GL_LINE_STRIP)												' Start Drawing Another Line Strip
			glVertex2d(  0,128)											' Bottom Left Of Top Box
			glVertex2d(639,128)											' Bottom Right Of Top Box								
			glVertex2d(639,  1)											' Top Right Of Top Box
			glVertex2d(  0,  1)											' Top Left Of Top Box
			glVertex2d(  0,417)											' Down To Top Left Of Bottom Box
		glEnd()															' Done Second Line Strip
	
		' Define Scissor Region
		glScissor(1,Int(0.135416*Float(ScreenHeight)),ScreenWidth-2,Int(0.597916*Float(ScreenHeight)))
		glEnable(GL_SCISSOR_TEST)											' Enable Scissor Testing
	
		text="".FromCString(Byte Ptr glGetString(GL_EXTENSIONS))				' Grab The Extension List, Store In Text
		While StartPos<text.length
			cnt:+1														' Increase The Counter
			If cnt>maxtokens												' Is 'maxtokens' Less Than 'cnt'
				maxtokens=cnt												' If So, Set 'maxtokens' Equal To 'cnt'
			EndIf
				
			EndPos=text.find(" ",StartPos)
			If EndPos<0
				EndPos=text.length
			EndIf
			token=text[StartPos..EndPos]
			glColor3f(0.5,1.0,0.5)											' Set Color To Bright Green
			glPrint(0,96+(cnt*32)-scroll,"".FromInt(cnt),0)					' Print Current Extension Number
			glColor3f(1.0,1.0,0.5)											' Set Color To Yellow
			glPrint(50,96+(cnt*32)-scroll,token,0)							' Print The Current Token (Parsed Extension Name)
			StartPos=EndPos+1
		Wend
	
		glDisable(GL_SCISSOR_TEST)											' Disable Scissor Testing
		glColor3f(1.0,1.0,1.0)
		'--------------------------------------------------------
		GLDrawText("NeHe's Token, Extensions, Scissoring & TGA Loading Tutorial (lesson 24)",10,24)
		Flip
	End Method
	
	Method glPrint(x:Int, y:Int, phrase:String, set:Int)					' Where The Printing Happens
		If (set>1) Then set=1
		glEnable(GL_TEXTURE_2D)											' Enable Texture Mapping
		glLoadIdentity()													' Reset The Modelview Matrix
		glTranslated(x,y,0)												' Position The Text (0,0 - Top Left)
		glListBase(base-32+(128*set))										' Choose The Font Set (0 Or 1)
		glScalef(1.0,2.0,1.0)												' Make The Text 2X Taller
		glCallLists(phrase.length, GL_UNSIGNED_BYTE, Byte Ptr phrase.ToCString())			' Write The Text To The Screen
		glDisable(GL_TEXTURE_2D)											' Disable Texture Mapping
	End Method
	
	Method BuildFont()													' Build Our Font Display List
		Local cx:Float													' Holds Our X Character Coord
		Local cy:Float													' Holds Our Y Character Coord
		base=glGenLists(256)												' Creating 256 Display Lists
		glBindTexture(GL_TEXTURE_2D, textureload)							' Select Our Font Texture
		For Local loop1=0 To 255											' Loop Through All 256 Lists
			cx=Float(loop1 Mod 16)/16.0									' X Position Of Current Character
			cy=Float(loop1/16)/16.0										' Y Position Of Current Character
			glNewList(base+loop1,GL_COMPILE)								' Start Building A List
				glBegin(GL_QUADS)											' Use A Quad For Each Character
					glTexCoord2f(cx,1.0-cy-0.0625)							' Texture Coord (Bottom Left)
					glVertex2d(0,16)										' Vertex Coord (Bottom Left)
					glTexCoord2f(cx+0.0625,1.0-cy-0.0625)					' Texture Coord (Bottom Right)
					glVertex2i(16,16)										' Vertex Coord (Bottom Right)
					glTexCoord2f(cx+0.0625,1.0-cy-0.001)					' Texture Coord (Top Right)
					glVertex2i(16,0)										' Vertex Coord (Top Right)
					glTexCoord2f(cx,1.0-cy-0.001)							' Texture Coord (Top Left)
					glVertex2i(0,0)										' Vertex Coord (Top Left)
				glEnd()													' Done Building Our Quad (Character)
				glTranslated(14,0,0)										' Move To The Right Of The Character
			glEndList()													' Done Building The Display List
		Next
	End Method 
End Type