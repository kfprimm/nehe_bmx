Strict
Import "framework.bmx"

New TNeHe17.Run(17,"2d font")

Type TNeHe17 Extends TNeHe
	Field ScreenWidth:Int=800
	Field ScreenHeight:Int=600
	Field ScreenDepth:Int=32

	Field base:Int					' Base Display List For The Font
	Field loops:Int					' Generic Loop Variable
	Field cnt1:Float					' 1st Counter Used To Move Text & For Coloring
	Field cnt2:Float					' 2nd Counter Used To Move Text & For Coloring
	Field texture:Int[2]				' Storage For Our Font Texture

	Method Init()
		LoadGlTextures()
		BuildFont()
		glEnable(GL_TEXTURE_2D)											' Enable Texture Mapping
		glShadeModel(GL_SMOOTH)											' Enable Smooth Shading
		glClearColor(0.0,0.0,0.0,0.0)										' We'll Clear To The Color Of The Fog
		glClearDepth(1.0)													' Depth Buffer Setup
		glEnable(GL_DEPTH_TEST)											' Enables Depth Testing
		glDepthFunc(GL_LEQUAL)												' The Type Of Depth Testing To Do
		glBlendFunc(GL_SRC_ALPHA,GL_ONE)									' Select The Type Of Blending
		glViewport(0,0,ScreenWidth,ScreenHeight)							' Set viewport
		glMatrixMode(GL_PROJECTION)										' Select The Projection Matrix
		glLoadIdentity()													' Reset The Projection Matrix
		gluPerspective(45.0,Float(ScreenWidth)/Float(ScreenHeight),0.1,100.0)	' Calculate The Aspect Ratio Of The Window
		glMatrixMode(GL_MODELVIEW)											' Select The Modelview Matrix
		glLoadIdentity()
	End Method

	Method LoadGlTextures()
		Local TextureImage:TPixmap[2]
		TextureImage:TPixmap[0]=LoadPixmap("data\font.bmp")
		TextureImage:TPixmap[1]=LoadPixmap("data\bumps.bmp")
		TextureImage:TPixmap[0]=YFlipPixmap(TextureImage[0])		' Swap image verticaly (font image)
		
		glGenTextures(2, Varptr texture[0])						' Create Two Texture
		For loops=0 To 1
			glBindTexture(GL_TEXTURE_2D, texture[loops]);
			glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
			glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
			glTexImage2D(GL_TEXTURE_2D, 0, 3, TextureImage[loops].width, TextureImage[loops].height, 0, GL_RGB, GL_UNSIGNED_BYTE, TextureImage[loops].pixels)
		Next
	End Method

	Method Loop()
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)	' Clear The Screen And The Depth Buffer
		glLoadIdentity()									' Reset The Modelview Matrix
		glBindTexture(GL_TEXTURE_2D, texture[1])			' Select Our Second Texture
		glTranslatef(0.0,0.0,-5.0)							' Move Into The Screen 5 Units
		glRotatef(45.0,0.0,0.0,1.0)						' Rotate On The Z Axis 45 Degrees (Clockwise)
		glRotatef(cnt1*30.0,1.0,1.0,0.0)					' Rotate On The X & Y Axis By cnt1 (Left To Right)
		glDisable(GL_BLEND)								' Disable Blending Before We Draw In 3D
		glColor3f(1.0,1.0,1.0)								' Bright White
		glBegin(GL_QUADS)									' Draw Our First Texture Mapped Quad
			glTexCoord2d(0.0,0.0)							' First Texture Coord
			glVertex2f(-1.0, 1.0)							' First Vertex
			glTexCoord2d(1.0,0.0)							' Second Texture Coord
			glVertex2f( 1.0, 1.0)							' Second Vertex
			glTexCoord2d(1.0,1.0)							' Third Texture Coord
			glVertex2f( 1.0,-1.0)							' Third Vertex
			glTexCoord2d(0.0,1.0)							' Fourth Texture Coord
			glVertex2f(-1.0,-1.0)							' Fourth Vertex
		glEnd()											' Done Drawing The First Quad
		glRotatef(90.0,1.0,1.0,0.0)						' Rotate On The X & Y Axis By 90 Degrees (Left To Right)
		glBegin(GL_QUADS)									' Draw Our Second Texture Mapped Quad
			glTexCoord2d(0.0,0.0)							' First Texture Coord
			glVertex2f(-1.0, 1.0)							' First Vertex
			glTexCoord2d(1.0,0.0)							' Second Texture Coord
			glVertex2f( 1.0, 1.0)							' Second Vertex
			glTexCoord2d(1.0,1.0)							' Third Texture Coord
			glVertex2f( 1.0,-1.0)							' Third Vertex
			glTexCoord2d(0.0,1.0)							' Fourth Texture Coord
			glVertex2f(-1.0,-1.0)							' Fourth Vertex
		glEnd()											' Done Drawing Our Second Quad
		glEnable(GL_BLEND)								' Enable Blending
	
		glLoadIdentity()									' Reset The View
		' Pulsing Colors Based On Text Position
		glColor3f(1.0*Float(Cos(cnt1)),1.0*Float(Sin(cnt2)),1.0-0.5*Float(Cos(cnt1+cnt2)))
		glPrint(Int((280.0+250.0*Cos(cnt1))),Int(235.0+200.0*Sin(cnt2)),"NeHe (Set 0)",0)				' Print GL Text To The Screen
		glColor3f(1.0*Float(Sin(cnt2)),1.0-0.5*Float(Cos(cnt1+cnt2)),1.0*Float(Cos(cnt1)))
		glPrint(Int((280.0+230.0*Cos(cnt2))),Int(235.0+200.0*Sin(cnt1)),"OpenGL (Set 1)",1)				' Print GL Text To The Screen
		' Shadowed look
		glColor3f(0.0,0.0,1.0)																' Set Color To Blue
		glPrint(Int(240+200*Cos((cnt2+cnt1)/5.0)),2,"Giuseppe D'Agata",0)						' Print GL Text To The Screen
		glColor3f(1.0,1.0,1.0)																' Set Color To White
		glPrint(Int(242+200*Cos((cnt2+cnt1)/5.0)),2,"Giuseppe D'Agata",0)						' Print GL Text To The Screen
		
		cnt1:+0.01										' Increase The First Counter
		cnt2:+0.0081										' Increase The Second Counter
		glDisable(GL_TEXTURE_2D)	
		glDisable(GL_DEPTH_TEST)	
		glColor3f(1.0,1.0,1.0)
		'--------------------------------------------------------
		GLDrawText("NeHe & Giuseppe D'Agata's 2D Font Tutorial (lesson 17)",10,24)
		
		glEnable(GL_DEPTH_TEST)
		glEnable(GL_TEXTURE_2D)
	End Method 

	Method glPrint(x:Int, y:Int, phrase:String, set:Int)			' Where The Printing Happens
		If (set>1) Then set=1
		glBindTexture(GL_TEXTURE_2D, texture[0])					' Select Our Font Texture
		glDisable(GL_DEPTH_TEST)									' Disables Depth Testing
		glMatrixMode(GL_PROJECTION)								' Select The Projection Matrix
		glPushMatrix()											' Store The Projection Matrix
		glLoadIdentity()											' Reset The Projection Matrix
		glOrtho(0,800,0,600,-1,1)									' Set Up An Ortho Screen
		glMatrixMode(GL_MODELVIEW)									' Select The Modelview Matrix
		glPushMatrix()											' Store The Modelview Matrix
		glLoadIdentity()											' Reset The Modelview Matrix
		glTranslated(x,y,0)										' Position The Text (0,0 - Bottom Left)
		glListBase(base-32 + (128 * set))							' Choose The Font Set (0 Or 1)
		glCallLists(phrase.length, GL_UNSIGNED_BYTE, Byte Ptr phrase.ToCString())	' Write The Text To The Screen
		glMatrixMode(GL_PROJECTION)								' Select The Projection Matrix
		glPopMatrix()												' Restore The Old Projection Matrix
		glMatrixMode(GL_MODELVIEW)									' Select The Modelview Matrix
		glPopMatrix()												' Restore The Old Projection Matrix
		glEnable(GL_DEPTH_TEST)									' Enables Depth Testing
	End Method

	Method BuildFont()									' Build Our Font Display List
		Local cx:Float									' Holds Our X Character Coord
		Local cy:Float									' Holds Our Y Character Coord
		base=glGenLists(256)								' Creating 256 Display Lists
		glBindTexture(GL_TEXTURE_2D, texture[0])			' Select Our Font Texture
		For loops=0 To 255									' Loop Through All 256 Lists
			cx=Float(loops Mod 16)/16.0						' X Position Of Current Character
			cy=Float(loops/16)/16.0							' Y Position Of Current Character
			glNewList(base+loops,GL_COMPILE)					' Start Building A List
				glBegin(GL_QUADS)							' Use A Quad For Each Character
					glTexCoord2f(cx,1-cy-0.0625)			' Texture Coord (Bottom Left)
					glVertex2i(0,0)						' Vertex Coord (Bottom Left)
					glTexCoord2f(cx+0.0625,1-cy-0.0625)		' Texture Coord (Bottom Right)
					glVertex2i(16,0)						' Vertex Coord (Bottom Right)
					glTexCoord2f(cx+0.0625,1-cy)			' Texture Coord (Top Right)
					glVertex2i(16,16)						' Vertex Coord (Top Right)
					glTexCoord2f(cx,1-cy)					' Texture Coord (Top Left)
					glVertex2i(0,16)						' Vertex Coord (Top Left)
				glEnd()									' Done Building Our Quad (Character)
				glTranslated(10,0,0)						' Move To The Right Of The Character
			glEndList()									' Done Building The Display List
		Next
	End Method
End Type