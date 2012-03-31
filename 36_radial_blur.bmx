Strict
Import "framework.bmx"


'
' ********************************************************************
' INITIALISATION
' ********************************************************************
New TNeHe36.Run(36,"Radial Blur")


Type TNeHe36 Extends TNeHe
	Field angle:Float							' Used To Rotate The Helix
	Field vertexes:Float[4,3]						' Holds Float Info For 4 Sets Of Vertices
	Field normal:Float[3]							' An Array To Store The Normal Data
	Field BlurTexture:Int							' An Unsigned Int To Store The Texture Number
	Field Helix:Int								' Storage For The Helix Display List
	
	Field Time:Int
	
	Method Init()
		Local global_ambient:Float[]=[0.2, 0.2,  0.2, 1.0]						' Set Ambient Lighting To Fairly Dark Light (No Color)
		Local light0pos:Float[]=     [0.0, 5.0, 10.0, 1.0]						' Set The Light Position
		Local light0ambient:Float[]= [0.2, 0.2,  0.2, 1.0]						' More Ambient Light
		Local light0diffuse:Float[]= [0.3, 0.3,  0.3, 1.0]						' Set The Diffuse Light A Bit Brighter
		Local light0specular:Float[]=[0.8, 0.8,  0.5, 1.0]						' Fairly Bright Specular Lighting
		Local lmodel_ambient:Float[]=[0.2,0.2,0.2,1.0]							' And More Ambient Light	
		
		' Start Of User Initialization
		angle=0.0															' Set Starting Angle To Zero
		BlurTexture=EmptyTexture()												' Create Our Empty Texture
		BuildLists()
		
		glClearColor(0.0, 0.0, 0.0, 0.5)										' Set The Clear Color To Black
		glEnable(GL_DEPTH_TEST)												' Enable Depth Testing
		glShadeModel(GL_SMOOTH)												' Select Smooth Shading
		glMateriali(GL_FRONT, GL_SHININESS, 128)
		glEnable(GL_TEXTURE_2D)												' Enable Texture Mapping
		glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST)						' Really Nice Perspective Calculations
	
		glEnable(GL_LIGHTING)													' Enable Lighting
		glEnable(GL_LIGHT0)													' Enable Light0	
		glLightModelfv(GL_LIGHT_MODEL_AMBIENT,lmodel_ambient)						' Set The Ambient Light Model
		glLightModelfv(GL_LIGHT_MODEL_AMBIENT, global_ambient)					' Set The Global Ambient Light Model
		glLightfv(GL_LIGHT0, GL_POSITION, light0pos)								' Set The Lights Position
		glLightfv(GL_LIGHT0, GL_AMBIENT, light0ambient)							' Set The Ambient Light
		glLightfv(GL_LIGHT0, GL_DIFFUSE, light0diffuse)							' Set The Diffuse Light
		glLightfv(GL_LIGHT0, GL_SPECULAR, light0specular)						' Set Up Specular Lighting
	
		glViewport(0,0,ScreenWidth,ScreenHeight)								' Set Up A Viewport
		glMatrixMode(GL_PROJECTION)											' Select The Projection Matrix
		glLoadIdentity()														' Reset The Projection Matrix
		gluPerspective(45.0,Float(ScreenWidth)/Float(ScreenHeight),5.0,2000.0)		' Set Our Perspective
		glMatrixMode(GL_MODELVIEW)												' Select The Modelview Matrix
		glLoadIdentity()														' Reset The Modelview Matrix
	End Method
	
	' Draw The Scene
	Method Loop()	
		Local milliseconds:Int = MilliSecs()-Time

		glEnable GL_LIGHTING
		glClearColor(0.0, 0.0, 0.0, 0.5)										' Set The Clear Color To Black
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)							' Clear Screen And Depth Buffer
		glLoadIdentity()														' Reset The View	
		RenderToTexture()														' Render To A Texture
		ProcessHelix()														' Draw Our Helix
		DrawBlur(25,0.02)														' Draw The Blur Effect
		angle:+(Float(milliseconds)/5.0	)										' Update angle Based On The Clock
		Time=MilliSecs()
	End Method

	' Create An Empty Texture
	Method EmptyTexture:Int()
		Local txtnumber:Int													' Texture ID
		Local data:Byte Ptr													' Stored Data
	
		' Create Storage Space For Texture Data (128x128x4)
		data=MemAlloc(128*128*4)
		MemClear(data,128*128*4)												' Clear Storage Memory
		glGenTextures(1, Varptr txtnumber)										' Create 1 Texture
	
		glBindTexture(GL_TEXTURE_2D, txtnumber)									' Bind The Texture
		' Build Texture Using Information In data
		glTexImage2D(GL_TEXTURE_2D, 0, 4, 128, 128, 0, GL_RGBA, GL_UNSIGNED_BYTE, data)
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR)
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR)
	
		MemFree(data)												' Free memory data
		Return txtnumber														' Return The Texture ID
	End Method
	
	' Reduces A Normal Vector (3 Coordinates) To A Unit Normal Vector With A Length Of One.
	Method ReduceToUnit(vector:Float Ptr)
		Local length:Float													' Holds Unit Length
		' Calculates The Length Of The Vector
		length=Float(Sqr(vector[0]*vector[0]) + (vector[1]*vector[1]) + (vector[2]*vector[2]))
		
		If length = 0.0														' Prevents Divide By 0 Error By Providing
			length = 1.0														' An Acceptable Value For Vectors To Close To 0.
		EndIf
		vector[0]:/length														' Dividing Each Element By
		vector[1]:/length														' The Length Results In A
		vector[2]:/length														' Unit Normal Vector.
	End Method
	
	' Calculates Normal For A Quad Using 3 Points
	Method calcNormal(v:Float Ptr, out:Float Ptr)
		Local v1:Float[3], v2:Float[3]											' Vector 1 (x,y,z) & Vector 2 (x,y,z)
		Local x:Int=0	, i0:Int=0												' Define X Coord
		Local y:Int=1	, i1:Int=3												' Define Y Coord
		Local z:Int=2	, i2:Int=6												' Define Z Coord
	
		' Finds The Vector Between 2 Points By Subtracting
		' The x,y,z Coordinates From One Point To Another.
	
		' Calculate The Vector From Point 1 To Point 0
		v1[x] = v[i0+x] - v[i1+x]												' Vector 1.x=Vertex[0].x-Vertex[1].x
		v1[y] = v[i0+y] - v[i1+y]												' Vector 1.y=Vertex[0].y-Vertex[1].y
		v1[z] = v[i0+z] - v[i1+z]												' Vector 1.z=Vertex[0].y-Vertex[1].z
		' Calculate The Vector From Point 2 To Point 1
		v2[x] = v[i1+x] - v[i2+x]												' Vector 2.x=Vertex[0].x-Vertex[1].x
		v2[y] = v[i1+y] - v[i2+y]												' Vector 2.y=Vertex[0].y-Vertex[1].y
		v2[z] = v[i1+z] - v[i2+z]												' Vector 2.z=Vertex[0].z-Vertex[1].z
		' Compute The Cross Product To Give Us A Surface Normal
		out[x] = v1[y]*v2[z] - v1[z]*v2[y]										' Cross Product For Y - Z
		out[y] = v1[z]*v2[x] - v1[x]*v2[z]										' Cross Product For X - Z
		out[z] = v1[x]*v2[y] - v1[y]*v2[x]										' Cross Product For X - Y
	
		ReduceToUnit(out)														' Normalize The Vectors
	End Method
	
	'  Draws A Helix
	Method ProcessHelix()
		Local glfMaterialColor:Float[]=[0.4,0.2,0.8,1.0]							' Set The Material Color
		Local specular:Float[]=[1.0,1.0,1.0,1.0]								' Sets Up Specular Lighting	
		
		glLoadIdentity()														' Reset The Modelview Matrix
		gluLookAt(0, 5, 50, 0, 0, 0, 0, 1, 0)									' Eye Position (0,5,50) Center Of Scene (0,0,0), Up On Y Axis
		glPushMatrix()														' Push The Modelview Matrix
		glTranslatef(0,0,-50)													' Translate 50 Units Into The Screen
		glRotatef(angle/2.0,1,0,0)												' Rotate By angle/2 On The X-Axis
		glRotatef(angle/3.0,0,1,0)												' Rotate By angle/3 On The Y-Axis
		
		glMaterialfv(GL_FRONT_AND_BACK,GL_AMBIENT_AND_DIFFUSE,glfMaterialColor)
		glMaterialfv(GL_FRONT_AND_BACK,GL_SPECULAR,specular)
		glCallList(Helix)
		
		glPopMatrix()															' Pop The Matrix
	End Method
	
	' Set Up An Ortho View
	Method ViewOrtho()
		glMatrixMode(GL_PROJECTION)											' Select Projection
		glPushMatrix()														' Push The Matrix
		glLoadIdentity()														' Reset The Matrix
		glOrtho(0, ScreenWidth, ScreenHeight, 0, -1, 1)							' Select Ortho Mode (640x480)
		glMatrixMode(GL_MODELVIEW)												' Select Modelview Matrix
		glPushMatrix()														' Push The Matrix
		glLoadIdentity()														' Reset The Matrix
	End Method
	
	' Set Up A Perspective View
	Method ViewPerspective()
		glMatrixMode(GL_PROJECTION)											' Select Projection
		glPopMatrix()															' Pop The Matrix
		glMatrixMode(GL_MODELVIEW)												' Select Modelview
		glPopMatrix()															' Pop The Matrix
	End Method
	
	' Renders To A Texture
	Method RenderToTexture()
		glViewport(0,0,128,128)												' Set Our Viewport (Match Texture Size)
		ProcessHelix()														' Render The Helix
		glBindTexture(GL_TEXTURE_2D,BlurTexture)								' Bind To The Blur Texture
		' Copy Our ViewPort To The Blur Texture (From 0,0 To 128,128... No Border)
		glCopyTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, 0, 0, 128, 128, 0)
		glClearColor(0.0, 0.0, 0.5, 0.5)										' Set The Clear Color To Medium Blue
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)						' Clear The Screen And Depth Buffer
		glViewport(0, 0, ScreenWidth, ScreenHeight)								' Set Viewport (0,0 To ScreenWidth,ScreenHeight)
	End Method
	
	' Draw The Blurred Image
	Method DrawBlur(times:Int, inc:Float)
		Local spost:Float=0.0													' Starting Texture Coordinate Offset
		Local alphainc:Float=0.9/Float(times)									' Fade Speed For Alpha Blending
		Local alpha:Float=0.2													' Starting Alpha Value
	
		' Disable AutoTexture Coordinates
		glDisable(GL_TEXTURE_GEN_S)
		glDisable(GL_TEXTURE_GEN_T)
	
		glEnable(GL_TEXTURE_2D)												' Enable 2D Texture Mapping
		glDisable(GL_DEPTH_TEST)												' Disable Depth Testing
		glBlendFunc(GL_SRC_ALPHA,GL_ONE)										' Set Blending Mode
		glEnable(GL_BLEND)													' Enable Blending
		glBindTexture(GL_TEXTURE_2D,BlurTexture)								' Bind To The Blur Texture
		ViewOrtho()															' Switch To An Ortho View
	
		alphainc=alpha/Float(times)											' alphainc=0.2 / Times To Render Blur
		glBegin(GL_QUADS)														' Begin Drawing Quads
			For Local num:Int=0 Until times										' Number Of Times To Render Blur
				glColor4f(1.0, 1.0, 1.0, alpha)									' Set The Alpha Value (Starts At 0.2)
				glTexCoord2f(0+spost,1-spost)									' Texture Coordinate (0,1)
				glVertex2f(0,0)												' First Vertex (0,0)
	
				glTexCoord2f(0+spost,0+spost)									' Texture Coordinate(0,0)
				glVertex2f(0,ScreenHeight)										' Second Vertex(0,ScreenHeight)
				glTexCoord2f(1-spost,0+spost)									' Texture Coordinate(1,0)
	
				glVertex2f(ScreenWidth,ScreenHeight)							' Third Vertex(ScreenWidth,ScreenHeight)
				glTexCoord2f(1-spost,1-spost)									' Texture Coordinate(1,1)
				glVertex2f(ScreenWidth,0)										' Fourth Vertex(ScreenWidth,0)
	
				spost:+inc													' Gradually Increase spost (Zooming Closer To Texture Center)
				alpha=alpha-alphainc											' Gradually Decrease alpha (Gradually Fading Image Out)
			Next
		glEnd()																' Done Drawing Quads
	
		ViewPerspective()														' Switch To A Perspective View
		glEnable(GL_DEPTH_TEST)												' Enable Depth Testing
		glDisable(GL_TEXTURE_2D)												' Disable 2D Texture Mapping
		glDisable(GL_BLEND)													' Disable Blending
		glBindTexture(GL_TEXTURE_2D,0)											' Unbind The Blur Texture
	End Method
	
	' Build Helix Display Lists
	Method BuildLists()
		Local x:Float															' Helix x Coordinate
		Local y:Float															' Helix y Coordinate
		Local z:Float															' Helix z Coordinate
		Local phi:Float														' Angle
		Local theta:Float														' Angle
		Local v:Float, u:Float													' Angles
		Local r:Float															' Radius Of Twist
		Local twists:Int=5													' 5 Twists
		Local pi2:Float=2.0*Pi
	
		r=1.5
		Helix=glGenLists(1)													' Generate 1 List
		glNewList(Helix,GL_COMPILE)											' Start The Helix List
			glBegin(GL_QUADS)													' Begin Drawing Quads
			For phi=0.0 To 360.0 Step 20.0										' 360 Degrees In Steps Of 20
				For theta=0.0 To 360.0*Float(twists) Step 20.0					' 360 Degrees * Number Of Twists In Steps Of 20
					v=phi													' Calculate Angle Of First Point (0)
					u=theta													' Calculate Angle Of First Point (0)
					x=Float(Cos(u)*(2.0+Cos(v)))*r								' Calculate x Position (1st Point)
					y=Float(Sin(u)*(2.0+Cos(v)))*r								' Calculate y Position (1st Point)
					z=Float((((u/180.0*Pi)-pi2)+Sin(v))*r)						' Calculate z Position (1st Point)
					vertexes[0,0]=x											' Set x Value Of First Vertex
					vertexes[0,1]=y											' Set y Value Of First Vertex
					vertexes[0,2]=z											' Set z Value Of First Vertex
	
					v=phi													' Calculate Angle Of Second Point ( 0)
					u=theta+20.0												' Calculate Angle Of Second Point (20)
					x=Float(Cos(u)*(2.0+Cos(v)))*r								' Calculate x Position (2nd Point)
					y=Float(Sin(u)*(2.0+Cos(v)))*r								' Calculate y Position (2nd Point)
					z=Float((((u/180.0*Pi)-pi2)+Sin(v))*r)						' Calculate z Position (2nd Point)
					vertexes[1,0]=x											' Set x Value Of Second Vertex
					vertexes[1,1]=y											' Set y Value Of Second Vertex
					vertexes[1,2]=z											' Set z Value Of Second Vertex
	
					v=phi+20.0												' Calculate Angle Of Third Point (20)
					u=theta+20.0												' Calculate Angle Of Third Point (20)
					x=Float(Cos(u)*(2.0+Cos(v)))*r								' Calculate x Position (3rd Point)
					y=Float(Sin(u)*(2.0+Cos(v)))*r								' Calculate y Position (3rd Point)
					z=Float((((u/180.0*Pi)-pi2)+Sin(v))*r)						' Calculate z Position (3rd Point)
					vertexes[2,0]=x											' Set x Value Of Third Vertex
					vertexes[2,1]=y											' Set y Value Of Third Vertex
					vertexes[2,2]=z											' Set z Value Of Third Vertex
	
					v=phi+20.0												' Calculate Angle Of Fourth Point (20)
					u=theta													' Calculate Angle Of Fourth Point ( 0)
					x=Float(Cos(u)*(2.0+Cos(v)))*r								' Calculate x Position (4th Point)
					y=Float(Sin(u)*(2.0+Cos(v)))*r								' Calculate y Position (4th Point)
					z=Float((((u/180.0*Pi)-pi2)+Sin(v))*r)						' Calculate z Position (4th Point)			
					vertexes[3,0]=x											' Set x Value Of Fourth Vertex
					vertexes[3,1]=y											' Set y Value Of Fourth Vertex
					vertexes[3,2]=z											' Set z Value Of Fourth Vertex
				
					calcNormal(Varptr vertexes[0,0], Varptr normal[0])			' Calculate The Quad Normal
					glNormal3f(normal[0],normal[1],normal[2])					' Set The Normal
	
					' Render The Quad
					glVertex3f(vertexes[0,0],vertexes[0,1],vertexes[0,2])
					glVertex3f(vertexes[1,0],vertexes[1,1],vertexes[1,2])
					glVertex3f(vertexes[2,0],vertexes[2,1],vertexes[2,2])
					glVertex3f(vertexes[3,0],vertexes[3,1],vertexes[3,2])
				Next
			Next
			glEnd()															' Done Rendering Quads	glEndList()
		glEndList()
	End Method
End Type

