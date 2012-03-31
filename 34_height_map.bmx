Strict
Import "framework.bmx"

New TNeHe34.Run(34,"Height Map")

Type TNeHe34 Extends TNeHe
	Field bRender:Byte=True								' Polygon Flag Set To True By Default (New)
	Field g_HeightMap:Byte[MAP_SIZE*MAP_SIZE]				' Holds The Height Map Data (New)
	Field scaleValue:Float=0.15							' Scale Value For The Terrain (New)
	
	Field ShowMenu:Int
	
	Const MAP_SIZE:Int=1024								' Size Of Our .RAW Height Map (New)
	Const STEP_SIZE:Int=16									' Width And Height Of Each Quad (New)
	Const HEIGHT_RATIO:Float=1.5							' Ratio That The Y Is Scaled According To The X And Z (New)
	
	Method Init()
		glShadeModel(GL_SMOOTH)												' Enable Smooth Shading
		glClearColor(0.5, 0.5, 0.5, 0.5)										' Black Background
		glClearDepth(1.0)														' Depth Buffer Setup
		glEnable(GL_DEPTH_TEST)												' Enables Depth Testing
		glDepthFunc(GL_LEQUAL)													' The Type Of Depth Testing To Do
		glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST)						' Really Nice Perspective Calculations
	
		glViewport(0,0,ScreenWidth,ScreenHeight)								' Set viewport
		glMatrixMode(GL_PROJECTION)											' Select The Projection Matrix
		glLoadIdentity()														' Reset The Projection Matrix
		gluPerspective(45.0,Float(ScreenWidth)/Float(ScreenHeight),0.1,500.0)		' Calculate The Aspect Ratio Of The Window
		glMatrixMode(GL_MODELVIEW)												' Select The Modelview Matrix
		glLoadIdentity()	
		
		g_HeightMap=LoadRawFile("Data/Terrain.raw", MAP_SIZE * MAP_SIZE, g_HeightMap)
	End Method
	
	Method Loop()
		If KeyHit(KEY_F1) Then ShowMenu=Not ShowMenu
		If KeyDown(KEY_UP) Then												' Is the UP ARROW key Being Pressed?
			scaleValue :+ 0.001												' Increase the scale value To zoom in
		EndIf
		If KeyDown(KEY_DOWN) Then												' Is the DOWN ARROW key Being Pressed?
			scaleValue :- 0.001												' Decrease the scale value To zoom out
			If scaleValue<0.0 Then scaleValue=0
		EndIf
		If MouseHit(1) Then													' Did We Receive A Left Mouse Click?
			bRender = Not bRender												' Change The Rendering State Between Fill And Wire Frame
		EndIf
		
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)						' Clear The Screen And The Depth Buffer
		glLoadIdentity()														' Reset The Matrix
		'           Position        View      Up Vector
		gluLookAt(212, 60, 194,  186, 55, 171,  0, 1, 0)							' This Determines Where The Camera's Position And View Is
		glScalef(scaleValue, scaleValue * HEIGHT_RATIO, scaleValue)
		RenderHeightMap(g_HeightMap)											' Render The Height Map
		DrawMenu()
	End Method
	
	' Loads The .RAW File And Stores It In pHeightMap
	Method LoadRawFile:Array(filename:String, nSize:Int, pHeightMap:Byte[] Var)
		' Open The File In Read / Binary Mode.
		Local File:TStream = OpenFile(filename)
		' Check To See If We Found The File And Could Open It
		If File = Null Then	
			' Display Error Message And Stop The method
			Notify("Can't Find The Height Map!", True)
			Return Null
		EndIf
		pHeightMap = LoadByteArray(File)
		CloseStream(File)
		Return pHeightMap
	End Method
	
	' This Renders The Height Map As Quads
	Method RenderHeightMap(pHeightMap:Byte[] Var)
		Local xx:Int=0, yy:Int=0								' Create Some Variables To Walk The Array With.
		Local x:Int, y:Int, z:Int								' Create Some Variables For Readability
		Local fcolor:Float
	
		If bRender Then										' What We Want To Render
			glBegin(GL_QUADS)									' Render Polygons
		Else
			glBegin(GL_LINES)									' Render Lines Instead
		EndIf
		For xx=0 Until (MAP_SIZE-STEP_SIZE) Step STEP_SIZE
			For yy=0 Until (MAP_SIZE-STEP_SIZE) Step STEP_SIZE
				' Get The (X, Y, Z) Value For The Bottom Left Vertex
				x = xx
				y = pHeightMap[xx + (yy * MAP_SIZE)] 'Height(Varptr pHeightMap, xx, yy)
				z = yy
				' Set The Color Value Of The Current Vertex
				fColor=-0.15 + (pHeightMap[x+(y*MAP_SIZE)] / 256.0)
				glColor3f(0, 0, fColor)
				glVertex3i(x, y, z)							' Send This Vertex To OpenGL To Be Rendered (Integer Points Are Faster)
	
				' Get The (X, Y, Z) Value For The Top Left Vertex
				x = xx
				y = pHeightMap[xx + ((yy+STEP_SIZE) * MAP_SIZE)] 'Height(Varptr pHeightMap, xx, yy + STEP_SIZE)
				z = yy + STEP_SIZE
				' Set The Color Value Of The Current Vertex
				fColor=-0.15 + (pHeightMap[x+(y*MAP_SIZE)] / 256.0)
				glColor3f(0, 0, fColor)
				glVertex3i(x, y, z)							' Send This Vertex To OpenGL To Be Rendered
	
				' Get The (X, Y, Z) Value For The Top Right Vertex
				x = xx + STEP_SIZE
				y = pHeightMap[(xx+STEP_SIZE) + ((yy+STEP_SIZE) * MAP_SIZE)] 'Height(Varptr pHeightMap, xx+STEP_SIZE, yy+STEP_SIZE)
				z = yy + STEP_SIZE
				' Set The Color Value Of The Current Vertex
				fColor=-0.15 + (pHeightMap[x+(y*MAP_SIZE)] / 256.0)
				glColor3f(0, 0, fColor)
				glVertex3i(x, y, z)							' Send This Vertex To OpenGL To Be Rendered
	
				' Get The (X, Y, Z) Value For The Bottom Right Vertex
				x = xx + STEP_SIZE;
				y = pHeightMap[(xx+STEP_SIZE) + (yy * MAP_SIZE)] 'Height(Varptr pHeightMap, xx+STEP_SIZE, yy)
				z = yy
				' Set The Color Value Of The Current Vertex
				fColor=-0.15 + (pHeightMap[x+(y*MAP_SIZE)] / 256.0)
				glColor3f(0, 0, fColor)
				glVertex3i(x, y, z)							' Send This Vertex To OpenGL To Be Rendered
			Next
		Next
		glEnd()
		glColor4f(1.0, 1.0, 1.0, 1.0)							' Reset The Color
	End Method
	
	Method DrawMenu()
		glDisable(GL_DEPTH_TEST)
		glColor3f(1.0,1.0,1.0)
		GLDrawText("F1 : Hide/Show menu",10,ScreenHeight-16-8)
		If ShowMenu Then
			GLDrawText("NeHe & Ben Humphrey's Height Map Tutorial (lesson 34)",10,24)
			GLDrawText("'UP'           Zoom in ",10,56)
			GLDrawText("'DOWN'         Zoom out",10,72)
			GLDrawText("'MOUSE LEFT'   Change render mode",10,88)
		EndIf
		glEnable(GL_DEPTH_TEST)
	End Method
End Type