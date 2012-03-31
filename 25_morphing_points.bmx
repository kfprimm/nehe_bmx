Strict

Import "framework.bmx"
	
New TNeHe25.Run(25,"Morphing Points")

Type Objet													' Structure For An Object
	Field verts:Int											' Number Of Vertices For The Object
 	Field points:VERTEX[]										' One Vertice (Vertex x,y & z)
End Type
	
Type VERTEX													' Structure For 3D Points
	Field x:Float, y:Float, z:Float								' X, Y & Z Points
End Type														' Called VERTEX
	
Type TNeHe25 Extends TNeHe
	Field ScreenWidth:Int=800
	Field ScreenHeight:Int=600
	Field ScreenDepth:Int=32

	Field showMenu:Int	
	Field xrot:Float, yrot:Float, zrot:Float						' X, Y & Z Rotation
	Field xspeed:Float, yspeed:Float, zspeed:Float					' X, Y & Z Spin Speed
	Field cx:Float, cy:Float, cz:Float=-15							' X, Y & Z Position
	
	Field key:Int=1												' Used To Make Sure Same Morph Key Is Not Pressed
	Field pas:Int=0, steps:Int=200									' Step Counter And Maximum Number Of Steps
	Field morph:Byte=False										' Default morph To False (Not Morphing)
	
	Field maxver:Int												' Will Eventually Hold The Maximum Number Of Vertices
	' Our 4 Morphable Objects (morph1,2,3 & 4)
	Field morph1:Objet=New Objet
	Field morph2:Objet=New Objet
	Field morph3:Objet=New Objet
	Field morph4:Objet=New Objet
	' Helper Object, Source Object, Destination Object
	Field helper:Objet=New Objet
	Field sour:Objet
	Field dest:Objet
	
	Field MorphMode:String[]=["Sphere","Torus","Tube","Cloud"]
	
	
	Method Init()
		glBlendFunc(GL_SRC_ALPHA,GL_ONE)									' Set The Blending method For Translucency
		glClearColor(0.0, 0.0, 0.0, 0.0)									' This Will Clear The Background Color To Black
		glClearDepth(1.0)													' Enables Clearing Of The Depth Buffer
		glDepthFunc(GL_LESS)												' The Type Of Depth Test To Do
		glEnable(GL_DEPTH_TEST)											' Enables Depth Testing
		glShadeModel(GL_SMOOTH)											' Enables Smooth Color Shading
		glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST)					' Really Nice Perspective Calculations
	
		maxver=0															' Sets Max Vertices To 0 By Default
		objload("data\sphere.txt", morph1)									' Load The First Object Into morph1 From File sphere.txt
		objload("data\torus.txt", morph2)									' Load The Second Object Into morph2 From File torus.txt
		objload("data\tube.txt", morph3)									' Load The Third Object Into morph3 From File tube.txt
	
		objallocate(morph4, 486)											' Manually Reserver Ram For A 4th 468 Vertice Object (morph4)
		For Local i=0 Until 486											' Loop Through All 468 Vertices
			morph4.points[i].x=Float(Rand(14))-7.0							' morph4 x Point Becomes A Random Float Value From -7 To 7
			morph4.points[i].y=Float(Rand(14))-7.0							' morph4 y Point Becomes A Random Float Value From -7 To 7
			morph4.points[i].z=Float(Rand(14))-7.0							' morph4 z Point Becomes A Random Float Value From -7 To 7
		Next
		
		objload("data\sphere.txt", helper)									' Load sphere.txt Object Into Helper (Used As Starting Point)
		' Source & Destination Are Set To Equal First Object (morph1)
		sour=morph1
		dest=sour
	
		glViewport(0,0,ScreenWidth,ScreenHeight)							' Set viewport
		glMatrixMode(GL_PROJECTION)										' Select The Projection Matrix
		glLoadIdentity()													' Reset The Projection Matrix
		gluPerspective(45.0,Float(ScreenWidth)/Float(ScreenHeight),0.1,100.0)	' Calculate The Aspect Ratio Of The Window
		glMatrixMode(GL_MODELVIEW)											' Select The Modelview Matrix
		glLoadIdentity()													' Reset The Modelview Matrix
	End Method
	
	Method Loop()
		Local tx:Float, ty:Float, tz:Float
		Local q:VERTEX=New VERTEX
		
		If KeyHit(KEY_F1) Then ShowMenu=Not ShowMenu
		If KeyDown(KEY_PAGEUP) Then zspeed:+0.001							' Is Page Up Being Pressed? Increase zspeed
		If KeyDown(KEY_PAGEDOWN) Then zspeed:-0.001							' Is Page Down Being Pressed? Decrease zspeed
		If KeyDown(KEY_UP) Then xspeed:-0.01								' Is Up Arrow Being Pressed? Decrease xspeed
		If KeyDown(KEY_DOWN) Then xspeed:+0.01								' Is Down Arrow Being Pressed? Increase xspeed
		If KeyDown(KEY_RIGHT) Then yspeed:+0.01								' Is Right Arrow Being Pressed? Increase yspeed
		If KeyDown(KEY_LEFT) Then yspeed:-0.01								' Is Left Arrow Being Pressed? Decrease yspeed
	
		If KeyDown(KEY_Q) Then cz:-0.01										' Is Q Key Being Pressed? Move Object Away From Viewer
		If KeyDown(KEY_Z) Then cz:+0.01										' Is Z Key Being Pressed? Move Object Towards Viewer
		If KeyDown(KEY_W) Then cy:+0.01										' Is W Key Being Pressed? Move Object Up
		If KeyDown(KEY_S) Then cy:-0.01										' Is S Key Being Pressed? Move Object Down
		If KeyDown(KEY_D) Then cx:+0.01										' Is D Key Being Pressed? Move Object Right
		If KeyDown(KEY_A) Then cx:-0.01										' Is A Key Being Pressed? Move Object Left
		
		If KeyHit(KEY_1) And key<>1 And Not morph Then						' Is 1 Pressed, key Not Equal To 1 And Morph False?
			key=1														' Sets key To 1 (To Prevent Pressing 1 2x In A Row)
			morph=True													' Set morph To True (Starts Morphing Process)
			dest=morph1													' Destination Object To Morph To Becomes morph1
		EndIf
		If KeyHit(KEY_2) And key<>2 And Not morph Then						' Is 2 Pressed, key Not Equal To 2 And Morph False?
			key=2														' Sets key To 2 (To Prevent Pressing 2 2x In A Row)
			morph=True													' Set morph To True (Starts Morphing Process)
			dest=morph2													' Destination Object To Morph To Becomes morph2
		EndIf
		If KeyHit(KEY_3) And key<>3 And Not morph Then						' Is 3 Pressed, key Not Equal To 3 And Morph False?
			key=3														' Sets key To 3 (To Prevent Pressing 3 2x In A Row)
			morph=True													' Set morph To True (Starts Morphing Process)
			dest=morph3													' Destination Object To Morph To Becomes morph3
		EndIf
		If KeyHit(KEY_4) And key<>4 And Not morph Then						' Is 4 Pressed, key Not Equal To 4 And Morph False?
			key=4														' Sets key To 4 (To Prevent Pressing 4 2x In A Row)
			morph=True													' Set morph To True (Starts Morphing Process)
			dest=morph4													' Destination Object To Morph To Becomes morph4
		EndIf
				
		glClear GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT					' Clear The Screen And The Depth Buffer
		glLoadIdentity()													' Reset The Current Modelview Matrix
		glTranslatef(cx,cy,cz)												' Translate The The Current Position To Start Drawing
		glRotatef(xrot,1,0,0)												' Rotate On The X Axis By xrot
		glRotatef(yrot,0,1,0)												' Rotate On The Y Axis By yrot
		glRotatef(zrot,0,0,1)												' Rotate On The Z Axis By zrot
		xrot:+xspeed; yrot:+yspeed; zrot:+zspeed							' Increase xrot,yrot & zrot by xspeed, yspeed & zspeed
	
		glBegin(GL_POINTS)												' Begin Drawing Points
			' Loop Through All The Verts Of morph1 (All Objects Have The Same Amount Of Verts For Simplicity, Could Use maxver Also)
			For Local i=0 Until morph1.verts
				If morph Then												' If morph Is True Calculate Movement Otherwise Movement=0
					calculate(q, i)
				Else
					q.x=q.y=q.z=0
				EndIf
				helper.points[i].x:-q.x									' Subtract q.x Units From helper.points[i].x (Move On X Axis)
				helper.points[i].y:-q.y									' Subtract q.y Units From helper.points[i].y (Move On Y Axis)
				helper.points[i].z:-q.z									' Subtract q.z Units From helper.points[i].z (Move On Z Axis)
				tx=helper.points[i].x										' Make Temp X Variable Equal To Helper's X Variable
				ty=helper.points[i].y										' Make Temp Y Variable Equal To Helper's Y Variable
				tz=helper.points[i].z										' Make Temp Z Variable Equal To Helper's Z Variable
	
				glColor3f(0,1,1)											' Set Color To A Bright Shade Of Off Blue
				glVertex3f(tx,ty,tz)										' Draw A Point At The Current Temp Values (Vertex)
				glColor3f(0,0.5,1)										' Darken Color A Bit
				tx:-2.0*q.x; ty:-2.0*q.y; tz:-2.0*q.z						' Calculate Two Positions Ahead
				glVertex3f(tx,ty,tz)										' Draw A Second Point At The Newly Calculate Position
				glColor3f(0,0,1)											' Set Color To A Very Dark Blue
				tx:-2.0*q.x; ty:-2.0*q.y; tz:-2.0*q.z						' Calculate Two More Positions Ahead
				glVertex3f(tx,ty,tz)										' Draw A Third Point At The Second New Position
				' This Creates A Ghostly Tail As Points Move
			Next
		glEnd()
	
		' If We're Morphing And We Haven't Gone Through All 200 Steps Increase Our Step Counter
		' Otherwise Set Morphing To False, Make Source=Destination And Set The Step Counter Back To Zero.
		If morph And pas<=steps Then
			pas:+1
		Else
			morph=False; sour=dest; pas=0
		EndIf
		DrawMenu()
	End Method
	
	Method DrawMenu()
		glDisable(GL_DEPTH_TEST)	
		glColor3f(1.0,1.0,1.0)
		GLDrawText("F1 : Hide/Show menu",10,ScreenHeight-16-8)
		If ShowMenu Then
			GLDrawText("Piotr Cieslak & NeHe's Morphing Points Tutorial (lesson 25)",10,24)
			GLDrawText("'1/2/3/4'  Morphing " + MorphMode[key-1],10,56)
			GLDrawText("'PAGEUP'   Increase Z speed",10,72)
			GLDrawText("'PAGEDOWN' Decrease Z speed",10,88)
			GLDrawText("'UP'       Decrease X speed",10,104)
			GLDrawText("'DOWN'     Increase X speed",10,120)	
			GLDrawText("'RIGHT'    Increase Y speed",10,136)
			GLDrawText("'LEFT'     Decrease Y speed",10,152)	
			GLDrawText("'Q'        Object Away Viewer",10,168)
			GLDrawText("'Z'        Object Towards Viewer",10,184)		
			GLDrawText("'W'        Object Up",10,200)
			GLDrawText("'S'        Object Down",10,216)	
			GLDrawText("'D'        Object Right",10,232)
			GLDrawText("'A'        Object Left",10,248)		
		EndIf
		glEnable(GL_DEPTH_TEST)
	End Method
	
	Method objallocate(k:Objet, n:Int)									' Allocate Memory For Each Object And Defines points
		k.points=k.points:VERTEX[..n]										' Slice array to n VERTEX
		For Local t=0 Until n												' Allocate type VERTEX to array
			k.points[t]=New VERTEX
		Next
	End Method
	
	Method objload(filename:String, k:Objet)								' Loads Object From File (name)
		Local ver:Int														' Will Hold Vertice Count
		Local rx:Float, ry:Float, rz:Float									' Hold Vertex X, Y & Z Position
		Local oneline:String												' Holds One Line Of Text (255 Chars Max)
		Local StartPos:Int=0												' Initial position
		Local StartPos0:Int												' First position of 'Space' string
		Local StartPos1:Int												' Second position of 'Space' string
	
		Local filein:TStream=OpenFile(filename)								' Opens The File For Reading Text
		oneline=ReadLine(filein)											' Reads a line From File (filename)
		StartPos=oneline.find(" ",StartPos)
		ver=oneline[StartPos+1..oneline.length].ToInt()						' Find and convert number of vertices
		k.verts=ver														' Sets Objects verts Variable To Equal The Value Of ver
		objallocate(k,ver)												' Jumps To Code That Allocates Ram To Hold The Object
		
		StartPos=0
		For Local i=0 Until ver											' Loops Through The Vertices
			oneline=ReadLine(filein)										' Reads In The Next Line Of Text
			' Searches For 3 Floating Point Numbers, Store In rx,ry and rz
			StartPos0=oneline.find("     ",StartPos)
			StartPos1=oneline.find("     ",StartPos0+1)
			k.points[i].x=oneline[StartPos..StartPos0].ToFloat()				' Sets Objects (k) points.x Value To rx
			k.points[i].y=oneline[StartPos0..StartPos1].ToFloat()				' Sets Objects (k) points.y Value To ry
			k.points[i].z=oneline[StartPos1..oneline.length].ToFloat()		' Sets Objects (k) points.z Value To rz
		Next		
		CloseFile(filein)													' Close The File
	
		If ver>maxver Then maxver=ver										' If ver Is Greater Than maxver Set maxver Equal To ver
	End Method	
	
	Method calculate(k:VERTEX, i:Int)										' Calculates Movement Of Points During Morphing
		k.x=(sour.points[i].x-dest.points[i].x)/steps						' k.x Value Equals Source x - Destination x Divided By Steps
		k.y=(sour.points[i].y-dest.points[i].y)/steps						' k.y Value Equals Source y - Destination y Divided By Steps
		k.z=(sour.points[i].z-dest.points[i].z)/steps						' k.z Value Equals Source z - Destination z Divided By Steps
	End Method
End Type