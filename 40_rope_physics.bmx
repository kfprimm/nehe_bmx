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

New TNeHe40.Run(40,"Rope Physics")


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
'
'**************************************************************************
'  Class Physics2  
'  Prepared by Erkin Tunca For nehe.gamedev.net
'  Updated to BlitzMax by Extron
'**************************************************************************
'
' An Object to represent a spring with inner friction binding two masses. The spring
' has a normal length (the length that the spring does not exert any force)
Type Spring
	Field mass1:Mass=New Mass											' The first mass at one tip of the spring
	Field mass2:Mass=New Mass											' The second mass at the other tip of the spring
	Field springConstant:Float											' A constant To represent the stiffness of the spring
	Field springLength:Float											' The length that the spring does Not exert any force
	Field frictionConstant:Float										' A constant To be used For the inner friction of the spring

	' Constructor
	Method Spring(mass1:Mass, mass2:Mass, springConstant:Float, springLength:Float, frictionConstant:Float)
		Self.springConstant = springConstant							' Set the springConstant
		Self.springLength = springLength								' Set the springLength
		Self.frictionConstant = frictionConstant						' Set the frictionConstant
		Self.mass1 = mass1											' Set mass1
		Self.mass2 = mass2											' Set mass2
	End Method

	' solve() Method: the Method where forces can be applied
	Method Solve()
		Local springVector:Vector3D = mass1.pos.Sub(mass2.pos)			' Vector between the two masses
		Local r:Float = springVector.length()							' Distance between the two masses
		Local force:Vector3D=New Vector3D								' Force initially has a zero value
		If r <> 0 Then												' To avoid a division by zero check If r is zero
			force.AddEqual( ((springVector.Div(r)).Mult(r - springLength)).Mult(-springConstant))
		EndIf
		
		' The friction force is added To the force with this addition we obtain the net force of the spring
		force.AddEqual(((mass1.vel.Sub(mass2.vel)).Negat()).Mult(frictionConstant))

		mass1.applyForce(force)										' Force is applied To mass1
		mass2.applyForce(force.Negat())									' The opposite of force is applied To mass2
	End Method
