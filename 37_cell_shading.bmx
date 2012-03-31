Strict
Import "framework.bmx"

New TNeHe37.Run(37,"Cell Shading")

' User Defined Structures
Type MATRIX															' A Structure To Hold An OpenGL Matrix
	Field Data:Float[16]												' We Use [16] Due To OpenGL's Matrix Format
End Type
Type VECTOR															' A Structure To Hold A Single Vector
	Field x:Float, y:Float, z:Float										' The Components Of The Vector
End Type
Type VERTEX															' A Structure To Hold A Single Vertex
	Field Nor:VECTOR=New VECTOR										' Vertex Normal
	Field Pos:VECTOR=New VECTOR										' Vertex Position
End Type
Type POLYGON															' A Structure To Hold A Single Polygon
	Field Verts:VERTEX[3]												' Array Of 3 VERTEX Structures
	Method New()
		Verts[0]=New VERTEX
		Verts[1]=New VERTEX
		Verts[2]=New VERTEX
	End Method
End Type

Type TNeHe37 Extends TNeHe
	Field outlineDraw:Byte=True											' Flag To Draw The Outline
	Field outlineSmooth:Byte=False											' Flag To Anti-Alias The Lines
	Field outlineColor:Float[]=[0.0, 0.0, 0.0]								' Color Of The Lines
	Field outlineWidth:Float=3.0											' Width Of The Lines
	
	Field lightAngle:VECTOR=New VECTOR										' The Direction Of The Light
	Field lightRotate:Byte=False											' Flag To See If We Rotate The Light
	
	Field modelAngle:Float=0.0											' Y-Axis Angle Of The Model
	Field modelRotate:Byte=False											' Flag To Rotate The Model
	
	Field polyData:POLYGON[]												' Polygon Data
	Field polyNum:Int=0													' Number Of Polygons
	
	Field shaderTexture:Int												' Storage For One Texture
	Field TickCount:Int													' Time passed
	
	Field ShowMenu:Int

	' Engine methods
	Method Init()														' Any GL Init Code & User Initialiazation Goes Here
		Local i:Int														' Looping Variable
		Local Line:String													' Storage For 255 Characters
		Local shaderData:Float[32,3]										' Storate For The 96 Shader Values
	
		TickCount=MilliSecs()
			
		' Start Of User Initialization
		glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST)					' Realy Nice perspective calculations
		glClearColor(0.7, 0.7, 0.7, 0.0)									' Light Grey Background
		glClearDepth(1.0)													' Depth Buffer Setup
		glEnable(GL_DEPTH_TEST)											' Enable Depth Testing
		glDepthFunc(GL_LESS)												' The Type Of Depth Test To Do
		glShadeModel(GL_SMOOTH)											' Enables Smooth Color Shading
		glDisable(GL_LINE_SMOOTH)											' Initially Disable Line Smoothing
		glEnable (GL_CULL_FACE)											' Enable OpenGL Face Culling
		glDisable (GL_LIGHTING)											' Disable OpenGL Lighting
	
		Local In:TStream=OpenFile("Data/shader.txt")										' Open The Shader File
		If In Then														' Check To See If The File Opened
			For Local i:Int=0 Until 32												' Loop Though The 32 Greyscale Values
				If Eof(In) Then Exit										' Check For The End Of The File
				Local Line:String=ReadLine(In)											' Get The Current Line
				shaderData[i,0]=Line.ToFloat()								' Copy Over The Value
				shaderData[i,1]=Line.ToFloat()								' Copy Over The Value
				shaderData[i,2]=Line.ToFloat()								' Copy Over The Value
			Next
			CloseStream(In)												' Close The File
		Else
			Return False													' It Went Horribly Horribly Wrong
		EndIf
	
		glGenTextures(1, Varptr shaderTexture)								' Get A Free Texture ID
		glBindTexture(GL_TEXTURE_1D, shaderTexture)							' Bind This Texture. From Now On It Will Be 1D
		' For Crying Out Loud Don't Let OpenGL Use Bi/Trilinear Filtering!
		glTexParameteri(GL_TEXTURE_1D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);	
		glTexParameteri(GL_TEXTURE_1D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
		glTexImage1D(GL_TEXTURE_1D, 0, GL_RGB, 32, 0, GL_RGB , GL_FLOAT, shaderData)	' Upload
	
		lightAngle.x=1.0													' Set The X Direction
		lightAngle.y=0.0													' Set The Y Direction
		lightAngle.z=1.0													' Set The Z Direction
		Normalize(lightAngle)												' Normalize The Light Direction
		
		glViewport(0,0,ScreenWidth,ScreenHeight)							' Set viewport
		glMatrixMode(GL_PROJECTION)										' Select The Projection Matrix
		glLoadIdentity()													' Reset The Projection Matrix
		gluPerspective(45.0,Float(ScreenWidth)/Float(ScreenHeight),1.0,100.0)	' Calculate The Aspect Ratio Of The Window
		glMatrixMode(GL_MODELVIEW)											' Select The Modelview Matrix
		glLoadIdentity()													' Reset The Modelview Matrix
		
		Return ReadMesh()													' Return The Value Of ReadMesh
	End Method
	
	Method Loop()
		Local i:Int, j:Int												' Looping Variables
		Local TmpShade:Float												' Temporary Shader Value
		Local TmpMatrix:MATRIX=New MATRIX									' Temporary MATRIX Structure
		Local TmpVector:VECTOR=New VECTOR									' Temporary VECTOR Structure
		Local TmpNormal:VECTOR=New VECTOR									' Temporary VECTOR Structure
		
		If KeyHit(KEY_F1) Then ShowMenu=Not ShowMenu

		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)					' Clear The Buffers
		glLoadIdentity()													' Reset The Matrix
	
		If outlineSmooth Then												' Check To See If We Want Anti-Aliased Lines
			glHint(GL_LINE_SMOOTH_HINT, GL_NICEST)							' Use The Good Calculations
			glEnable(GL_LINE_SMOOTH)										' Enable Anti-Aliasing
		Else																' We Don't Want Smooth Lines
			glDisable(GL_LINE_SMOOTH)										' Disable Anti-Aliasing
		EndIf
		
		glTranslatef(0.0, 0.0, -2.0)										' Move 2 Units Away From The Screen
		glRotatef(modelAngle, 0.0, 1.0, 0.0)								' Rotate The Model On It's Y-Axis
		glGetFloatv(GL_MODELVIEW_MATRIX, Varptr TmpMatrix.Data[0])			' Get The Generated Matrix
	
		' // Cel-Shading Code //
		glEnable(GL_TEXTURE_1D)											' Enable 1D Texturing
		glBindTexture(GL_TEXTURE_1D, shaderTexture)							' Bind Our Texture
		glColor3f(1.0, 1.0, 1.0)											' Set The Color Of The Model
		glBegin(GL_TRIANGLES)												' Tell OpenGL That We're Drawing Triangles
			For i=0 Until polyNum											' Loop Through Each Polygon
				For j=0 Until 3											' Loop Through Each Vertex
					TmpNormal.x=polyData[i].Verts[j].Nor.x					' Fill Up The TmpNormal Structure With
					TmpNormal.y=polyData[i].Verts[j].Nor.y					' The Current Vertices' Normal Values
					TmpNormal.z=polyData[i].Verts[j].Nor.z
					RotateVector(TmpMatrix, TmpNormal, TmpVector)			' Rotate This By The Matrix
					Normalize(TmpVector)									' Normalize The New Normal
					TmpShade=DotProduct(TmpVector, lightAngle)				' Calculate The Shade Value
					If TmpShade < 0.0 Then TmpShade = 0.0					' Clamp The Value To 0 If Negative
					glTexCoord1f(TmpShade)									' Set The Texture Co-ordinate As The Shade Value
					glVertex3fv(Varptr polyData[i].Verts[j].Pos.x)			' Send The Vertex Position
				Next
			Next
		glEnd()															' Tell OpenGL To Finish Drawing
	
		glDisable(GL_TEXTURE_1D)											' Disable 1D Textures
		' // Outline Code //
		If outlineDraw Then												' Check To See If We Want To Draw The Outline
			glEnable(GL_BLEND)											' Enable Blending
			glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA)					' Set The Blend Mode
			glPolygonMode(GL_BACK, GL_LINE)									' Draw Backfacing Polygons As Wireframes
			glLineWidth(outlineWidth)										' Set The Line Width
			glCullFace(GL_FRONT)											' Don't Draw Any Front-Facing Polygons
			glDepthFunc(GL_LEQUAL)											' Change The Depth Mode
			glColor3fv(Varptr outlineColor[0])								' Set The Outline Color
			glBegin(GL_TRIANGLES)											' Tell OpenGL What We Want To Draw
				For i=0 Until polyNum										' Loop Through Each Polygon
					For j=0 Until 3										' Loop Through Each Vertex
						glVertex3fv(Varptr polyData[i].Verts[j].Pos.x)		' Send The Vertex Position
					Next
				Next
			glEnd()														' Tell OpenGL We've Finished
			glDepthFunc(GL_LESS)											' Reset The Depth-Testing Mode
			glCullFace(GL_BACK)											' Reset The Face To Be Culled
			glPolygonMode(GL_BACK, GL_FILL)									' Reset Back-Facing Polygon Drawing Mode
			glDisable(GL_BLEND)											' Disable Blending
		EndIf
		update(MilliSecs()-TickCount)
		TickCount=MilliSecs()
		DrawMenu()
	End Method
	
	Method Update(milliseconds:Int)										' Perform Motion Updates Here
		If KeyHit(KEY_SPACE) Then											' Is the Space Bar Being Pressed?
			modelRotate= Not modelRotate									' Toggle Model Rotation On/Off
		EndIf
		If KeyHit(KEY_1) Then												' Is The Number 1 Being Pressed?
			outlineDraw= Not outlineDraw									' Toggle Outline Drawing On/Off
		EndIf
		If KeyHit(KEY_2) Then												' Is The Number 2 Being Pressed?
			outlineSmooth= Not outlineSmooth								' Toggle Anti-Aliasing On/Off
		EndIf
		If KeyHit(KEY_UP) Then												' Is The Up Arrow Being Pressed?
			outlineWidth:+1												' Increase Line Width
			If outlineWidth>10 Then outlineWidth=10
		EndIf
		If KeyHit(KEY_DOWN) Then											' Is The Down Arrow Being Pressed?
			outlineWidth:-1												' Decrease Line Width
			If outlineWidth<0 Then outlineWidth=0
		EndIf
		If modelRotate Then												' Check To See If Rotation Is Enabled
			modelAngle:+Float(milliseconds)/20.0							' Update Angle Based On The Clock
		EndIf
	End Method
	
	' File methods
	Method ReadMesh()													' Reads The Contents Of The "model.txt" File
		Local In:TStream=OpenFile("Data/model.txt")										' Open The File
		If Not In Then Return False										' Return False If File Not Opened
	
		Local count:Int, count1:Int
	
		polyNum=ReadInt(In)												' Read The Header (i.e. Number Of Polygons)
		polyData=polyData:POLYGON[..polyNum]								' Allocate The Memory
		For count=0 Until polyNum
			polyData[count]=New POLYGON
			For count1=0 To 2
				polyData[count].Verts[count1].Nor.x=ReadFloat(In)
				polyData[count].Verts[count1].Nor.y=ReadFloat(In)
				polyData[count].Verts[count1].Nor.z=ReadFloat(In)
				polyData[count].Verts[count1].Pos.x=ReadFloat(In)
				polyData[count].Verts[count1].Pos.y=ReadFloat(In)
				polyData[count].Verts[count1].Pos.z=ReadFloat(In)		
			Next
		Next
		CloseStream(In)													' Close The File
		Return True														' It Worked
	End Method
	
	
	' Math methods
	Method DotProduct:Float(V1:VECTOR, V2:VECTOR)							' Calculate The Angle Between The 2 Vectors
		Return V1.x * V2.x + V1.y * V2.y + V1.z * V2.z						' Return The Angle
	End Method
	
	Method Magnitude:Float(V:VECTOR)										' Calculate The Length Of The Vector
		Return Float(Sqr(V.x * V.x + V.y * V.y + V.z * V.z))					' Return The Length Of The Vector
	End Method
	
	Method Normalize(V:VECTOR)											' Creates A Vector With A Unit Length Of 1
		Local m:Float=Magnitude(V)											' Calculate The Length Of The Vector
		If m <> 0.0 Then													' Make Sure We Don't Divide By 0
			V.x :/ m														' Normalize The 3 Components
			V.y :/ m
			V.z :/ m
		EndIf
	End Method
	
	Method RotateVector(M:MATRIX, V:VECTOR, D:VECTOR)						' Rotate A Vector Using The Supplied Matrix
		D.x = (M.Data[0] * V.x) + (M.Data[4] * V.y) + (M.Data[8]  * V.z)		' Rotate Around The X Axis
		D.y = (M.Data[1] * V.x) + (M.Data[5] * V.y) + (M.Data[9]  * V.z)		' Rotate Around The Y Axis
		D.z = (M.Data[2] * V.x) + (M.Data[6] * V.y) + (M.Data[10] * V.z)		' Rotate Around The Z Axis
	End Method
	
	Method DrawMenu()
		glDisable(GL_TEXTURE_1D)	
		glDisable(GL_DEPTH_TEST)
		glColor3f(1.0,1.0,1.0)
		GLDrawText("F1 : Hide/Show menu",10,ScreenHeight-16-8)
		If ShowMenu Then
			GLDrawText("NeHe's Cel-Shading Tutorial (lesson 37)",10,24)
			GLDrawText("'SPACE' Rotate On/Off",10,56)
			GLDrawText("'1'     Toggle Outline Drawing On/Off",10,72)
			GLDrawText("'2'     Toggle Anti-Aliasing On/Off",10,88)
			GLDrawText("'DOWN'  Decrease Line Width",10,104)
			GLDrawText("'UP'    Increase Line Width",10,120)
		EndIf
		glEnable(GL_TEXTURE_1D	)
		glEnable(GL_DEPTH_TEST)
	End Method
End Type