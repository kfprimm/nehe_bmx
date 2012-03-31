Strict

'**************************************************************************
'  Class Physics  
'  Prepared by Erkin Tunca For http://nehe.gamedev.net
'  Updated to BlitzMax by Extron
'**************************************************************************
' ************************************************************************
' CLASS
' ************************************************************************
'
' ************************************************************************
' Class Vector3D ---> An Object To represent a 3D vector Or a 3D point in space
' ************************************************************************
Import "framework.bmx"

New TNeHe39.Run(39,"Physics")

Type Vector3D
	Field x:Float										' the x value of this Vector3D
	Field y:Float										' the y value of this Vector3D
	Field z:Float										' the z value of this Vector3D

	' Constructor To set x = y = z = 0
	Method New()
		x=0.0 ; y=0.0 ; z=0.0
	End Method

	' Constructor that initializes this Vector3D To the intended values of x, y And z
	Function Constructor:Vector3D(a:Float, b:Float, c:Float)
		Local result:Vector3D=New Vector3D
		result.x=a ; result.y=b ; result.z=c
		Return result
	End Function

	' Operator= sets values of v To this Vector3D. example: v1 = v2 means that values of v2 are set onto v1
	Method Equal:Vector3D(v:Vector3D)
		x=v.x ; y=v.y ; z=v.z
	End Method

	' Operator+ is used To add two Vector3D's. operator+ returns a new Vector3D
	Method Add:Vector3D(v:Vector3D)
		Local result:Vector3D=New Vector3D
		result.x=x+v.x ; result.y=y+v.y ; result.z=z+v.z
		Return result
	End Method

	' Operator- is used To take difference of two Vector3D's. operator- returns a new Vector3D
	Method Sub:Vector3D(v:Vector3D)
		Local result:Vector3D=New Vector3D
		result.x=x-v.x ; result.y=y-v.y ; result.z=z-v.z
		Return result
	End Method

	' Operator* is used To scale a Vector3D by a value. This value multiplies the Vector3D's x, y and z.
	Method Mult:Vector3D(value:Float)
		Local result:Vector3D=New Vector3D
		result.x=x*value ; result.y=y*value ; result.z=z*value
		Return result
	End Method

	' Operator/ is used To scale a Vector3D by a value. This value divides the Vector3D's x, y and z.
	Method Div:Vector3D(value:Float)
		Local result:Vector3D=New Vector3D
		result.x=x/value ; result.y=y/value ; result.z=z/value
		Return result
	End Method
	
	' Operator+= is used To add another Vector3D To this Vector3D.
	Method AddEqual:Vector3D(v:Vector3D)
		x:+v.x ; y:+v.y ; z:+v.z
		Return Self
	End Method
	
	' Operator-= is used To subtract another Vector3D from this Vector3D.
	Method SubEqual:Vector3D(v:Vector3D)
		x:-v.x ; y:-v.y ; z:-v.z
		Return Self
	End Method

	' Operator*= is used To scale this Vector3D by a value.
	Method MultEqual:Vector3D(value:Float)
		x:*value ; y:*value ; z:*value
		Return Self
	End Method

	' Operator/= is used To scale this Vector3D by a value.
	Method DivEqual:Vector3D(value:Float)
		x:/value ; y:/value ; z:/value
		Return Self
	End Method
	
	' Operator- is used To set this Vector3D's x, y, and z to the negative of them.
	Method Negat:Vector3D()
		Local result:Vector3D=New Vector3D
		result.x=-x ; result.y=-y ; result.z=-z
		Return result
	End Method

	' Length() returns the length of this Vector3D
	Method Length:Float()
		Return Float(Sqr(x*x + y*y + z*z))
	End Method
	
	' Unitize() normalizes this Vector3D that its direction remains the same but its length is 1.   		
	Method Unitize()
		Local length:Float=Self.Length()
		If length=0.0 Then Return
		x:/length ; y:/length ; z:/length
	End Method

	' Unit() returns a New Vector3D. The returned value is a unitized version of this Vector3D.
	Method Unit:Vector3D()
		Local length:Float=Self.Length()
		If length=0.0 Then Return Self
		Local result:Vector3D=New Vector3D
		result.x=x/length ; result.y=y/length ; result.z=z/length
		Return result
	End Method
