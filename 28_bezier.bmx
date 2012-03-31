Strict
Import "framework.bmx"

New TNeHe28.Run(28,"Bezier")

Type POINT_3D									' Structure For a 3-dimensional point
	Field x:Double, y:Double, z:Double
End Type

Type BEZIER_PATCH								' Structure For a 3rd degree Bezier patch
	Field anchors:POINT_3D[][]				' 4x4 grid of anchor points
	Field dlBPatch:Int						' Display List For Bezier Patch
	Field texture:Int							' Texture For the patch
End Type
	
Type TNeHe28 Extends TNeHe

	' **********************************************************************************************************
	' Change method pointAdd(), pointTimes(), makePoint() and Bernstein() : Type are send by ref.
	'
	' Tweaked display list, don't recreate a list in genBezier(), this will cause a massive memory leak.
	' Simply create a list in initBezier() and store it in dlBPatch field.
	' To change the display list recreate it with the same number (stored in dlBPatch field).
	' **********************************************************************************************************
	'
	Field texture:Int
	
	Field rotz:Float=0.0							' Rotation about the Z axis
	Field mybezier:BEZIER_PATCH=New BEZIER_PATCH	' The bezier patch we're going to use
	Field showCPoints:Byte=True					' Toggles displaying the control point grid
	Field divs:Int=7								' Number of intrapolations (conrols poly resolution)
	
	Field ShowMenu:Int
	Method Init()
		glEnable(GL_TEXTURE_2D)											' Enable Texture Mapping
		glShadeModel(GL_SMOOTH)											' Enable Smooth Shading
		'glClearColor(0.05, 0.05, 0.05, 0.5)									' Black Background
		glClearColor(0.5, 0.5, 0.5, 0.5)	
		glClearDepth(1.0)													' Depth Buffer Setup
		glEnable(GL_DEPTH_TEST)											' Enables Depth Testing
		glDepthFunc(GL_LEQUAL)												' The Type Of Depth Testing To Do
		glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST)					' Really Nice Perspective Calculations
	
		initBezier()														' Initialize the Bezier's control grid
		LoadGLTextures(Varptr mybezier.texture, "data\NeHe.bmp")				' Load the texture
		'Replace : 'mybezier.dlBPatch=genBezier(mybezier, divs)'
		genBezier(mybezier, divs)											' Generate the patch
		
		glViewport(0,0,ScreenWidth,ScreenHeight)							' Reset The Current Viewport
		glMatrixMode(GL_PROJECTION)										' Select The Projection Matrix
		glLoadIdentity()													' Reset The Projection Matrix
		gluPerspective(45.0,Float(ScreenWidth)/Float(ScreenHeight),0.1,100.0)	' Calculate The Aspect Ratio Of The Window
		glMatrixMode(GL_MODELVIEW)											' Select The Modelview Matrix
		glLoadIdentity()
	End Method
	
	' Load Bitmaps And Convert To Textures
	Method LoadGlTextures(texPntr:Int Ptr, name:String)
		Local TextureImage:TPixmap
		TextureImage:TPixmap=LoadPixmap(name)
		TextureImage:TPixmap=YFlipPixmap(TextureImage)						' Swap image verticaly (font image)
	
		glGenTextures(1, texPntr)											' Generate OpenGL texture IDs
		glBindTexture(GL_TEXTURE_2D, texPntr[0])							' Bind Our Texture
		glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR)		' Linear Filtered
		glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR)		' Linear Filtered
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, TextureImage.width, TextureImage.height, 0, GL_RGB, GL_UNSIGNED_BYTE, TextureImage.pixels)
	End Method
	
	Method Loop()
		Local i:Int, j:Int
			
		If KeyHit(KEY_F1) Then ShowMenu=Not ShowMenu
		If KeyDown(KEY_LEFT) Then rotz:-0.8									' rotate Left
		If KeyDown(KEY_RIGHT) Then rotz:+0.8								' rotate Right
		If KeyDown(KEY_UP) Then												' resolution up
			divs:+1
			' Replace 'mybezier.dlBPatch=genBezier(mybezier, divs)'
			genBezier(mybezier, divs)										' Update the patch
		EndIf
		If KeyDown(KEY_DOWN) And divs>1 Then									' resolution down
			divs:-1
			' Replace 'mybezier.dlBPatch=genBezier(mybezier, divs)'
			genBezier(mybezier, divs)										' Update the patch
		EndIf
		If KeyHit(KEY_SPACE)												' SPACE toggles showCPoints
			showCPoints = Not showCPoints
		EndIf
			
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)					' Clear Screen And Depth Buffer
		glLoadIdentity()													' Reset The Current Modelview Matrix
		glTranslatef(0.0,0.0,-4.0)											' Move Left 1.5 Units And Into The Screen 6.0
		glRotatef(-75.0,1.0,0.0,0.0)
		glRotatef(rotz,0.0,0.0,1.0)										' Rotate The Triangle On The Z axis ( New )
		glCallList(mybezier.dlBPatch)										' Call the Bezier's display list
		' This need only be updated when the patch changes
		If showCPoints Then												' If drawing the grid is toggled on
			glDisable(GL_TEXTURE_2D)
			glColor3f(1.0,0.0,0.0)
			For i=0 Until 4												' draw the horizontal lines
				glBegin(GL_LINE_STRIP)
				For j=0 Until 4
					glVertex3d(mybezier.anchors[i][j].x, mybezier.anchors[i][j].y, mybezier.anchors[i][j].z)
				Next
				glEnd()
			Next
			For i=0 Until 4												' draw the vertical lines
				glBegin(GL_LINE_STRIP)
				For j=0 Until 4
					glVertex3d(mybezier.anchors[j][i].x, mybezier.anchors[j][i].y, mybezier.anchors[j][i].z)
				Next
				glEnd()
			Next
			glColor3f(1.0,1.0,1.0)
			glEnable(GL_TEXTURE_2D)
		EndIf
		DrawMenu()
	End Method
	
	Method DrawMenu()
		glDisable(GL_TEXTURE_2D)	
		glDisable(GL_DEPTH_TEST)
		glColor3f(1.0,1.0,1.0)
		GLDrawText("F1 : Hide/Show menu",10,ScreenHeight-16-8)
		If ShowMenu Then
			GLDrawText("David Nikdel & NeHe's Bezier Tutorial (lesson 28)",10,24)
			GLDrawText("'LEFT'  Rotate left",10,56)
			GLDrawText("'RIGHT' Rotate right",10,72)
			GLDrawText("'UP'    Resolution up",10,88)
			GLDrawText("'DOWN'  Resolution down",10,104)
			GLDrawText("'SPACE' Hide/Show points",10,120)
		EndIf
		glEnable(GL_TEXTURE_2D	)
		glEnable(GL_DEPTH_TEST)
	End Method
	
	' Adds 2 points. Don't just use '+' ;)
	Method pointAdd(result:POINT_3D, p:POINT_3D, q:POINT_3D)
		result.x=p.x+q.x; result.y=p.y+q.y; result.z=p.z+q.z
	End Method
	
	' Multiplies a point And a constant. Don't just use '*'
	Method pointTimes(result:POINT_3D, c:Double, p:POINT_3D)
		result.x=p.x*c; result.y=p.y*c; result.z=p.z*c
	End Method
	
	' method For quick point creation
	Method makePoint(result:POINT_3D, a:Double, b:Double, c:Double)
		result.x=a; result.y=b; result.z=c
	End Method
	
	' Calculates 3rd degree polynomial based on array of 4 points
	' And a single variable (u) which is generally between 0 And 1
	Method Bernstein(result:POINT_3D, u:Float, p:POINT_3D[])
		Local a:POINT_3D = New POINT_3D
		Local b:POINT_3D = New POINT_3D
		Local c:POINT_3D = New POINT_3D
		Local d:POINT_3D = New POINT_3D
		Local r1:POINT_3D = New POINT_3D
		Local r2:POINT_3D = New POINT_3D
	
		pointTimes(a,u*u*u, p[0])
		pointTimes(b,3*(u*u)*(1-u), p[1])
		pointTimes(c,3*u*((1-u)*(1-u)), p[2])
		pointTimes(d,(1-u)*(1-u)*(1-u), p[3])
	
		pointAdd(r1, a, b)
		pointAdd(r2, c, d)
		pointAdd(result, r1, r2)
	End Method
	
	' Generates a display list based on the data in the patch and the number of divisions
	Method genBezier:Int(patch:BEZIER_PATCH, divs:Int)
		Local u:Int=0
		Local v:Int
		Local py:Float, px:Float, pyold:Float
		Local temp:POINT_3D[4]	
		
		Local last:POINT_3D[divs+1]										' array of points To mark the first line of polys
		For Local i=0 To divs
			last[i]=New POINT_3D
		Next
	
		temp[0]=New POINT_3D ; temp[1]=New POINT_3D ; temp[2]=New POINT_3D ; temp[3]=New POINT_3D
		temp[0].x=patch.anchors[0][3].x ; temp[0].y=patch.anchors[0][3].y ; temp[0].z=patch.anchors[0][3].z
		temp[1].x=patch.anchors[1][3].x ; temp[1].y=patch.anchors[1][3].y ; temp[1].z=patch.anchors[1][3].z
		temp[2].x=patch.anchors[2][3].x ; temp[2].y=patch.anchors[2][3].y ; temp[2].z=patch.anchors[2][3].z
		temp[3].x=patch.anchors[3][3].x ; temp[3].y=patch.anchors[3][3].y ; temp[3].z=patch.anchors[3][3].z
	
		For v=0 To divs													' create the first line of points
			px = Float(v)/Float(divs)										' percent along y axis
			' use the 4 points from the derives curve To calculate the points along that curve
			Bernstein(last[v], px, temp)
		Next
		
		glNewList(patch.dlBPatch, GL_COMPILE)								' Start a New display list
		glBindTexture(GL_TEXTURE_2D, patch.texture)							' Bind the texture
		For u=1 To divs
			py = Float(u)/Float(divs)										' Percent along Y axis
			pyold = (Float(u)-1.0)/Float(divs)								' Percent along old Y axis
	
			Bernstein(temp[0], py, patch.anchors[0])				' Calculate New bezier points
			Bernstein(temp[1], py, patch.anchors[1])
			Bernstein(temp[2], py, patch.anchors[2])
			Bernstein(temp[3], py, patch.anchors[3])
	
			glBegin(GL_TRIANGLE_STRIP)										' Begin a New triangle strip
				For v=0 To divs
					px = Float(v)/Float(divs)								' Percent along the X axis
					glTexCoord2f(pyold, px)								' Apply the old texture coords
					glVertex3d(last[v].x, last[v].y, last[v].z)				' Old Point
					Bernstein(last[v], px, temp)							' Generate New point
					glTexCoord2f(py, px)									' Apply the New texture coords
					glVertex3d(last[v].x, last[v].y, last[v].z)				' New Point
				Next
			glEnd()														' End the triangle srip
		Next
		glEndList()														' End the list
	End Method
	
	Method initBezier()	
		mybezier.anchors = mybezier.anchors[..4]
		For Local j:Int=0 Until  4
			mybezier.anchors[j]= mybezier.anchors[j][..4]
		Next
		For Local i:Int = 0 Until 4
			For Local j:Int = 0 Until 4
				mybezier.anchors[i][j] = New  POINT_3D
			Next
		Next
		
		makePoint(mybezier.anchors[0][0],-0.75,	-0.75,	-0.5)				' set the bezier vertices
		makePoint(mybezier.anchors[0][1],-0.25,	-0.75,	 0.0)
		makePoint(mybezier.anchors[0][2], 0.25,	-0.75,	 0.0)
		makePoint(mybezier.anchors[0][3], 0.75,	-0.75,	-0.5)
		makePoint(mybezier.anchors[1][0],-0.75,	-0.25,	-0.75)
		makePoint(mybezier.anchors[1][1],-0.25,	-0.25,	 0.5)
		makePoint(mybezier.anchors[1][2], 0.25,	-0.25,	 0.5)
		makePoint(mybezier.anchors[1][3], 0.75,	-0.25,	-0.75)
		makePoint(mybezier.anchors[2][0],-0.75,	 0.25,	 0.0)
		makePoint(mybezier.anchors[2][1],-0.25,	 0.25,	-0.5)
		makePoint(mybezier.anchors[2][2], 0.25,	 0.25,	-0.5)
		makePoint(mybezier.anchors[2][3], 0.75,	 0.25,	 0.0)
		makePoint(mybezier.anchors[3][0],-0.75,	 0.75,	-0.5)
		makePoint(mybezier.anchors[3][1],-0.25,	 0.75,	-1.0)
		makePoint(mybezier.anchors[3][2], 0.25,	 0.75,	-1.0)
		makePoint(mybezier.anchors[3][3], 0.75,	 0.75,	-0.5)
		mybezier.dlBPatch = glGenLists(1)									' Assign a display list
	End Method 

End Type