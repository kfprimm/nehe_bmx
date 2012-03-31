SuperStrict

Import "object.bmx"									' Header File For 3D Object Handling

Global ScreenWidth:Int=800
Global ScreenHeight:Int=600
Global ScreenDepth:Int=32

Global obj:glObject=New glObject						' Object
Global xrot:Float										' X Rotation
Global yrot:Float										' Y Rotation
Global xspeed:Float									' X Speed
Global yspeed:Float									' Y Speed

Global LightPos:Float[]=[ 0.0, 5.0,-4.0, 1.0]			' Light Position
Global LightAmb:Float[]=[ 0.2, 0.2, 0.2, 1.0]			' Ambient Light Values
Global LightDif:Float[]=[ 0.6, 0.6, 0.6, 1.0]			' Diffuse Light Values
Global LightSpc:Float[]=[-0.2,-0.2,-0.2, 1.0]			' Specular Light Values

Global MatAmb:Float[]=[0.4, 0.4, 0.4, 1.0]				' Material - Ambient Values
Global MatDif:Float[]=[0.2, 0.6, 0.9, 1.0]				' Material - Diffuse Values
Global MatSpc:Float[]=[0.0, 0.0, 0.0, 1.0]				' Material - Specular Values
Global MatShn:Float[]=[0.0]							' Material - Shininess

Global ObjPos:Float[]=[-2.0,-2.0,-5.0]					' Object Position

Global q:Int Ptr										' Quadratic For Drawing A Sphere
Global SpherePos:Float[]=[-4.0,-5.0,-6.0]
Global ShowMenu:Int

GLGraphics(ScreenWidth,ScreenHeight)

InitGl()

ShowMenu:Int=0
While Not KeyHit( KEY_ESCAPE )
	If KeyHit(KEY_F1) Then ShowMenu=Not ShowMenu
	nehe27()
	'--------------------------------------------------------
	DrawMenu(ShowMenu)
	Flip
Wend
End

Function InitGl()
	If Not InitGLObjects() Then Return							' Function For Initializing Our Object(s)
	glShadeModel(GL_SMOOTH)											' Enable Smooth Shading
	glClearColor(0.0, 0.0, 0.0, 0.5)									' Black Background
	glClearDepth(1.0)													' Depth Buffer Setup
	glClearStencil(0)													' Stencil Buffer Setup
	glEnable(GL_DEPTH_TEST)											' Enables Depth Testing
	glDepthFunc(GL_LEQUAL)												' The Type Of Depth Testing To Do
	glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST)					' Really Nice Perspective Calculations

	glLightfv(GL_LIGHT1, GL_POSITION, LightPos)							' Set Light1 Position
	glLightfv(GL_LIGHT1, GL_AMBIENT, LightAmb)							' Set Light1 Ambience
	glLightfv(GL_LIGHT1, GL_DIFFUSE, LightDif)							' Set Light1 Diffuse
	glLightfv(GL_LIGHT1, GL_SPECULAR, LightSpc)							' Set Light1 Specular
	glEnable(GL_LIGHT1)												' Enable Light1
	glEnable(GL_LIGHTING)												' Enable Lighting

	glMaterialfv(GL_FRONT, GL_AMBIENT, MatAmb)							' Set Material Ambience
	glMaterialfv(GL_FRONT, GL_DIFFUSE, MatDif)							' Set Material Diffuse
	glMaterialfv(GL_FRONT, GL_SPECULAR, MatSpc)							' Set Material Specular
	glMaterialfv(GL_FRONT, GL_SHININESS, MatShn)							' Set Material Shininess

	glCullFace(GL_BACK)												' Set Culling Face To Back Face
	glEnable(GL_CULL_FACE)												' Enable Culling
	glClearColor(0.1, 1.0, 0.5, 1.0)									' Set Clear Color (Greenish Color)

	q=Int Ptr gluNewQuadric()											' Initialize Quadratic
	gluQuadricNormals(q, GL_SMOOTH)										' Enable Smooth Normal Generation
	gluQuadricTexture(q, GL_FALSE)										' Disable Auto Texture Coords

	glViewport(0,0,ScreenWidth,ScreenHeight)							' Set viewport
	glMatrixMode(GL_PROJECTION)										' Select The Projection Matrix
	glLoadIdentity()													' Reset The Projection Matrix
	gluPerspective(45.0,Float(ScreenWidth)/Float(ScreenHeight),0.001,100.0)	' Calculate The Aspect Ratio Of The Window
	glMatrixMode(GL_MODELVIEW)											' Select The Modelview Matrix
	glLoadIdentity()
