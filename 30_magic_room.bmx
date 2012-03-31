Strict

Import "framework.bmx"

New TNeHe30.Run(30,"Magic Room")

' INSTRUCTION
'
' Cursor Keys    : Move Camera
' KEY UP         : Zoom in  (field view)
' KEY DOWN       : Zoom out (field view)
' KEY LEFT/RIGHT : Z Rotate
' NUMPAD +/-     : Increase/Decrease Simulation TimeStep
' F2             : Hook Camera To Ball
' F3             : Sound On/Off
'
' ************************************************************************
' CLASS
' ************************************************************************
' TVECTOR
' ************************************************************************

Type TVector
	Const VINVALID:Byte=0 ; Const VDEFAULT:Byte=1 ; Const VUNIT:Byte=2
	Field _x:Double , _y:Double , _z:Double
	Field _Status:Byte

	' ********************************************************************
	' Constructor
	' ********************************************************************
	Function Constructor:TVector(a:Double, b:Double, c:Double)
		Local result:TVector=New TVector
		result._x=a ; result._y=b ; result._z=c
		result._Status=VDEFAULT
		Return result
	End Function
	Function Constructor1:TVector(v:TVector)
		Local result:TVector=New TVector
		result._x=v._x ; result._y=v._y ; result._z=v._z ; result._Status=v._Status
		Return result
	End Function
	' ********************************************************************
	' Selectors
	' ********************************************************************
	Method x:Double()
		Return _x
	End Method
	Method y:Double()
		Return _y
	End Method
	Method z:Double()
		Return _z
	End Method
	Method isUnit()
		Return _Status=VUNIT
	End Method
	Method isDefault()
		Return _Status=VDEFAULT
	End Method
	Method isValid()
		Return _Status<>VINVALID
	End Method
	' ********************************************************************
	' Magnitude
	' ********************************************************************
	Method mag:Double()
		If isValid() Then
			If isUnit() Then
				Return 1.0
			Else
				Return Sqr(x()*x() + y()*y() + z()*z())
			EndIf
		Else
			Return 0.0
		EndIf
	End Method
	Method magSqr:Double()
		If isValid() Then
			If isUnit() Then
				Return 1.0
			Else
				Return x()*x() + y()*y() + z()*z()
			EndIf
		Else
			Return 0.0
		EndIf
	End Method	
	' ********************************************************************
	' Dot or scalar product
	' ********************************************************************
	Function dot1:Double(v1:TVector, v2:TVector)
		Return v1.dot(v2)
	End Function
	Method dot:Double(v:TVector)
		If isValid() And v.isValid() Then
			Return x()*v.x() + y()*v.y() + z()*v.z()
		Else
			Return 0.0
		EndIf
	End Method
	' ********************************************************************
	' Distance between two vectors
	' ********************************************************************
	Method dist:Double(v:TVector)	
		Local VEC:TVector=TVector.Constructor((_x-v._x),(_y-v._y),(_z-v._z))
		Return VEC.mag()
	End Method
	Method distSqr:Double(v:TVector)
		Local VEC:TVector=TVector.Constructor((_x-v._x),(_y-v._y),(_z-v._z))
		Return VEC.magSqr()
	End Method
	' ********************************************************************
	' Make a unit vector
	' ********************************************************************
	Method unit:TVector()
		If isDefault() Then
			Local rep:Double=Self.mag()
				If rep<EPSILON Then
					_x=0.0
					_y=0.0
					_z=0.0
				Else
					Local temp:Double=1.0/rep
					_x:*temp
					_y:*temp
					_z:*temp
				EndIf
				_Status = VUNIT
		EndIf
		Return Self
	End Method
	Function unit1:TVector(v:TVector)
		Local VEC:TVector=TVector.Constructor(v._x, v._y, v._z)
		Return VEC.unit()
	End Function
	Function unit2:TVector(v:TVector, result:TVector)
		result._x=v._x ; result._y=v._y ; result._z=v._z ; result._Status=v._Status
		Return result.unit()
	End Function
	' ********************************************************************
	' Make a default vector
	' ********************************************************************	
	Method V_defaut:TVector()
		If isUnit() Then
			_Status = VDEFAULT
		EndIf
		Return Self
	End Method
	Function V_defaut1:TVector(v:TVector)
		Local VEC:TVector=TVector.Constructor(v._x, v._y, v._z)
		Return VEC.V_defaut()
	End Function
	Function V_defaut2:TVector(v:TVector, result:TVector)
		result._x=v._x ; result._y=v._y ; result._z=v._z ; result._Status=v._Status
		Return result.V_defaut()
	End Function
	' ********************************************************************
	' Optimised arithmetic methods
	' Return a TVector (Function, don't operate with this TVector)
	' ********************************************************************
	' Addition 2 vectors and return new vector (Result = v1 + v2)
	Function Addition:TVector(v1:TVector, v2:TVector)
		Local result:TVector=New TVector
		If v1.isValid() And v2.isValid() Then
			result._x = v1._x + v2._x
			result._y = v1._y + v2._y
			result._z = v1._z + v2._z
			result._Status = VDEFAULT
		EndIf
		Return result
	End Function
	' Substract 2 vectors and return new vector (Result = v1 - v2)
	Function Substract:TVector(v1:TVector, v2:TVector)
		Local result:TVector=New TVector
		If v1.isValid() And v2.isValid() Then
			result._x = v1._x - v2._x
			result._y = v1._y - v2._y
			result._z = v1._z - v2._z
			result._Status = VDEFAULT
		EndIf
		Return result
	End Function
	' Crossproduct of 2 vectors and return new vector (Result = v1 * v2)
	Function Cross:TVector(v1:TVector, v2:TVector)
		Local result:TVector=New TVector
		If v1.isValid() And v2.isValid() Then
			result._x = v1._y * v2._z - v1._z * v2._y
			result._y = v1._z * v2._x - v1._x * v2._z
			result._z = v1._x * v2._y - v1._y * v2._x
			result._Status = VDEFAULT
		EndIf
		Return result
	End Function	
	' Invert a vector and return new vector (Result = -(v1))
	Function Invert:TVector(v1:TVector)
		Local result:TVector=New TVector
		If v1.isValid() Then
			result._x = - v1._x
			result._y = - v1._y
			result._z = - v1._z
			result._Status = VDEFAULT
		EndIf
		Return result
	End Function	
	' Multiply 1 vector by scale and return new vector (Result = v1 * scale)
	Function Multiply:TVector(v1:TVector, scale:Double)
		Local result:TVector=New TVector
		If v1.isValid() Then
			result._x = v1._x * scale
			result._y = v1._y * scale
			result._z = v1._z * scale
			result._Status = VDEFAULT
		EndIf
		Return result
	End Function
	' ********************************************************************
	' Operator
	' ( Method, operate with this TVector )
	' ********************************************************************
	' Negat this vector and return a vector ( result = - self ) (v2=v1.Negat())
	Method Negat:TVector()
		Return TVector.Invert(Self)
	End Method
	' Assign a vector to this vector ( self = v1 ) (v2=v2.Equal(v1))
	Method Equal:TVector(v1:TVector)
		_x=v1._x ; _y=v1._y ; _z=v1._z ; _Status=v1._Status
	End Method	
	' Add to this vector a vector and return this vector ( self :+ v1 ) (v2=v2.AddEqual(v1))
	Method AddEqual:TVector(v1:TVector)
		Return TVector.Addition(Self, v1)
	End Method
	' Sub to this vector a vector and return this vector ( self :- v1 ) (v2=v2.SubEqual(v1))
	Method SubEqual:TVector(v1:TVector)
		Return TVector.Substract(Self, v1)
	End Method
	' Mult this vector by a vector and return this vector (Crossproduct) ( self :* v1 ) (v2=v2.MultEqualVec(v1))
	Method MultEqualVec:TVector(v1:TVector)
		Return TVector.Cross(Self, v1)
	End Method
	' Mult this vector by a val and return this vector ( self :* value ) (v2=v2.MultEqualVal(scale))
	Method MultEqualVal:TVector(scale:Double)
		Return TVector.Multiply(Self, scale)
	End Method
	' Add to this vector a vector and return a vector ( result = self + v1 ) (v3=v1.Add(v2))
	Method Add:TVector(v1:TVector)
		Return TVector.Addition(Self, v1)
	End Method
	' Sub to this vector a vector and return a vector ( result = self - v1 ) (v3=v1.Sub(v2))
	Method Sub:TVector(v1:TVector)
		Return TVector.Substract(Self, v1)
	End Method	
	' Mult to this vector a vector and return a vector (Crossproduct) ( result = self * v1 ) (v3=v1.MultVec(v2))
	Method MultVec:TVector(v1:TVector)
		Return TVector.Cross(Self, v1)
	End Method	
	' Mult to this vector by a value and return a vector ( result = self * scale ) (v3=v1.MultVal(scale))
	Method MultVal:TVector(scale:Double)
		Return TVector.Multiply(Self, scale)
	End Method