End Type
'
'  Class RopeSimulation is derived from class Simulation (see Physics). It simulates a rope with
'  point-like particles binded with springs. The springs have inner friction And normal length. One tip of
'  the rope is stabilized at a point in space called "Vector3D ropeConnectionPos". This point can be
'  moved externally by a Method "setRopeConnectionVel(ropeConnectionVel:Vector3D)". RopeSimulation
'  creates air friction And a planer surface (Or ground) with a normal in +y direction. RopeSimulation
'  implements the force applied by this surface. In the code, the surface is refered as "ground".
'  An Object to simulate a rope interacting with a planer surface and air 
Type RopeSimulation Extends Simulation

	Field springs:Spring[]									' Springs binding the masses (there shall be [numOfMasses - 1] of them)
	Field gravitation:Vector3D								' Gravitational acceleration (gravity will be applied To all masses)
	Field ropeConnectionPos:Vector3D=New Vector3D			' A point in space that is used To set the position of the first mass in the system (mass with index 0)
	Field ropeConnectionVel:Vector3D						' A variable To move the ropeConnectionPos (by this, we can swing the rope)
	Field groundRepulsionConstant:Float						' A constant To represent how much the ground shall repel the masses
	Field groundFrictionConstant:Float						' A constant of friction applied To masses by the ground (used For the sliding of rope on the ground)
	Field groundAbsorptionConstant:Float					' A constant of absorption friction applied To masses by the ground (used For vertical collisions of the rope with the ground)
	Field groundHeight:Float								' A value To represent the y position value of the ground (the ground is a planar surface facing +y direction)
	Field airFrictionConstant:Float							' A constant of air friction applied To masses

	' A Long Long constructor with 11 parameters starts here
	Method RopeSimulation( ..
		numOfMasses:Int, ..								'  1. the number of masses
		m:Float, ..										'  2. weight of each mass
		springConstant:Float, ..							'  3. how stiff the springs are
		springLength:Float, ..								'  4. the length that a spring does Not exert any force
		springFrictionConstant:Float, ..					'  5. inner friction constant of spring
		gravitation:Vector3D, ..							'  6. gravitational acceleration
		airFrictionConstant:Float, ..						'  7. air friction constant
		groundRepulsionConstant:Float, ..					'  8. ground repulsion constant
		groundFrictionConstant:Float, ..					'  9. ground friction constant
		groundAbsorptionConstant:Float, ..					' 10. ground absorption constant
		groundHeight:Float)								' 11. height of the ground (y position)

		Simulation(numOfMasses, m)							' The Super class creates masses with weights m of each
		Self.gravitation = gravitation
		Self.airFrictionConstant = airFrictionConstant
		Self.groundFrictionConstant = groundFrictionConstant
		Self.groundRepulsionConstant = groundRepulsionConstant
		Self.groundAbsorptionConstant = groundAbsorptionConstant
		Self.groundHeight = groundHeight

		Local a:Int
		For a=0 Until numOfMasses							' To set the initial positions of masses loop with For(;;)
			masses[a].pos.x = a * springLength				' Set x position of masses[a] with springLength distance To its neighbor
			masses[a].pos.y = 0							' Set y position as 0 so that it stand horizontal with respect To the ground
			masses[a].pos.z = 0							' Set z position as 0 so that it looks simple
		Next

		' Create (numOfMasses-1) pointers for springs ((numOfMasses-1) springs are necessary for numOfMasses)
		springs=springs:Spring[..(numOfMasses-1)]
		For a=0 Until (numOfMasses-1)						' To create each spring, start a loop
			' Create the spring with index "a" by the mass with index "a" And another mass with index "a + 1".
			springs[a] = New Spring
			springs[a].Spring(masses[a], masses[a+1], springConstant, springLength, springFrictionConstant)
		Next
	End Method

	Method Erase()
		Super.Erase()										' Have the Super class Release itself
		For Local a:Int=0 Until (numOfMasses-1)				' To Delete all springs, start a loop
			'Delete(springs[a])
			springs[a] = Null
		Next
		'Delete(springs);
		springs = Null
	End Method

	' Solve() is overriden because we have forces To be applied
	Method Solve()
		Local a:Int
		For a=0 Until (numOfMasses-1)												' Apply force of all springs
			springs[a].Solve()													' Spring with index "a" should apply its force
		Next
		For a=0 Until numOfMasses													' Start a loop To apply forces which are common For all masses
			masses[a].applyForce(gravitation.Mult(masses[a].m))						' The gravitational force
			masses[a].applyForce( (masses[a].vel.Negat()).Mult(airFrictionConstant) )	' The air friction

			If masses[a].pos.y < groundHeight Then									' Forces from the ground are applied If a mass collides with the ground
				Local v:Vector3D=New Vector3D										' A temporary Vector3D

				v.Equal(masses[a].vel)												' Get the velocity
				v.y=0															' Omit the velocity component in y direction

				' The velocity in y direction is omited because we will apply a friction force To create 
				' a sliding effect. Sliding is parallel To the ground. Velocity in y direction will be used
				' in the absorption effect.
				masses[a].applyForce( (v.Negat()).Mult(groundFrictionConstant) )		' Ground friction force is applied
				v.Equal(masses[a].vel)												' Get the velocity
				v.x=0															' Omit the x And z components of the velocity
				v.z=0															' We will use v in the absorption effect
				' Above, we obtained a velocity which is vertical To the ground And it will be used in 
				' the absorption force
				If v.y < 0 Then													' Let's absorb energy only when a mass collides towards the ground
					masses[a].applyForce( (v.Negat()).Mult(groundAbsorptionConstant) )	' The absorption force is applied
				EndIf
				' The ground shall repel a mass like a spring. 
				' By "Vector3D(0, groundRepulsionConstant, 0)" we create a vector in the plane normal direction 
				' with a magnitude of groundRepulsionConstant.
				' By (groundHeight - masses[a].pos.y) we repel a mass as much as it crashes into the ground.
				Local force:Vector3D=(Vector3D.Constructor(0, groundRepulsionConstant, 0)).Mult(groundHeight - masses[a].pos.y)
				' Vector3D force = Vector3D(0, groundRepulsionConstant, 0) * (groundHeight - masses[a]->pos.y);
				masses[a].applyForce(force)										' The ground repulsion force is applied
			EndIf
				
		Next
	End Method
	
	' Simulate(dt:Float) is overriden because we want to simulate the motion of the ropeConnectionPos
	Method Simulate(dt:Float)
		Super.Simulate(dt)									' The Super class shall simulate the masses
		ropeConnectionPos.AddEqual(ropeConnectionVel.Mult(dt))	' Iterate the positon of ropeConnectionPos
		If ropeConnectionPos.y < groundHeight Then				' ropeConnectionPos shall Not go under the ground
			ropeConnectionPos.y = groundHeight
			ropeConnectionVel.y = 0
		EndIf
		masses[0].pos.Equal(ropeConnectionPos)					' Mass with index "0" shall position at ropeConnectionPos
		masses[0].vel.Equal(ropeConnectionVel)					' The mass's velocity is set to be equal to ropeConnectionVel
	End Method

	'  The Method to set ropeConnectionVel
	Method setRopeConnectionVel(ropeConnectionVel:Vector3D)
		Self.ropeConnectionVel = ropeConnectionVel
	End Method