End Function

Function nehe27()
	Local Minv:Float[16]
	Local lp:Float[4]
	Local wlp:Float[4]
	
	ProcessKeyboard()

	' Clear Color Buffer, Depth Buffer, Stencil Buffer
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT)
	
	glLoadIdentity()													' Reset Modelview Matrix
	glTranslatef(0.0, 0.0, -20.0)										' Zoom Into Screen 20 Units
	glLightfv(GL_LIGHT1, GL_POSITION, LightPos)							' Position Light1
	glTranslatef(SpherePos[0], SpherePos[1], SpherePos[2])				' Position The Sphere
	gluSphere(q, 1.5, 32, 16)											' Draw A Sphere

	' calculate light's position relative to local coordinate system
	' dunno If this is the best way To do it, but it actually works
	' If u find another aproach, let me know ;)

	' we build the inversed matrix by doing all the actions in reverse order
	' And with reverse parameters (notice -xrot, -yrot, -ObjPos[], etc.)
	glLoadIdentity()													' Reset Matrix
	glRotatef(-yrot, 0.0, 1.0, 0.0)										' Rotate By -yrot On Y Axis
	glRotatef(-xrot, 1.0, 0.0, 0.0)										' Rotate By -xrot On X Axis
	glGetFloatv(GL_MODELVIEW_MATRIX,Minv)								' Retrieve ModelView Matrix (Stores In Minv)
	lp[0] = LightPos[0]												' Store Light Position X In lp[0]
	lp[1] = LightPos[1]												' Store Light Position Y In lp[1]
	lp[2] = LightPos[2]												' Store Light Position Z In lp[2]
	lp[3] = LightPos[3]												' Store Light Direction In lp[3]
	VMatMult(Varptr Minv[0], Varptr lp[0])								' We Store Rotated Light Vector In 'lp' Array
	glTranslatef(-ObjPos[0], -ObjPos[1], -ObjPos[2])						' Move Negative On All Axis Based On ObjPos[] Values (X, Y, Z)
	glGetFloatv(GL_MODELVIEW_MATRIX,Minv)								' Retrieve ModelView Matrix From Minv
	wlp[0] = 0.0														' World Local Coord X To 0
	wlp[1] = 0.0														' World Local Coord Y To 0
	wlp[2] = 0.0														' World Local Coord Z To 0
	wlp[3] = 1.0
	VMatMult(Varptr Minv[0], Varptr wlp[0])								' We Store The Position Of The World Origin Relative To The
																	' Local Coord. System In 'wlp' Array
	lp[0] :+ wlp[0]													' Adding These Two Gives Us The
	lp[1] :+ wlp[1]													' Position Of The Light Relative To
	lp[2] :+ wlp[2]													' The Local Coordinate System

	glColor4f(0.7, 0.4, 0.0, 1.0)										' Set Color To An Orange
	glLoadIdentity()													' Reset Modelview Matrix
	glTranslatef(0.0, 0.0, -20.0)										' Zoom Into The Screen 20 Units
	DrawGLRoom()														' Draw The Room
	glTranslatef(ObjPos[0], ObjPos[1], ObjPos[2])						' Position The Object
	glRotatef(xrot, 1.0, 0.0, 0.0)										' Spin It On The X Axis By xrot
	glRotatef(yrot, 0.0, 1.0, 0.0)										' Spin It On The Y Axis By yrot
	DrawGLObject(obj)													' Procedure For Drawing The Loaded Object
	CastShadow(obj, Varptr lp[0])										' Procedure For Casting The Shadow Based On The Silhouette

	glColor4f(0.7, 0.4, 0.0, 1.0)										' Set Color To Purplish Blue
	glDisable(GL_LIGHTING)												' Disable Lighting
	glDepthMask(GL_FALSE)												' Disable Depth Mask
	glTranslatef(lp[0], lp[1], lp[2])									' Translate To Light's Position
																	' Notice We're Still In Local Coordinate System
	gluSphere(q, 0.2, 16, 8)											' Draw A Little Yellow Sphere (Represents Light)
	glEnable(GL_LIGHTING)												' Enable Lighting
	glDepthMask(GL_TRUE)												' Enable Depth Mask

	xrot :+ xspeed													' Increase xrot By xspeed
	yrot :+ yspeed													' Increase yrot By yspeed