End Type
'
' ************************************************************************
' Class Mass ---> An Object To represent a mass
' ************************************************************************
Type Mass
	Field m:Float										' The mass value
	Field pos:Vector3D=New Vector3D						' Position in space
	Field vel:Vector3D=New Vector3D						' Velocity
	Field force:Vector3D=New Vector3D					' Force applied on this mass at an instance

	' Constructor
	Method Mass(m:Float)
		Self.m=m
	End Method

	' ApplyForce(Vector3D force) Method is used To add external force To the mass. 
	' At an instance in time, several sources of force might affect the mass. The vector sum 
	' of these forces make up the net force applied To the mass at the instance.
	Method ApplyForce(f:Vector3D)
		force.AddEqual(f)								' The external force is added To the force of the mass
	End Method

	' Init() Method sets the force values To zero
	Method Init()
		force.x=0 ; force.y=0 ; force.z=0
	End Method

	' Simulate(Float dt) Method calculates the New velocity And New position of 
	' the mass according To change in time (dt). Here, a simulation Method called
	' "The Euler Method" is used. The Euler Method is Not always accurate, but it is 
	' simple. It is suitable For most of physical simulations that we know in common 
	' computer And video games.
	Method Simulate(dt:Float)
		' Change in velocity is added To the velocity.
		' The change is proportinal with the acceleration (force / m) And change in time
		vel.AddEqual((force.Div(m)).Mult(dt))
		
		' Change in position is added To the position.
		' Change in position is velocity times the change in time
		pos.AddEqual(vel.Mult(dt))
	End Method
End Type
'
' ************************************************************************
' Class Simulation ---> A container Object For simulating masses
' ************************************************************************
Type Simulation
	Field numOfMasses:Int		' number of masses in this container
	Field masses:Mass[]		' masses are held by pointer To pointer. (Here Mass[] represents a 1 dimensional array)
	
	' Constructor creates some masses with mass values m
	Method Simulation(num_Of_Masses:Int, m:Float)
		numOfMasses=num_Of_Masses
		masses=masses:Mass[..numOfMasses]				' Create an array of pointers
		For Local a:Int=0 Until numOfMasses					' We will Step To every pointer in the array
			masses[a]=New Mass						' Create a Mass as a pointer And put it in the array
			masses[a].Mass(m)
		Next
	End Method

	' Delete the masses created
	Method Erase()
		For Local a:Int=0 Until numOfMasses					' we will Delete all of them
			'Delete masses[a]
			masses[a]=Null
		Next
		'Delete masses
		masses=Null
	End Method

	Method GetMass:Mass(index:Int)
		If (index<0) Or (index>=numOfMasses) Then		' If the index is Not in the array
			Return Null								' Then Return Null
		EndIf
		Return masses[index]							' get the mass at the index
	End Method

	' This method will call the Init() method of every mass
	Method Init()
		For Local a:Int=0 Until numOfMasses					' We will init() every mass
			masses[a].Init()							' call init() Method of the mass
		Next
	End Method

	' No implementation because no forces are wanted in this basic container.
	' In advanced containers, this Method will be overrided and some forces will act on masses
	Method Solve()
	End Method

	' Iterate the masses by the change in time
	Method Simulate(dt:Float)
		For Local a:Int=0 Until numOfMasses					' We will iterate every mass
			masses[a].Simulate(dt)						' Iterate the mass And obtain New position And New velocity
		Next
	End Method

	' The complete procedure of simulation
	Method Operate(dt:Float)
		Init()										' Step 1: reset forces To zero
		Solve()										' Step 2: apply forces
		Simulate(dt)									' Step 3: iterate the masses by the change in time
	End Method
End Type
'
' ************************************************************************
' Class ConstantVelocity is derived from class Simulation
' It creates 1 mass with mass value 1 kg And sets its velocity to (1.0, 0.0, 0.0)
' so that the mass moves in the x direction with 1 m/s velocity.
' ************************************************************************
Type ConstantVelocity Extends Simulation

	' Constructor firstly constructs its Super class with 1 mass and 1 kg
	Method New() 'ConstantVelocity()
		Simulation(1, 1.0)
		masses[0].pos=Vector3D.Constructor(0.0, 0.0, 0.0)	' a mass was created And we set its position To the origin
		masses[0].vel=Vector3D.Constructor(1.0, 0.0, 0.0)	' we set the mass's velocity to (1.0, 0.0, 0.0)
	End Method