End Type

Type TNeHe40 Extends TNeHe
	
	'
	' ********************************************************************
	' fields vars
	' ********************************************************************
	'
	Field ScreenWidth:Int=800
	Field ScreenHeight:Int=600
	Field ScreenDepth:Int=32
	'
	' class RopeSimulation is derived from class Simulation (see Physics1.h). It simulates a rope with 
	' point-like particles binded with springs. The springs have inner friction And normal length. One tip of 
	' the rope is stabilized at a point in space called "Vector3D ropeConnectionPos". This point can be 
	' moved externally by a Method "void setRopeConnectionVel(Vector3D ropeConnectionVel)". RopeSimulation 
	' creates air friction And a planer surface (Or ground) with a normal in +y direction. RopeSimulation 
	' implements the force applied by this surface. In the code, the surface is refered as "ground".
	Field ropeSimulation1:RopeSimulation=New RopeSimulation
	Field TickCount:Int													' Time passed
	Field ShowMenu:Int

	Method Init()
		ropesimulation1.RopeSimulation	(80, ..								' 80 Particles (Masses)
								0.05, ..									' Each Particle Has A Weight Of 50 Grams
								10000.0, ..								' springConstant In The Rope
								0.05, ..									' Normal Length Of Springs In The Rope
								0.2, ..									' Spring Inner Friction Constant
								(Vector3D.Constructor(0, -9.81, 0)), ..		' Gravitational Acceleration
								0.02, ..									' Air Friction Constant
								100.0, ..								' Ground Repel Constant
								0.2, ..									' Ground Slide Friction Constant
								2.0, ..									' Ground Absoption Constant
								-1.5)									' Height Of Ground
	
		ropeSimulation1.getMass(ropeSimulation1.numOfMasses-1).vel.z=10.0
		glClearColor(0.0, 0.0, 0.0, 0.5)										' Black Background
		glClearDepth(1.0)														' Depth Buffer Setup
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
		Local a:Int
		Local mass1:Mass=New Mass
		Local mass2:Mass=New Mass
		Local pos1:Vector3D=New Vector3D
		Local pos2:Vector3D=New Vector3D
	
		If KeyHit(KEY_F1) Then ShowMenu=Not ShowMenu

		glMatrixMode(GL_MODELVIEW)
		glLoadIdentity()														' Reset The Modelview Matrix
		
		' Position Camera 40 Meters Up In Z-Direction.
		' Set The Up Vector In Y-Direction So That +X Directs To Right And +Y Directs To Up On The Window.
		gluLookAt(0, 0, 4, 0, 0, 0, 0, 1, 0)						
	
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)						' Clear Screen And Depth Buffer
		' Draw A Plane To Represent The Ground (Different Colors To Create A Fade)
		glBegin(GL_QUADS)
			glColor3ub(0, 0, 255)												' Set Color To Light Blue
			glVertex3f(20, ropeSimulation1.groundHeight, 20)
			glVertex3f(-20, ropeSimulation1.groundHeight, 20)
			glColor3ub(0, 0, 0)												' Set Color To Black
			glVertex3f(-20, ropeSimulation1.groundHeight, -20)
			glVertex3f(20, ropeSimulation1.groundHeight, -20)
		glEnd()
		
		' Start Drawing Shadow Of The Rope
		glColor3ub(0, 0, 0)													' Set Color To Black
		For a=0 Until ropeSimulation1.numOfMasses-1
			mass1=ropeSimulation1.getMass(a)
			pos1.Equal(mass1.pos)
			mass2=ropeSimulation1.getMass(a+1)
			pos2.Equal(mass2.pos)
			glLineWidth(2)
			glBegin(GL_LINES)
				glVertex3f(pos1.x, ropeSimulation1.groundHeight, pos1.z)			' Draw Shadow At groundHeight
				glVertex3f(pos2.x, ropeSimulation1.groundHeight, pos2.z)			' Draw Shadow At groundHeight
			glEnd()
		Next
		' Drawing Shadow Ends Here.
	
		' Start Drawing The Rope.
		glColor3ub(255, 255, 0)												' Set Color To Yellow
		For a=0 Until ropeSimulation1.numOfMasses-1
			mass1=ropeSimulation1.getMass(a)
			pos1.Equal(mass1.pos)
			mass2=ropeSimulation1.getMass(a+1)
			pos2.Equal(mass2.pos)
			glLineWidth(4)
			glBegin(GL_LINES)
				glVertex3f(pos1.x, pos1.y, pos1.z)
				glVertex3f(pos2.x, pos2.y, pos2.z)
			glEnd()
		Next
		' Drawing The Rope Ends Here.
		Update(MilliSecs()-TickCount)
		TickCount=MilliSecs()
		DrawMenu()
	End Method
	
	' Perform Motion Updates Here
	Method Update(milliseconds:Int)
		Local ropeConnectionVel:Vector3D=New Vector3D					' Create A Temporary Vector3D
	
		' Keys Are Used To Move The Rope
		If KeyDown(KEY_RIGHT) Then										' Is The Right Arrow Being Pressed?
			ropeConnectionVel.x:+3.0									' Add Velocity In +X Direction
		EndIf
		If KeyDown(KEY_LEFT) Then										' Is The Left Arrow Being Pressed?
			ropeConnectionVel.x:-3.0									' Add Velocity In -X Direction
		EndIf
		If KeyDown(KEY_UP) Then										' Is The Up Arrow Being Pressed?
			ropeConnectionVel.z:-3.0									' Add Velocity In +Z Direction
		EndIf
		If KeyDown(KEY_DOWN) Then										' Is The Down Arrow Being Pressed?
			ropeConnectionVel.z:+3.0									' Add Velocity In -Z Direction
		EndIf
		If KeyDown(KEY_HOME) Then										' Is The Home Key Pressed?
			ropeConnectionVel.y:+3.0									' Add Velocity In +Y Direction
		EndIf
		If KeyDown(KEY_END) Then										' Is The End Key Pressed?
			ropeConnectionVel.y:-3.0									' Add Velocity In -Y Direction
		EndIf
		ropeSimulation1.setRopeConnectionVel(ropeConnectionVel)			' Set The Obtained ropeConnectionVel In The Simulation
	
		Local dt:Float=Float(milliseconds)/1000.0						' Let's Convert Milliseconds To Seconds
		' Maximum Possible dt Is 0.002 Seconds. This Is Needed To Prevent Pass Over Of A Non-Precise dt Value
		Local maxPossible_dt:Float=0.002
	
	  	Local numOfIterations:Int=Int(dt/maxPossible_dt)+1				' Calculate Number Of Iterations To Be Made At This Update Depending On maxPossible_dt And dt
		If numOfIterations <> 0 Then									' Avoid Division By Zero
			dt=dt/Float(numOfIterations)								' dt Should Be Updated According To numOfIterations
		EndIf
		For Local a:Int=0 Until numOfIterations							' We Need To Iterate Simulations "numOfIterations" Times
			ropeSimulation1.operate(dt)
		Next
	End Method
	
	Method DrawMenu()
		glDisable(GL_TEXTURE_2D)	
		glColor3f(1.0,1.0,1.0)
		GLDrawText("F1 : Hide/Show menu",10,ScreenHeight-16-8)
		If ShowMenu Then
			GLDrawText("NeHe & Erkin Tunca's Rope Physics Tutorial (lesson 40)",10,0)
			GLDrawText("'RIGHT' Add velocity in +X direction",10,32)
			GLDrawText("'LEFT'  Add velocity in -X direction",10,48)
			GLDrawText("'UP'    Add velocity in +Z direction",10,64)
			GLDrawText("'DOWN'  Add velocity in -Z Direction",10,80)
			GLDrawText("'HOME'  Add velocity in +Y Direction",10,96)
			GLDrawText("'END'   Add velocity in -Y Direction",10,112)
		EndIf
		glEnable(GL_TEXTURE_2D)
	End Method
	
End Type