End Function

Function VMatMult(M:Float Ptr, v:Float Ptr)
	Local res:Float[4]												' Hold Calculated Results
	res[0]=M[ 0]*v[0]+M[ 4]*v[1]+M[ 8]*v[2]+M[12]*v[3]
	res[1]=M[ 1]*v[0]+M[ 5]*v[1]+M[ 9]*v[2]+M[13]*v[3]
	res[2]=M[ 2]*v[0]+M[ 6]*v[1]+M[10]*v[2]+M[14]*v[3]
	res[3]=M[ 3]*v[0]+M[ 7]*v[1]+M[11]*v[2]+M[15]*v[3]
	v[0]=res[0]														' Results Are Stored Back In v[]
	v[1]=res[1]
	v[2]=res[2]
	v[3]=res[3]														' Homogenous Coordinate
End Function

Function InitGLObjects:Int()												' Initialize Objects
	' Here you can send "Objet.txt", "Object1.txt" or "Object2.txt"
	If Not ReadObject("Data/Object2.txt", obj) Then						' Read Object2 Into obj
		Return False													' If Failed Return False
	EndIf
	SetConnectivity(obj)												' Set Face To Face Connectivity
	CalcPlane(obj)													' Compute Plane Equations For All Faces
	Return True														' Return True
End Function

Function DrawGLRoom()													' Draw The Room (Box)
	glBegin(GL_QUADS)													' Begin Drawing Quads
		' Floor
		glNormal3f(0.0, 1.0, 0.0)										' Normal Pointing Up
		glVertex3f(-10.0,-10.0,-20.0)									' Back Left
		glVertex3f(-10.0,-10.0, 20.0)									' Front Left
		glVertex3f( 10.0,-10.0, 20.0)									' Front Right
		glVertex3f( 10.0,-10.0,-20.0)									' Back Right
		' Ceiling
		glNormal3f(0.0,-1.0, 0.0)										' Normal Point Down
		glVertex3f(-10.0, 10.0, 20.0)									' Front Left
		glVertex3f(-10.0, 10.0,-20.0)									' Back Left
		glVertex3f( 10.0, 10.0,-20.0)									' Back Right
		glVertex3f( 10.0, 10.0, 20.0)									' Front Right
		' Front Wall
		glNormal3f(0.0, 0.0, 1.0)										' Normal Pointing Away From Viewer
		glVertex3f(-10.0, 10.0,-20.0)									' Top Left
		glVertex3f(-10.0,-10.0,-20.0)									' Bottom Left
		glVertex3f( 10.0,-10.0,-20.0)									' Bottom Right
		glVertex3f( 10.0, 10.0,-20.0)									' Top Right
		' Back Wall
		glNormal3f(0.0, 0.0,-1.0)										' Normal Pointing Towards Viewer
		glVertex3f( 10.0, 10.0, 20.0)									' Top Right
		glVertex3f( 10.0,-10.0, 20.0)									' Bottom Right
		glVertex3f(-10.0,-10.0, 20.0)									' Bottom Left
		glVertex3f(-10.0, 10.0, 20.0)									' Top Left
		' Left Wall
		glNormal3f(1.0, 0.0, 0.0)										' Normal Pointing Right
		glVertex3f(-10.0, 10.0, 20.0)									' Top Front
		glVertex3f(-10.0,-10.0, 20.0)									' Bottom Front
		glVertex3f(-10.0,-10.0,-20.0)									' Bottom Back
		glVertex3f(-10.0, 10.0,-20.0)									' Top Back
		' Right Wall
		glNormal3f(-1.0, 0.0, 0.0)										' Normal Pointing Left
		glVertex3f( 10.0, 10.0,-20.0)									' Top Back
		glVertex3f( 10.0,-10.0,-20.0)									' Bottom Back
		glVertex3f( 10.0,-10.0, 20.0)									' Bottom Front
		glVertex3f( 10.0, 10.0, 20.0)									' Top Front
	glEnd()															' Done Drawing Quads
End Function