End Type
'
' ************************************************************************
' Class MotionUnderGravitation is derived from class Simulation
' It creates 1 mass with mass value 1 kg And sets its velocity To (10.0, 15.0, 0.0) And its position to
' (-10.0, 0.0, 0.0). The purpose of this application is to apply a gravitational force to the mass and
' observe the path it follows. The above velocity and position provides a fine projectile path with a
' 9.81 m/s/s downward gravitational acceleration. 9.81 m/s/s is a very close value to the gravitational
' acceleration we experience on the Earth.
' ************************************************************************
Type MotionUnderGravitation Extends Simulation
	Field gravitation:Vector3D=New Vector3D					' The gravitational acceleration

	' Constructor firstly constructs its Super class with 1 mass and 1 kg
	' Vector3D grav, is the gravitational acceleration
	Method MotionUnderGravitation(gravitation:Vector3D)
		Simulation(1, 1.0)
		Self.gravitation=gravitation						' Set this class's gravitation
		masses[0].pos=Vector3D.Constructor(-10.0,  0.0, 0.0)	' Set the position of the mass
		masses[0].vel=Vector3D.Constructor( 10.0, 15.0, 0.0)	' Set the velocity of the mass
	End Method

	' Gravitational force will be applied therefore we need a "solve" method.
	Method Solve()
		For Local a:Int=0 Until numOfMasses							' We will apply force to all masses (actually we have 1 mass, but we can extend it in the future)
			masses[a].applyForce(gravitation.Mult(masses[a].m))	' Gravitational force is as F = m * g. (mass times the gravitational acceleration)
		Next
	End Method
End Type
'
' ************************************************************************
' Class MassConnectedWithSpring is derived from class Simulation
' It creates 1 mass with mass value 1 kg and binds the mass to an arbitrary constant point with a spring. 
' This point is refered as the connectionPos and the spring has a springConstant value to represent its 
' stiffness.
' ************************************************************************
Type MassConnectedWithSpring Extends Simulation
	Field springConstant:Float									' More the springConstant, stiffer the spring force
	Field connectionPos:Vector3D								' The arbitrary constant point that the mass is connected

	' Constructor firstly constructs its Super class with 1 mass and 1 kg
	Method MassConnectedWithSpring(springConstant:Float)
		Simulation(1, 1.0)	
		Self.springConstant=springConstant									' Set the springConstant
		connectionPos=Vector3D.Constructor(0.0, -5.0, 0.0)					' Set the connectionPos
		masses[0].pos=connectionPos.Add(Vector3D.Constructor(10.0, 0.0, 0.0))	' Set the position of the mass 10 meters To the Right side of the connectionPos
		masses[0].vel=Vector3D.Constructor(0.0, 0.0, 0.0)					' Set the velocity of the mass To zero
	End Method

	' The spring force will be applied
	Method Solve()
		For Local a:Int=0 Until numOfMasses										' We will apply force To all masses (actually we have 1 mass, but we can extend it in the future)
			Local springVector:Vector3D
			springVector=(masses[a].pos).Sub(connectionPos)					' Find a vector from the position of the mass To the connectionPos
			masses[a].ApplyForce((springVector.Negat()).Mult(springConstant))	' Apply the force according To the famous spring force formulation
		Next
	End Method