End Type
' ************************************************************************
' TRAY
' ************************************************************************
Type TRay
	Field _P:TVector=New TVector			' Any point on the line
	Field _V:TVector=New TVector			' Direction of the line

	' ********************************************************************
	' Constructor ( Origin - Direction (normalized) )
	' ********************************************************************
	Function Constructor:TRay(point1:TVector, point2:TVector)
		Local result:TRay=New TRay
		result._P.Equal(point1)
		If point2.isUnit() Then
			result._V.Equal(point2)
		Else
			result._V=TVEctor.unit1(point2.Sub(point1))
		EndIf
		Return result
	End Function
	
	' ********************************************************************
	' Selectors
	' ********************************************************************
	Method P:TVector()
		Return _P
	End Method
	Method V:TVector()
		Return _V
	End Method
	Method isValid()
		Return (V().isUnit() And P().isValid())
	End Method
	' ********************************************************************
	' Distance
	' ********************************************************************
	' Distance between two rays
	Method dist:Double(ray:TRay)
		Local point1:TVector=TVector.Constructor(0.0,0.0,0.0)
		Local point2:TVector=TVector.Constructor(0.0,0.0,0.0)
		If adjacentPoints(ray, point1, point2)
			Return point1.dist(point2)
		Else
			Return 0.0
		EndIf	
	End Method
	' Distance between a ray and a point
	Method distPointRay:Double(point:TVector)
		If isValid() And point.isValid() Then
			Local point2:TVector=TVector.Constructor(0.0,0.0,0.0)
			Local lambda:Double=TVector.dot1(_V,point.Sub(_P))
			point2=TVector.Addition(_P, TVector.Multiply(_V, lambda))
			Return point.dist(point2)
		EndIf
		Return 0.0
	End Method
	
	Method adjacentPoints(ray:TRay, point1:TVector, point2:TVector)
		If isValid() And ray.isValid() Then
			Local temp:Double=TVector.dot1(_V, ray._V)
			Local temp2:Double=1.0-Sqr(temp)
			' Check For parallel rays
			If Abs(temp2)<EPSILON Then
				Local mu:Double=TVector.dot1(_V, _P.Sub(ray._P))/temp
				point1.Equal(_P)
				point2=TVector.Addition(ray._P, TVector.Multiply(ray._V, mu))
			Else
				Local a:Double= TVector.dot1(_V, TVector.Substract(ray._P, _P))
				Local b:Double= TVector.dot1(ray._V, TVector.Substract(_P, ray._P))
				Local mu:Double= (b + temp*a)/temp2
				Local lambda:Double= (a + temp*b)/temp2
				point1=TVector.Addition(_P, TVector.Multiply(_V, lambda))
				point2=TVector.Addition(ray._P, TVector.Multiply(ray._V, mu))
			EndIf		
			Return True
		EndIf
		Return False
	End Method