Function ProcessKeyboard()												' Process Key Presses
	' Spin Object
	If KeyDown(KEY_LEFT) Then yspeed:-0.1								' 'Arrow Left' Decrease yspeed
	If KeyDown(KEY_RIGHT) Then yspeed:+0.1								' 'Arrow Right' Increase yspeed
	If KeyDown(KEY_UP) Then xspeed:-0.1									' 'Arrow Up' Decrease xspeed
	If KeyDown(KEY_DOWN) Then xspeed:+0.1								' 'Arrow Down' Increase xspeed

	' Adjust Light's Position
	If KeyDown(KEY_L) Then LightPos[0]:+0.05							' 'L' Moves Light Right
	If KeyDown(KEY_J) Then LightPos[0]:-0.05							' 'J' Moves Light Left

	If KeyDown(KEY_I) Then LightPos[1]:+0.05							' 'I' Moves Light Up
	If KeyDown(KEY_K) Then LightPos[1]:-0.05							' 'K' Moves Light Down

	If KeyDown(KEY_O) Then LightPos[2]:+0.05							' 'O' Moves Light Toward Viewer
	If KeyDown(KEY_U) Then LightPos[2]:-0.05							' 'U' Moves Light Away From Viewer

	' Adjust Object's Position
	If KeyDown(KEY_NUM6) Then ObjPos[0]:+0.05							' 'Numpad6' Move Object Right
	If KeyDown(KEY_NUM4) Then ObjPos[0]:-0.05							' 'Numpad4' Move Object Left

	If KeyDown(KEY_NUM8) Then ObjPos[1]:+0.05							' 'Numpad8' Move Object Up
	If KeyDown(KEY_NUM2) Then ObjPos[1]:-0.05							' 'Numpad2' Move Object Down

	If KeyDown(KEY_NUM9) Then ObjPos[2]:+0.05							' 'Numpad9' Move Object Toward Viewer
	If KeyDown(KEY_NUM7) Then ObjPos[2]:-0.05							' 'Numpad7' Move Object Away From Viewer

	' Adjust Ball's Position
	If KeyDown(KEY_D) Then SpherePos[0]:+0.05							' 'D' Move Ball Right
	If KeyDown(KEY_A) Then SpherePos[0]:-0.05							' 'A' Move Ball Left

	If KeyDown(KEY_W) Then SpherePos[1]:+0.05							' 'W' Move Ball Up
	If KeyDown(KEY_S) Then SpherePos[1]:-0.05							' 'S' Move Ball Down

	If KeyDown(KEY_E) Then SpherePos[2]:+0.05							' 'E' Move Ball Toward Viewer
	If KeyDown(KEY_Q) Then SpherePos[2]:-0.05							' 'Q' Move Ball Away From Viewer
End Function

Function DrawMenu(ShowMenu:Int)
	glDisable(GL_DEPTH_TEST)	
	glDisable(GL_LIGHT1)
	glDisable(GL_LIGHTING)
	glColor3f(1.0,1.0,1.0)
	GLDrawText("F1 : Hide/Show menu",10,ScreenHeight-16-8)
	If ShowMenu Then
		GLDrawText("Banu Octavian & NeHe's Shadow Casting Tutorial (lesson 27)",10,24)
		GLDrawText("'LEFT'  Decrease Y speed",10,56)
		GLDrawText("'RIGHT' Increase Y speed",10,72)
		GLDrawText("'UP'    Decrease X speed",10,88)
		GLDrawText("'DOWN'  Increase X speed",10,104)	

		GLDrawText("'L'     Move light right",10,120)
		GLDrawText("'J'     Move light left",10,136)	
		GLDrawText("'I'     Move light up",10,152)
		GLDrawText("'K'     Move light down",10,168)		
		GLDrawText("'O'     Move light toward viewer",10,184)
		GLDrawText("'U'     Move light away from viewer",10,200)

		GLDrawText("'Pad 6' Move object right",10,216)
		GLDrawText("'Pad 4' Move object left",10,232)	
		GLDrawText("'Pad 8' Move object up",10,248)
		GLDrawText("'Pad 2' Move object down",10,264)		
		GLDrawText("'Pad 9' Move object toward viewer",10,280)
		GLDrawText("'Pad 7' Move object away from viewer",10,296)

		GLDrawText("'D'     Move ball right",10,312)
		GLDrawText("'A'     Move ball left",10,328)	
		GLDrawText("'W'     Move ball up",10,344)
		GLDrawText("'S'     Move ball down",10,360)		
		GLDrawText("'E'     Move ball toward viewer",10,376)
		GLDrawText("'Q'     Move ball away from viewer",10,392)
	EndIf
	glEnable(GL_LIGHTING)
	glEnable(GL_LIGHT1)
	glEnable(GL_DEPTH_TEST)
End Function