End Type

	
Type TNeHe39 Extends TNeHe
	' ConstantVelocity is an object from class Physics. It is a container for simulating masses.
	' Specifically, it creates a mass and sets its velocity as (1, 0, 0) so that the mass
	' moves with 1.0f meters / second in the x direction.
	Field ConstantVelocity1:ConstantVelocity=New ConstantVelocity
	'ConstantVelocity* constantVelocity = New ConstantVelocity();
	
	' MotionUnderGravitation is an object from class Physics. It is a container for simulating masses.
	' This object applies gravitation to all masses it contains. This gravitation is set by the
	' constructor which is (0.0, -9.81, 0.0) for now (see below). This means a gravitational acceleration
	' of 9.81 meter per (second * second) in the negative y direction. MotionUnderGravitation
	' creates one mass by default and sets its position to (-10, 0, 0) and its velocity to (10, 15, 0)
	Field motionUnderGravitation1:MotionUnderGravitation=New MotionUnderGravitation 
	
	' MassConnectedWithSpring is an object from class Physics1. It is a container for simulating masses.
	' This object has a member called connectionPos, which is the connection position of the spring
	' it simulates. All masses in this container are pulled towards the connectionPos by a spring
	' with a constant of stiffness. This constant is set by the constructor and for now it is 2.0 (see below).
	Field massConnectedWithSpring1:MassConnectedWithSpring=New MassConnectedWithSpring
	
	Field slowMotionRatio:Float=10.0			' slowMotionRatio Is A Value To Slow Down The Simulation, Relative To Real World Time
	Field timeElapsed:Float=0.0				' Elapsed Time In The Simulation (Not Equal To Real World's Time Unless slowMotionRatio Is 1
	Field base:Int							' Base Display List For The Font Set
	Field gmf:Float[256]						' Storage For Information About Our Outline Font Characters
	'GLYPHMETRICSFLOAT gmf[256]
	Field TickCount:Int						' Time passed
	Field ShowMenu:Int
	
	Method Init()
		motionUnderGravitation1.MotionUnderGravitation(Vector3D.Constructor(0.0, -9.81, 0.0))
		massConnectedWithSpring1.MassConnectedWithSpring(2.0)
		glClearColor(0.0, 0.0, 0.0, 0.5)										' Black Background
		glShadeModel(GL_SMOOTH)												' Select Smooth Shading
		glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST)						' Set Perspective Calculations To Most Accurate
		glViewport(0,0,ScreenWidth,ScreenHeight)								' Set viewport
		glMatrixMode(GL_PROJECTION)											' Select The Projection Matrix
		glLoadIdentity()														' Reset The Projection Matrix
		gluPerspective(45.0,Float(ScreenWidth)/Float(ScreenHeight),1.0,100.0)		' Calculate The Aspect Ratio Of The Window
		glMatrixMode(GL_MODELVIEW)												' Select The Modelview Matrix
		glLoadIdentity()														' Reset The Current Modelview Matrix
		TickCount=MilliSecs()
	End Method
	
	Method Loop()
		Local mass:Mass=New Mass
		Local pos:Vector3D=New Vector3D
		
		If KeyHit(KEY_F1) Then ShowMenu=Not ShowMenu
		glMatrixMode(GL_MODELVIEW)
		glLoadIdentity()														' Reset The Modelview Matrix
	
		' Position Camera 40 Meters Up In Z-Direction.
		' Set The Up Vector In Y-Direction So That +X Directs To Right And +Y Directs To Up On The Window.
		gluLookAt(0, 0, 40, 0, 0, 0, 0, 1, 0)						
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)						' Clear Screen And Depth Buffer
		
		' Drawing The Coordinate Plane Starts Here.
		' We Will Draw Horizontal And Vertical Lines With A Space Of 1 Meter Between Them.
		glColor3ub(0, 0, 255)													' Draw In Blue
		glBegin(GL_LINES)
			' Draw The Vertical Lines
			For Local x=-20 Until 21											' x:+1.0 Stands For 1 Meter Of Space In This Example
				glVertex3f(x, 20, 0)
				glVertex3f(x,-20, 0)
			Next
			' Draw The Horizontal Lines
			For Local y=-20 Until 21											' y:+1.0 Stands For 1 Meter Of Space In This Example
				glVertex3f( 20, y, 0)
				glVertex3f(-20, y, 0)
			Next
		glEnd()
		' Drawing The Coordinate Plane Ends Here.
	
		' Draw All Masses In constantVelocity Simulation (Actually There Is Only One Mass In This Example Of Code)
		glColor3ub(255, 0, 0)													' Draw In Red
		Local a:Int
		For a=0 Until constantVelocity1.numOfMasses
			mass=constantVelocity1.getMass(a)
			pos.Equal(mass.pos)
			GLDrawText("Mass with constant vel",(pos.x*14.5)+145.0,-(pos.y*14.5)+210.0)
			glPointSize(4)
			glBegin(GL_POINTS)
				glVertex3f(pos.x, pos.y, pos.z)
			glEnd()
		Next
		' Drawing Masses In constantVelocity Simulation Ends Here.
	
		' Draw All Masses In motionUnderGravitation Simulation (Actually There Is Only One Mass In This Example Of Code)
		glColor3ub(255, 255, 0)												' Draw In Yellow
		For a=0 Until motionUnderGravitation1.numOfMasses
			mass=motionUnderGravitation1.getMass(a)
			pos.Equal(mass.pos)
			GLDrawText("Motion under gravitation",(pos.x*14.5)+124.0,-(pos.y*14.5)+210.0)
			glPointSize(4)
			glBegin(GL_POINTS)
				glVertex3f(pos.x, pos.y, pos.z)
			glEnd()
		Next
		' Drawing Masses In motionUnderGravitation Simulation Ends Here.
	
		' Draw All Masses In massConnectedWithSpring Simulation (Actually There Is Only One Mass In This Example Of Code)
		glColor3ub(0, 255, 0)													' Draw In Green
		For a=0 Until massConnectedWithSpring1.numOfMasses
			mass=massConnectedWithSpring1.getMass(a)
			pos.Equal(mass.pos)
			GLDrawText("Mass connected with spring",(pos.x*14.5)+116,-(pos.y*14.5)+210.0)
			glPointSize(8)
			glBegin(GL_POINTS)
				glVertex3f(pos.x, pos.y, pos.z)
			glEnd()
			' Draw A Line From The Mass Position To Connection Position To Represent The Spring
			glBegin(GL_LINES)
				glVertex3f(pos.x, pos.y, pos.z)
				pos.Equal(massConnectedWithSpring1.connectionPos)
				glVertex3f(pos.x, pos.y, pos.z)
			glEnd()
		Next
		' Drawing Masses In massConnectedWithSpring Simulation Ends Here.
	
		glColor3ub(255, 255, 255)													' Draw In White
		GLDrawText("Time elapsed (seconds): " + "".FromFloat(timeElapsed),35.0, 16)
		GLDrawText("Slow motion ratio: " + "".FromFloat(slowMotionRatio),35.0, 32)
		GLDrawText("Press F2 for normal motion",35.0, 48)
		GLDrawText("Press F3 for slow motion",35.0, 64)
		Update(MilliSecs()-TickCount)
		TickCount=MilliSecs()
		DrawMenu()
	End Method
	
	' Perform Motion Updates Here
	Method Update(milliseconds:Int)
		If KeyHit(Key_F2) Then												' Is F2 Being Pressed?
			slowMotionRatio=1.0											' Set slowMotionRatio To 1.0f (Normal Motion)
		EndIf
		
		If KeyHit(Key_F3) Then												' Is F3 Being Pressed?
			slowMotionRatio=10.0											' Set slowMotionRatio To 10.0f (Very Slow Motion)
		EndIf
		
		' dt Is The Time Interval (As Seconds) From The Previous Frame To The Current Frame.
		' dt Will Be Used To Iterate Simulation Values Such As Velocity And Position Of Masses.
		Local dt:Float=Float(milliseconds)/1000.0							' Let's Convert Milliseconds To Seconds
		dt:/slowMotionRatio												' Divide dt By slowMotionRatio And Obtain The New dt
		timeElapsed:+dt													' Iterate Elapsed Time
		' Say That The Maximum Possible dt Is 0.1 Seconds. This Is Needed So We Do Not Pass Over A Non Precise dt Value
		Local maxPossible_dt:Float=0.1
		Local numOfIterations:Int=Int(dt/maxPossible_dt)+1					' Calculate Number Of Iterations To Be Made At This Update Depending On maxPossible_dt And dt
		If numOfIterations <> 0 Then										' Avoid Division By Zero
			dt=dt/Float(numOfIterations)									' dt Should Be Updated According To numOfIterations
		EndIf
		For Local a=0 Until numOfIterations									' We Need To Iterate Simulations "numOfIterations" Times
			constantVelocity1.operate(dt)									' Iterate constantVelocity Simulation By dt Seconds
			motionUnderGravitation1.operate(dt)								' Iterate motionUnderGravitation Simulation By dt Seconds
			massConnectedWithSpring1.operate(dt)							' Iterate massConnectedWithSpring Simulation By dt Seconds
		Next
	End Method
	
	Method DrawMenu()
		glDisable(GL_TEXTURE_2D)	
		glColor3f(1.0,1.0,1.0)
		GLDrawText("F1 : Hide/Show menu",10,ScreenHeight-16-8)
		If ShowMenu Then
			GLDrawText("NeHe & Erkin Tunca's Physics Tutorial (lesson 39)",35,0)
		EndIf
		glEnable(GL_TEXTURE_2D)
	End Method
End Type