End Type


' ********************************************************************
' STRUCTURE
' ********************************************************************
Type Plane												' Plane structure
	Field _Position:TVector
	Field _Normal:TVector
End Type

Type Cylinder												' Cylinder structure
	Field _Position:TVector
	Field _Axis:TVector
	Field _Radius:Double
End Type

Type Explosion											' Explosion structure
	Field _Position:TVector=TVector.Constructor(0.0,0.0,0.0) 'New TVector
	Field _Alpha:Float
	Field _Scale:Float
End Type

' ********************************************************************
' CONSTANTS
' ********************************************************************
Const EPSILON:Double=1.0e-8
Const ZERO:Double=EPSILON

Type TNeHe30 Extends TNeHe
	' ********************************************************************
	' fields vars
	' ********************************************************************
	
	Field spec:Float[]=[1.0, 1.0 ,1.0 ,1.0]					' sets specular highlight of balls
	Field posl:Float[]=[0.0,400.0,0.0,1.0]						' position of ligth source
	Field amb:Float[]=[0.2, 0.2, 0.2 ,1.0]						' field ambient
	Field amb2:Float[]=[0.3, 0.3, 0.3 ,1.0]					' ambient of lightsource
	
	Field dir:TVector=TVector.Constructor(0,0,-10)				' initial direction of camera
	Field pos:TVector=TVector.Constructor(0,-50,1000)			' initial position of camera
	Field camera_rotation:Float=0								' holds rotation around the Y axis
	
	Field veloc:TVector=TVector.Constructor(0.5,-0.1,0.5)		' initial velocity of balls
	Field accel:TVector=TVector.Constructor(0,-0.05,0)			' acceleration ie. gravity of balls
	
	Field ArrayVel:TVector[10]								' holds velocity of balls
	Field ArrayPos:TVector[10]								' position of balls
	Field OldPos:TVector[10]									' old position of balls
	Field NrOfBalls:Int										' sets the number of balls
	Field Time:Double=0.6										' timestep of simulation
	Field hook_toball1:Int=0, sounds:Int=1						' hook camera on ball, And sound on/off
	' The 5 planes of the room
	Field pl1:Plane=New Plane
	Field pl2:Plane=New Plane
	Field pl3:Plane=New plane
	Field pl4:Plane=New Plane
	Field pl5:Plane=New Plane
	' The 3 cylinders of the room
	Field cyl1:Cylinder=New Cylinder
	Field cyl2:Cylinder=New Cylinder
	Field cyl3:Cylinder=New Cylinder
	Field cylinder_obj:Int Ptr								' Quadratic Object To render the cylinders
	Field ExplosionArray:Explosion[20]							' holds Max 20 explosions at once
	Field texture:Int[4], dlist:Int							' stores texture objects And display list
	
	Field sound:TSound

	Field ShowMenu:Int
	
	'
	'*************************************************************************************
	' FUNCTIONS
	'*************************************************************************************
	'
	Method Init()
		Local df:Float=100.0
	
		sound = LoadSound("Data/Explode.wav")
		If KeyHit(KEY_F1) Then ShowMenu=Not ShowMenu
		InitVars()

		glClearDepth(1.0)														' Depth Buffer Setup
		glEnable(GL_DEPTH_TEST)												' Enables Depth Testing
		glDepthFunc(GL_LEQUAL)													' The Type Of Depth Testing To Do
		glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST)						' Really Nice Perspective Calculations
	
		glClearColor(0.0,0.0,0.0,0.0)
		glMatrixMode(GL_MODELVIEW)
		glLoadIdentity()
	
		glShadeModel(GL_SMOOTH)
		glEnable(GL_CULL_FACE)
		glEnable(GL_DEPTH_TEST)
	
		glMaterialfv(GL_FRONT,GL_SPECULAR,spec)
		glMaterialfv(GL_FRONT,GL_SHININESS,Varptr df)
	
		glEnable(GL_LIGHTING)
		glLightfv(GL_LIGHT0,GL_POSITION,posl)
		glLightfv(GL_LIGHT0,GL_AMBIENT,amb2)
		glEnable(GL_LIGHT0)
	
		glLightModelfv(GL_LIGHT_MODEL_AMBIENT,amb)
		glEnable(GL_COLOR_MATERIAL)
		glColorMaterial(GL_FRONT,GL_AMBIENT_AND_DIFFUSE)
	   
		glEnable(GL_BLEND)
		glBlendFunc(GL_SRC_ALPHA, GL_ONE)
	   	
		glEnable(GL_TEXTURE_2D)
		LoadGLTextures()
	
		' Construct billboarded explosion primitive as display list
		' 4 quads at Right angles To each other
		dlist=glGenLists(1)
		glNewList(dlist, GL_COMPILE)
			glBegin(GL_QUADS)
				glRotatef(-45.0,0,1,0)
				glNormal3f(0.0,0.0,1.0)
				glTexCoord2f(0.0, 0.0); glVertex3f(-50.0,-40.0,0.0)
				glTexCoord2f(0.0, 1.0); glVertex3f(50.0,-40.0,0.0)
				glTexCoord2f(1.0, 1.0); glVertex3f(50.0,40.0,0.0)
				glTexCoord2f(1.0, 0.0); glVertex3f(-50.0,40.0,0.0)
				glNormal3f(0.0,0.0,-1.0)
				glTexCoord2f(0.0, 0.0); glVertex3f(-50,40,0)
				glTexCoord2f(0.0, 1.0); glVertex3f(50,40,0)
				glTexCoord2f(1.0, 1.0); glVertex3f(50,-40,0)
				glTexCoord2f(1.0, 0.0); glVertex3f(-50,-40,0)
	
				glNormal3f(1,0,0)
				glTexCoord2f(0.0, 0.0); glVertex3f(0,-40,50)
				glTexCoord2f(0.0, 1.0); glVertex3f(0,-40,-50)
				glTexCoord2f(1.0, 1.0); glVertex3f(0,40,-50)
				glTexCoord2f(1.0, 0.0); glVertex3f(0,40,50)
				glNormal3f(-1,0,0)
				glTexCoord2f(0.0, 0.0); glVertex3f(0,40,50)
				glTexCoord2f(0.0, 1.0); glVertex3f(0,40,-50)
				glTexCoord2f(1.0, 1.0); glVertex3f(0,-40,-50)
				glTexCoord2f(1.0, 0.0); glVertex3f(0,-40,50)
			glEnd()
		glEndList()
	
		glViewport(0,0,ScreenWidth,ScreenHeight)								' Set viewport
		glMatrixMode(GL_PROJECTION)											' Select The Projection Matrix
		glLoadIdentity()														' Reset The Projection Matrix
		gluPerspective(45.0,Float(ScreenWidth)/Float(ScreenHeight),10.0,5000.0)		' Calculate The Aspect Ratio Of The Window
		glMatrixMode(GL_MODELVIEW)												' Select The Modelview Matrix
		glLoadIdentity()														' Reset The Modelview Matrix
	End Method
	'
	'*************************************************************************************
	'***        Load Bitmaps And Convert To Textures                                  ****
	'*************************************************************************************
	Method LoadGlTextures()
		Local TextureImage:TPixmap[4]
		TextureImage:TPixmap[0]=LoadPixmap("data/marble.bmp")
		TextureImage:TPixmap[1]=LoadPixmap("data/spark.bmp")
		TextureImage:TPixmap[2]=LoadPixmap("data/boden.bmp")
		TextureImage:TPixmap[3]=LoadPixmap("data/wand.bmp")
		
		'* Create Texture *****************************************
		glGenTextures(2, Varptr texture[0])										' Create Two Textures
		glBindTexture(GL_TEXTURE_2D, texture[0])
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR)				' scale linearly when image bigger than texture
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR)				' scale linearly when image smalled than texture
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S, GL_REPEAT)
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T, GL_REPEAT)
		' 2d texture, level of detail 0 (normal), 3 components (red, green, blue), x size from image, y size from image,
		' border 0 (normal), rgb color data, unsigned Byte data, And finally the data itself.
		glTexImage2D(GL_TEXTURE_2D, 0, 3, TextureImage[0].width, TextureImage[0].height, 0, GL_RGB, GL_UNSIGNED_BYTE, TextureImage[0].pixels)
		
		'* Create Texture ******************************************
		glBindTexture(GL_TEXTURE_2D, texture[1])
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR)				' scale linearly when image bigger than texture
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR)				' scale linearly when image smalled than texture
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S, GL_REPEAT)
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T, GL_REPEAT)
		' 2d texture, level of detail 0 (normal), 3 components (red, green, blue), x size from image, y size from image,
		' border 0 (normal), rgb color data, unsigned Byte data, And finally the data itself.
		glTexImage2D(GL_TEXTURE_2D, 0, 3, TextureImage[1].width, TextureImage[1].height, 0, GL_RGB, GL_UNSIGNED_BYTE, TextureImage[1].pixels)
		
		'* Create Texture ********************************************
		glGenTextures(2, Varptr texture[2])
		glBindTexture(GL_TEXTURE_2D, texture[2])
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR)				' scale linearly when image bigger than texture
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR)				' scale linearly when image smalled than texture
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S, GL_REPEAT)
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T, GL_REPEAT)
		' 2d texture, level of detail 0 (normal), 3 components (red, green, blue), x size from image, y size from image,
		' border 0 (normal), rgb color data, unsigned Byte data, And finally the data itself.
		glTexImage2D(GL_TEXTURE_2D, 0, 3, TextureImage[2].width, TextureImage[2].height, 0, GL_RGB, GL_UNSIGNED_BYTE, TextureImage[2].pixels)
	
		'* Create Texture ********************************************
		glBindTexture(GL_TEXTURE_2D, texture[3])
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR)				' scale linearly when image bigger than texture
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR)				' scale linearly when image smalled than texture
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S, GL_REPEAT)
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T, GL_REPEAT)
		' 2d texture, level of detail 0 (normal), 3 components (red, green, blue), x size from image, y size from image,
		' border 0 (normal), rgb color data, unsigned Byte data, And finally the data itself.
		glTexImage2D(GL_TEXTURE_2D, 0, 3, TextureImage[2].width, TextureImage[2].height, 0, GL_RGB, GL_UNSIGNED_BYTE, TextureImage[3].pixels)
	End Method
	'
	Method Loop()
		Local i:Int
			
		If KeyHit(KEY_F2) Then
			hook_toball1= Not hook_toball1
			camera_rotation=0;
		EndIf
		If KeyHit(KEY_F3) Then
			sounds= Not sounds
		EndIf
		If KeyHit(KEY_NUMADD) Then
			Time:+0.1
		EndIf
		If KeyHit(KEY_NUMSUBTRACT) Then
			Time:-0.1
		EndIf
		
		If Not hook_toball1 Then
			If KeyDown(KEY_UP) Then pos._z=pos._z-10.0
			If KeyDown(KEY_DOWN) Then pos._z=pos._z+10.0
		EndIf
		If KeyDown(KEY_LEFT) Then camera_rotation:+1
		If KeyDown(KEY_RIGHT) Then camera_rotation:-1
		
		
		glMatrixMode(GL_MODELVIEW)
		glLoadIdentity()
		' set camera in hookmode 
		If hook_toball1 Then
			Local unit_followvector:TVector=TVector.Constructor1(ArrayVel[0])
			unit_followvector.unit()
			gluLookAt(ArrayPos[0].x()+250,ArrayPos[0].y()+250 ,ArrayPos[0].z(), ArrayPos[0].x()+ArrayVel[0].x() ,ArrayPos[0].y()+ArrayVel[0].y() ,ArrayPos[0].z()+ArrayVel[0].z() ,0,1,0)
		Else
			gluLookAt(pos.x(),pos.y(),pos.z(), pos.x()+dir.x(),pos.y()+dir.y(),pos.z()+dir.z(), 0,1.0,0.0)
		EndIf
		
		glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT)
		glRotatef(camera_rotation,0,1,0)
	
		' render balls
		For i=0 Until NrOfBalls
			Select i
				Case 1
					glColor3f(1.0,1.0,1.0)
				Case 2
					glColor3f(1.0,1.0,0.0)
				Case 3
					glColor3f(0.0,1.0,1.0)
				Case 4
					glColor3f(0.0,1.0,0.0)
				Case 5
					glColor3f(0.0,0.0,1.0)
				Case 6
					glColor3f(0.65,0.2,0.3)
				Case 7
					glColor3f(1.0,0.0,1.0)
				Case 8
					glColor3f(0.0,0.7,0.4)
				Default
					glColor3f(1.0,0,0)
			End Select
			glPushMatrix()
			glTranslated(ArrayPos[i].x(),ArrayPos[i].y(),ArrayPos[i].z())
			gluSphere(cylinder_obj,20,20,20)
			glPopMatrix()
		Next
			
	
		glEnable(GL_TEXTURE_2D)
		' render walls(planes) with texture
		glBindTexture(GL_TEXTURE_2D, texture[3])
		glColor3f(1, 1, 1)
		glBegin(GL_QUADS)
			glTexCoord2f(1.0, 0.0); glVertex3f(320,320,320)
			glTexCoord2f(1.0, 1.0); glVertex3f(320,-320,320)
			glTexCoord2f(0.0, 1.0); glVertex3f(-320,-320,320)
			glTexCoord2f(0.0, 0.0); glVertex3f(-320,320,320)
	        
			glTexCoord2f(1.0, 0.0); glVertex3f(-320,320,-320)
			glTexCoord2f(1.0, 1.0); glVertex3f(-320,-320,-320)
			glTexCoord2f(0.0, 1.0); glVertex3f(320,-320,-320)
			glTexCoord2f(0.0, 0.0); glVertex3f(320,320,-320)
	    
			glTexCoord2f(1.0, 0.0); glVertex3f(320,320,-320)
			glTexCoord2f(1.0, 1.0); glVertex3f(320,-320,-320)
			glTexCoord2f(0.0, 1.0); glVertex3f(320,-320,320)
			glTexCoord2f(0.0, 0.0); glVertex3f(320,320,320)
		
			glTexCoord2f(1.0, 0.0); glVertex3f(-320,320,320)
			glTexCoord2f(1.0, 1.0); glVertex3f(-320,-320,320)
			glTexCoord2f(0.0, 1.0); glVertex3f(-320,-320,-320)
			glTexCoord2f(0.0, 0.0); glVertex3f(-320,320,-320)
		glEnd()
	
		' render Floor (plane) with colours
		glBindTexture(GL_TEXTURE_2D, texture[2]); 
		glBegin(GL_QUADS)
			glTexCoord2f(1.0, 0.0); glVertex3f(-320,-320,320)
			glTexCoord2f(1.0, 1.0); glVertex3f(320,-320,320)
			glTexCoord2f(0.0, 1.0); glVertex3f(320,-320,-320)
			glTexCoord2f(0.0, 0.0); glVertex3f(-320,-320,-320)
		glEnd()
	
		' render columns(cylinders)
		glBindTexture(GL_TEXTURE_2D, texture[0])					' choose the texture To use.
		glColor3f(0.5,0.5,0.5)
		glPushMatrix()
		glRotatef(90, 1,0,0)
		glTranslatef(0,0,-500)
		gluCylinder(cylinder_obj, 60, 60, 1000, 20, 2)
		glPopMatrix()
	
		glPushMatrix()
		glTranslatef(200,-300,-500)
		gluCylinder(cylinder_obj, 60, 60, 1000, 20, 2)
		glPopMatrix()
	
		glPushMatrix()
		glTranslatef(-200,0,0)
		glRotatef(135, 1,0,0)
		glTranslatef(0,0,-500)
		gluCylinder(cylinder_obj, 30, 30, 1000, 20, 2)
		glPopMatrix()
		
		' render/blend explosions
		glEnable(GL_BLEND)
		glDepthMask(GL_FALSE)
		glBindTexture(GL_TEXTURE_2D, texture[1])
		For i=0 Until 20
			If ExplosionArray[i]._Alpha >= 0 Then
				glPushMatrix()
				ExplosionArray[i]._Alpha:-0.01
				ExplosionArray[i]._Scale:+0.03
				glColor4f(1.0,1.0,0.0,ExplosionArray[i]._Alpha)
				glScalef(ExplosionArray[i]._Scale,ExplosionArray[i]._Scale,ExplosionArray[i]._Scale)
				glTranslatef(ExplosionArray[i]._Position._x/ExplosionArray[i]._Scale, ExplosionArray[i]._Position._y/ExplosionArray[i]._Scale, ExplosionArray[i]._Position._z/ExplosionArray[i]._Scale)
				glCallList(dlist)
				glPopMatrix()
			EndIf
		Next
		glDepthMask(GL_TRUE)
		glDisable(GL_BLEND)
		glDisable(GL_TEXTURE_2D)

		idle()
		DrawMenu()

	End Method
	'
	'*************************************************************************************
	'***                  Find If any of the current balls                            ****
	'***             intersect with each other in the current timestep                ****
	'***Returns the index of the 2 itersecting balls, the point And time of intersection *
	'*************************************************************************************
	Method FindBallCol:Int(point:TVector Var, TimePoint:Double Var, Time2:Double , BallNr1:Int Var, BallNr2:Int Var)
		Local RelativeV:TVector
		Local rays:TRay
		Local MyTime:Double=0.0, Add:Double=Time2/150.0, Timedummy:Double=10000, Timedummy2:Double=-1
		Local posi:TVector
		
		' Test all balls against eachother in 150 small steps
		For Local i=0 Until NrOfBalls-1
			For Local j=i+1 Until NrOfBalls
				RelativeV=TVector.Substract(ArrayVel[i], ArrayVel[j])	
				rays=TRay.Constructor(OldPos[i],TVector.unit1(RelativeV))
				MyTime=0.0
				
				If rays.distPointRay(OldPos[j]) > 40.0 Then Continue
				While (MyTime<Time2)
					MyTime:+Add
					posi=OldPos[i].Add(RelativeV.MultVal(MyTime))
					If posi.dist(OldPos[j]) <= 40.0 Then
						point.Equal(posi)
						If Timedummy > (MyTime-Add) Then Timedummy=MyTime-Add
							BallNr1=i
							BallNr2=j
						Exit
					EndIf
				Wend
			Next
		Next
	
		If Timedummy<>10000.0 Then
			TimePoint=Timedummy
			Return True
		EndIf
		Return False
	End Method
	'
	'*************************************************************************************
	'***             Main loop of the simulation                                      ****
	'***      Moves, finds the collisions And responses of the objects in the         ****
	'***      current time Step.                                                      ****
	'*************************************************************************************
	Method idle()
		Local rt:Double, rt2:Double, rt4:Double, lamda:Double=10000
		Local norm:TVector=TVector.Constructor(0.0,0.0,0.0)
		Local uveloc:TVector
		Local normal:TVector=New TVector '.Constructor(0.0,0.0,0.0)
		Local point:TVector
		Local RestTime:Double, BallTime:Double
		Local Pos2:TVector=TVector.Constructor(0.0,0.0,0.0)
		Local BallNr:Int=0, dummy:Int=0, BallColNr1:Int, BallColNr2:Int
		Local Nc:TVector=TVector.Constructor(0.0,0.0,0.0)
	
		If Not hook_toball1 Then
			camera_rotation:+0.1
			If camera_rotation>360 Then camera_rotation=0
		EndIf
		RestTime=Time
		lamda=1000.0
	
		' Compute velocity For Next timestep using Euler equations
		For Local j=0 Until NrOfBalls
			ArrayVel[j]=ArrayVel[j].AddEqual(accel.MultVal(RestTime))
		Next
		
		' While timestep Not over
		While RestTime>ZERO
			lamda=10000.0				' initialize To very large value
			' For all the balls find closest intersection between balls And planes/cylinders
			For Local i=0 Until NrOfBalls
				' compute New position And distance
				OldPos[i].Equal(ArrayPos[i])
				uveloc=TVector.unit1(ArrayVel[i])
				ArrayPos[i]=ArrayPos[i].Add(ArrayVel[i].MultVal(RestTime))
				rt2=OldPos[i].dist(ArrayPos[i])
				
				' Test If collision occured between ball And all 5 planes
				If (TestIntersionPlane(pl1,OldPos[i],uveloc,rt,norm)) Then
					' Find intersection time
					rt4=rt*RestTime/rt2
					' If smaller than the one already stored Replace And in timestep
					If rt4<=lamda Then
						If rt4<=RestTime+ZERO Then
							If Not ( (rt<=ZERO) And (uveloc.dot(norm)>ZERO) ) Then
								normal.Equal(norm)
								point=OldPos[i].Add(uveloc.MultVal(rt))
								lamda=rt4
								BallNr=i
							EndIf
						EndIf
					EndIf
				EndIf
				  
				If (TestIntersionPlane(pl2,OldPos[i],uveloc,rt,norm)) Then
					rt4=rt*RestTime/rt2
					If rt4<=lamda Then
						If rt4<=RestTime+ZERO Then
							If Not ( (rt<=ZERO) And (uveloc.dot(norm)>ZERO) ) Then
								normal.Equal(norm)
								point=OldPos[i].Add(uveloc.MultVal(rt))
								lamda=rt4
								BallNr=i
							EndIf
						EndIf
					EndIf
				EndIf
					
				If (TestIntersionPlane(pl3,OldPos[i],uveloc,rt,norm)) Then
					rt4=rt*RestTime/rt2
					If rt4<=lamda Then
						If rt4<=RestTime+ZERO Then
							If Not ( (rt<=ZERO) And (uveloc.dot(norm)>ZERO) ) Then
								normal.Equal(norm)
								point=OldPos[i].Add(uveloc.MultVal(rt))
								lamda=rt4
								BallNr=i
							EndIf
						EndIf
					EndIf
				EndIf
	
				If (TestIntersionPlane(pl4,OldPos[i],uveloc,rt,norm)) Then
					rt4=rt*RestTime/rt2
					If rt4<=lamda Then
						If rt4<=RestTime+ZERO Then
							If Not ( (rt<=ZERO) And (uveloc.dot(norm)>ZERO) ) Then
								normal.Equal(norm)
								point=OldPos[i].Add(uveloc.MultVal(rt))
								lamda=rt4
								BallNr=i
							EndIf
						EndIf
					EndIf
				EndIf
	
				If (TestIntersionPlane(pl5,OldPos[i],uveloc,rt,norm)) Then
					rt4=rt*RestTime/rt2
					If rt4<=lamda Then
						If rt4<=RestTime+ZERO Then
							If Not ( (rt<=ZERO) And (uveloc.dot(norm)>ZERO) ) Then
								normal.Equal(norm)
								point=OldPos[i].Add(uveloc.MultVal(rt))
								lamda=rt4
								BallNr=i
							EndIf
						EndIf
					EndIf
				EndIf
	
				' Now test intersection with the 3 cylinders
				If (TestIntersionCylinder(cyl1,OldPos[i],uveloc,rt,norm,Nc)) Then
					rt4=rt*RestTime/rt2
					If rt4<=lamda Then
						If rt4<=RestTime+ZERO Then
							If Not ( (rt<=ZERO) And (uveloc.dot(norm)>ZERO) ) Then
								normal.Equal(norm)
								point=Nc
								lamda=rt4
								BallNr=i
							EndIf
						EndIf
					EndIf
				EndIf
				
				If (TestIntersionCylinder(cyl2,OldPos[i],uveloc,rt,norm,Nc)) Then
					rt4=rt*RestTime/rt2
					If rt4<=lamda Then
						If rt4<=RestTime+ZERO Then
							If Not ( (rt<=ZERO) And (uveloc.dot(norm)>ZERO) ) Then
								normal.Equal(norm)
								point=Nc
								lamda=rt4
								BallNr=i
							EndIf
						EndIf
					EndIf
				EndIf
		
				If (TestIntersionCylinder(cyl3,OldPos[i],uveloc,rt,norm,Nc)) Then
					rt4=rt*RestTime/rt2
					If rt4<=lamda Then
						If rt4<=RestTime+ZERO Then
							If Not ( (rt<=ZERO) And (uveloc.dot(norm)>ZERO) ) Then
								normal.Equal(norm)
								point=Nc
								lamda=rt4
								BallNr=i
							EndIf
						EndIf
					EndIf
				EndIf
			Next
	
			' After all balls were teste with planes/cylinders test For collision
			' between them And Replace If collision time smaller
			If (FindBallCol(Pos2,BallTime,RestTime,BallColNr1,BallColNr2)) Then
				If sounds Then
					PlaySound sound
				EndIf
				If (lamda=10000.0) Or (lamda>BallTime) Then
					RestTime=RestTime-BallTime
						
					Local pb1:TVector, pb2:TVector, xaxis:TVector, U1x:TVector, U1y:TVector
					Local U2x:TVector, U2y:TVector, V1x:TVEctor, V1y:TVector, V2x:TVector
					Local V2y:TVector
					Local a:Double, b:Double
	
					pb1=OldPos[BallColNr1].Add(ArrayVel[BallColNr1].MultVal(BallTime))
					pb2=OldPos[BallColNr2].Add(ArrayVel[BallColNr2].MultVal(BallTime))
	
					xaxis=(pb2.Sub(pb1)).unit()
					a=xaxis.dot(ArrayVel[BallColNr1])
					U1x=xaxis.MultVal(a)
					U1y=ArrayVel[BallColNr1].Sub(U1x)
	
					xaxis=(pb1.Sub(pb2)).unit()
					b=xaxis.dot(ArrayVel[BallColNr2])
					U2x=xaxis.MultVal(b)
					U2y=ArrayVel[BallColNr2].Sub(U2x)
	
					V1x=( (U1x.Add(U2x)).Sub(U1x.Sub(U2x)) ).MultVal(0.5)
					V2x=( (U1x.Add(U2x)).Sub(U2x.Sub(U1x)) ).MultVal(0.5)
					'V1y.Equal(U1y)
					'V2y.Equal(U2y)
					V1y=U1y
					V2y=U2y
					
					For Local j:Int=0 Until NrOfBalls
						ArrayPos[j]=OldPos[j].Add(ArrayVel[j].MultVal(BallTime))
					Next
						
					ArrayVel[BallColNr1]=V1x.Add(V1y)
					ArrayVel[BallColNr2]=V2x.Add(V2y)
	
					' Update explosion array
					For Local j:Int=0 Until 20
						If ExplosionArray[j]._Alpha<=0 Then
							ExplosionArray[j]._Alpha=1
							ExplosionArray[j]._Position.Equal(ArrayPos[BallColNr1])
							ExplosionArray[j]._Scale=1
							Exit
						EndIf
					Next
					Continue
				EndIf
			EndIf
			' End of tests 
	
			' If test occured move simulation for the correct timestep
			' And compute response for the colliding ball
			If lamda <> 10000.0
				RestTime:-lamda
				For Local j:Int=0 Until NrOfBalls
					ArrayPos[j]=OldPos[j].Add(ArrayVel[j].MultVal(lamda))
				Next
				rt2=ArrayVel[BallNr].mag()
				ArrayVel[BallNr].unit()
				ArrayVel[BallNr]=TVector.unit1((normal.MultVal(2.0*(normal.dot(ArrayVel[BallNr].Negat())))).Add(ArrayVel[BallNr]))
				ArrayVel[BallNr]=ArrayVel[BallNr].MultVal(rt2)
	
				' Update explosion array
				For Local j:Int=0 Until 20
					If ExplosionArray[j]._Alpha<=0 Then
						ExplosionArray[j]._Alpha=1
						ExplosionArray[j]._Position=point
						ExplosionArray[j]._Scale=1
						Exit
					EndIf
				Next
			Else 
				RestTime=0
			EndIf
		Wend
	End Method
	'
	'*************************************************************************************
	'*************************************************************************************
	'***        Init Variables                                                        ****
	'*************************************************************************************
	Method InitVars()
		' create palnes
		pl1._Position=TVector.Constructor(0,-300,0)
		pl1._Normal=TVector.Constructor(0,1,0)
		pl2._Position=TVector.Constructor(300,0,0)
		pl2._Normal=TVector.Constructor(-1,0,0);
		pl3._Position=TVector.Constructor(-300,0,0)
		pl3._Normal=TVector.Constructor(1,0,0)
		pl4._Position=TVector.Constructor(0,0,300)
		pl4._Normal=TVector.Constructor(0,0,-1)
		pl5._Position=TVector.Constructor(0,0,-300)
		pl5._Normal=TVector.Constructor(0,0,1)
	
		' create cylinders
		cyl1._Position=TVector.Constructor(0,0,0)
		cyl1._Axis=TVector.Constructor(0,1,0)
		cyl1._Radius=60+20
		cyl2._Position=TVector.Constructor(200,-300,0)
		cyl2._Axis=TVector.Constructor(0,0,1)
		cyl2._Radius=60+20
		cyl3._Position=TVector.Constructor(-200,0,0)
		cyl3._Axis=TVector.Constructor(0,1,1)
		cyl3._Axis.unit()
		cyl3._Radius=30+20
		
		' create quadratic Object To render cylinders
		cylinder_obj=Int Ptr gluNewQuadric()
		gluQuadricTexture(cylinder_obj, GL_TRUE)
	
	    ' Set initial positions And velocities of balls
		' also initialize array which holds explosions
		NrOfBalls=10
		ArrayVel[0]=TVector.Constructor1(veloc)
		ArrayPos[0]=TVector.Constructor(199,180,10)
		OldPos[0]=TVector.Constructor1(ArrayPos[0])
		ExplosionArray[0]=New Explosion
		ExplosionArray[0]._Alpha=0
		ExplosionArray[0]._Scale=1
		ArrayVel[1]=TVector.Constructor1(veloc)
		ArrayPos[1]=TVector.Constructor(0,150,100)
		OldPos[1]=TVector.Constructor1(ArrayPos[1])
		ExplosionArray[1]=New Explosion
		ExplosionArray[1]._Alpha=0
		ExplosionArray[1]._Scale=1
		ArrayVel[2]=TVector.Constructor1(veloc)
		ArrayPos[2]=TVector.Constructor(-100,180,-100)
		OldPos[2]=TVector.Constructor1(ArrayPos[2])
		ExplosionArray[2]=New Explosion
		ExplosionArray[2]._Alpha=0
		ExplosionArray[2]._Scale=1
		For Local i=3 Until 10
			ArrayVel[i]=TVector.Constructor1(veloc)
			ArrayPos[i]=TVector.Constructor(-500+i*75, 300, -500+i*50)
			OldPos[i]=TVector.Constructor1(ArrayPos[i])
			ExplosionArray[i]=New Explosion
			ExplosionArray[i]._Alpha=0
			ExplosionArray[i]._Scale=1
		Next
		For Local i:int=10 Until 20
			ExplosionArray[i]=New Explosion
			ExplosionArray[i]._Alpha=0
			ExplosionArray[i]._Scale=1
		Next
	End Method
	'
	'*************************************************************************************
	'***        Fast Intersection method between ray/plane                          ****
	'*************************************************************************************
	Method TestIntersionPlane:Int(plane:Plane, position:TVector, direction:TVector, lamda:Double Var, pNormal:TVector Var)
		Local DotProduct:Double=direction.dot(plane._Normal)
		Local l2:Double
		' determine If ray paralle To plane
		If (DotProduct<ZERO) And (DotProduct>-ZERO) Then Return False
		l2=(plane._Normal.dot(plane._Position.Sub(position)))/DotProduct
		If  l2<-ZERO Then Return False
		pNormal.Equal(plane._Normal)
		lamda=l2
		Return True
	End Method
	'
	'*************************************************************************************
	'***        Fast Intersection method between ray/cylinder                       ****
	'*************************************************************************************
	Method TestIntersionCylinder:Int(cylinder:Cylinder, position:TVector, direction:TVector, lamda:Double Var, pNormal:TVector Var, newposition:TVector Var)
		Local RC:TVector
		Local d:Double
		Local t:Double, s:Double
		Local n:TVector, O:TVector
		Local ln:Double
		Local in:Double, out:Double
		
		RC=TVector.Substract(position,cylinder._Position)
		n=TVector.Cross(direction,cylinder._Axis)
	
		ln=n.mag()
		If (ln<ZERO) And (ln>-ZERO) Then Return False
	
		n.unit()
	
		d=Abs(RC.dot(n))
		If d<=cylinder._Radius Then
			O = TVector.Cross(RC,cylinder._Axis)
			t = - O.dot(n)/ln
			O=TVector.Cross(n,cylinder._Axis)
			O.unit()
			s=Abs( Sqr(cylinder._Radius*cylinder._Radius - d*d) / direction.dot(O) )
	
			in=t-s
			out=t+s
	
			If in < -ZERO
				If out < -ZERO Then
					Return 0
				Else
					lamda=out
				EndIf
			ElseIf out < -ZERO Then
				lamda=in
			ElseIf in < out Then
				lamda=in
			Else
				lamda=out
			EndIf
	
			newposition=position.Add(direction.MultVal(lamda))
			Local HB:TVector
			HB=newposition.Sub(cylinder._Position)
			pNormal=HB.Sub(cylinder._Axis.MultVal((HB.dot(cylinder._Axis))))
			pNormal.unit()
			Return True
		EndIf
		Return False
	End Method
	'
	Method DrawMenu()
		glColor3f(1.0,1.0,1.0)
		GLDrawText("F1 : Hide/Show menu",10,ScreenHeight-16-8)
		If ShowMenu Then
			GLDrawText("Magic Room (lesson 30)",10,24)
		EndIf
	End Method

End Type