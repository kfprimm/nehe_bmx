Import brl.filesystem

' vertex in 3d-coordinate system
Type sPoint
	Field x:Float, y:Float, z:Float
End Type

' plane equation
Type sPlaneEq
	Field a:Float, b:Float, c:Float, d:Float
End Type

' structure describing an Object's face
Type sPlane
	Field p:Int[3]
	Field normals:sPoint[3]
	Field neigh:Int[3]
	Field PlaneEq:sPlaneEq
	Field visible:Byte
End Type

' Object structure
Type glObject
	Field nPlanes:Int, nPoints:Int
	Field points:sPoint[]
	Field planes:sPlane[]
End Type

' load Object
Function ReadObject(filename:String, o:glObject)
	Local i:Int
	Local oneline:String
	Local Pos1:Int, Pos2:Int, Pos3:Int, Pos4:Int, Pos5:Int, Pos6:Int
	Local Pos7:Int, Pos8:Int, Pos9:Int, Pos10:Int, Pos11:Int
	
	file=OpenFile(filename)											' Opens The File For Reading Text
	If Not file Then Return False
	
	' points
	oneline=ReadLine(file)												' Reads a line From File (filename)
	o.nPoints=oneline.ToInt()											' Assign number of points
	o.points=o.points:sPoint[..o.nPoints]								' Slice array to n points
	For i=0 Until o.nPoints
		oneline=ReadLine(file)											' Reads In The Next Line Of Text
		' Searches For 3 Floating Point Numbers, Store In rx,ry and rz
		Pos1=oneline.find(",",0)
		Pos2=oneline.find(",",Pos1+1)
		o.points[i]=New sPoint											' Initialize type sPoint
		o.points[i].x=oneline[..Pos1].ToFloat()							' Set Object (o) points[i].x Value To x
		o.points[i].y=oneline[Pos1+1..Pos2].ToFloat()					' Set Object (o) points[i].y Value To y
		o.points[i].z=oneline[Pos2+1..oneline.length].ToFloat()			' Set Object (o) points[i].z Value To z
	Next

	' planes
	oneline=ReadLine(file)												' Reads a line From File (filename)
	o.nPlanes=oneline.ToInt()											' Assign number of planes
	o.planes=o.planes:sPlane[..o.nPlanes]								' Slice array to n planes
	For i=0 Until o.nPlanes
		oneline=ReadLine(file)											' Reads In The Next Line Of Text	
		' Read plane structure
		Pos1=oneline.find(",",0)
		Pos2=oneline.find(",",Pos1+1)
		Pos3=oneline.find(",",Pos2+1)
		Pos4=oneline.find(",",Pos3+1)	
		Pos5=oneline.find(",",Pos4+1)
		Pos6=oneline.find(",",Pos5+1)
		Pos7=oneline.find(",",Pos6+1)
		Pos8=oneline.find(",",Pos7+1)
		Pos9=oneline.find(",",Pos8+1)
		Pos10=oneline.find(",",Pos9+1)
		Pos11=oneline.find(",",Pos10+1)
		o.planes[i]=New sPlane											' Initialize type sPlane
		o.planes[i].PlaneEq=New sPlaneEq								' Initialize type sPlaneEq
		' Assign index triangle 
		o.planes[i].p[0]=oneline[..Pos1].ToInt()-1						' Set Object (o) planes[i].p[0] to index 0 triangle
		o.planes[i].p[1]=oneline[Pos1+1..Pos2].ToInt()-1					' Set Object (o) planes[i].p[1] to index 1 triangle
		o.planes[i].p[2]=oneline[Pos2+1..Pos3].ToInt()-1					' Set Object (o) planes[i].p[2] to index 2 triangle
		' Assign normal vertex
		o.planes[i].normals[0]=New sPoint
		o.planes[i].normals[1]=New sPoint
		o.planes[i].normals[2]=New sPoint
		o.planes[i].normals[0].x=oneline[Pos3+1..Pos4].ToFloat()			' Set Object (o) planes[i].normals[0].x to normal point 1
		o.planes[i].normals[0].y=oneline[Pos4+1..Pos5].ToFloat()			' Set Object (o) planes[i].normals[0].y to normal point 1
		o.planes[i].normals[0].z=oneline[Pos5+1..Pos6].ToFloat()			' Set Object (o) planes[i].normals[0].z to normal point 1
		o.planes[i].normals[1].x=oneline[Pos6+1..Pos7].ToFloat()			' Set Object (o) planes[i].normals[1].x to normal point 1
		o.planes[i].normals[1].y=oneline[Pos7+1..Pos8].ToFloat()			' Set Object (o) planes[i].normals[1].y to normal point 1
		o.planes[i].normals[1].z=oneline[Pos8+1..Pos9].ToFloat()			' Set Object (o) planes[i].normals[1].z to normal point 1
		o.planes[i].normals[2].x=oneline[Pos9+1..Pos10].ToFloat()			' Set Object (o) planes[i].normals[2].x to normal point 1
		o.planes[i].normals[2].y=oneline[Pos10+1..Pos11].ToFloat()		' Set Object (o) planes[i].normals[2].y to normal point 1
		o.planes[i].normals[2].z=oneline[Pos11+1..oneline.length].ToFloat()' Set Object (o) planes[i].normals[2].z to normal point 1	
	Next
	CloseFile(file)
	Return True
End Function	

' Connectivity procedure - based on Gamasutra's article
' hard to explain here
Function SetConnectivity(o:glObject)
	Local p1i:Int, p2i:Int, p1j:Int, p2j:Int
	Local P01i:Int, P02i:Int, P01j:Int, P02j:Int
	Local i:Int,j:Int,ki:Int,kj:Int

	For i=0 Until o.nPlanes-1
		For j=i+1 Until o.nPlanes
			For ki=0 Until 3
				If Not o.planes[i].neigh[ki]
					For kj=0 Until 3
						p1i=ki
						p1j=kj
						p2i=(ki+1) Mod 3
						p2j=(kj+1) Mod 3

						p1i=o.planes[i].p[p1i]
						p2i=o.planes[i].p[p2i]
						p1j=o.planes[j].p[p1j]
						p2j=o.planes[j].p[p2j]

						P01i=((p1i+p2i)-Abs(p1i-p2i))/2
						P02i=((p1i+p2i)+Abs(p1i-p2i))/2
						P01j=((p1j+p2j)-Abs(p1j-p2j))/2
						P02j=((p1j+p2j)+Abs(p1j-p2j))/2

						If (P01i=P01j) And (P02i=P02j) Then					' they are neighbours
							o.planes[i].neigh[ki] = j+1
							o.planes[j].neigh[kj] = i+1
						EndIf
					Next
				EndIf
			Next
		Next
	Next
End Function

' Function For computing a plane equation given 3 points
Function CalcPlane(o:glObject)', plane:sPlane)
	Local v:sPoint[3]
	v[0]=New sPoint
	v[1]=New sPoint
	v[2]=New sPoint

	For i=0 Until o.nPlanes								' For each planes object
		For Local j=0 Until 3								' Copy each points
			v[j].x = o.points[o.planes[i].p[j]].x
			v[j].y = o.points[o.planes[i].p[j]].y
			v[j].z = o.points[o.planes[i].p[j]].z	
		Next
		' Comput plane equation
		o.planes[i].PlaneEq.a=v[0].y*(v[1].z-v[2].z) + v[1].y*(v[2].z-v[0].z) + v[2].y*(v[0].z-v[1].z)
		o.planes[i].PlaneEq.b=v[0].z*(v[1].x-v[2].x) + v[1].z*(v[2].x-v[0].x) + v[2].z*(v[0].x-v[1].x)
		o.planes[i].PlaneEq.c=v[0].x*(v[1].y-v[2].y) + v[1].x*(v[2].y-v[0].y) + v[2].x*(v[0].y-v[1].y)
		o.planes[i].PlaneEq.d=-( v[0].x*(v[1].y*v[2].z-v[2].y*v[1].z) + v[1].x*(v[2].y*v[0].z-v[0].y*v[2].z) + v[2].x*(v[0].y*v[1].z-v[1].y*v[0].z))
	Next
End Function

' Procedure For drawing the Object - very simple
Function DrawGLObject(o:glObject)
	Local i:Int, j:Int

	glBegin(GL_TRIANGLES)
	For i=0 Until o.nPlanes
		For j=0 Until 3
			glNormal3f(o.planes[i].normals[j].x,o.planes[i].normals[j].y,o.planes[i].normals[j].z)
			glVertex3f(o.points[o.planes[i].p[j]].x,o.points[o.planes[i].p[j]].y,o.points[o.planes[i].p[j]].z)
		Next
	Next
	glEnd()
End Function

Function CastShadow(o:glObject, lp:Float Ptr)
	Local i:Int, j:Int, k:Int, jj:Int
	Local p1:Int, p2:Int
	Local v1:sPoint=New sPoint, v2:sPoint=New sPoint
	Local side:Float

	' Set visual parameter
	For i=0 Until o.nPlanes
		' Chech To see If light is in front Or behind the plane (face plane)
		side=o.planes[i].PlaneEq.a*lp[0]+o.planes[i].PlaneEq.b*lp[1]+o.planes[i].PlaneEq.c*lp[2]+o.planes[i].PlaneEq.d*lp[3]
		If side>0 Then
			o.planes[i].visible = True
		Else
			o.planes[i].visible = False
		EndIf
	Next

 	glDisable(GL_LIGHTING)
	glDepthMask(GL_FALSE)
	glDepthFunc(GL_LEQUAL)

	glEnable(GL_STENCIL_TEST)
	glColorMask(0, 0, 0, 0)
	glStencilFunc(GL_ALWAYS, 1, $ffffffff)

	' first pass, stencil operation decreases stencil value
	glFrontFace(GL_CCW)
	glStencilOp(GL_KEEP, GL_KEEP, GL_INCR)
	For i=0 Until o.nPlanes
		If o.planes[i].visible Then
			For j=0 Until 3
				k = o.planes[i].neigh[j]
				If (Not k) Or (Not o.planes[k-1].visible) Then
					' here we have an edge, we must draw a polygon
					p1 = o.planes[i].p[j]
					jj = (j+1) Mod 3
					p2 = o.planes[i].p[jj]

					' calculate the length of the vector
					v1.x = (o.points[p1].x - lp[0])*100
					v1.y = (o.points[p1].y - lp[1])*100
					v1.z = (o.points[p1].z - lp[2])*100

					v2.x = (o.points[p2].x - lp[0])*100
					v2.y = (o.points[p2].y - lp[1])*100
					v2.z = (o.points[p2].z - lp[2])*100
					
					' draw the polygon
					glBegin(GL_TRIANGLE_STRIP)
						glVertex3f(o.points[p1].x,o.points[p1].y,o.points[p1].z)
						glVertex3f(o.points[p1].x + v1.x,o.points[p1].y + v1.y,o.points[p1].z + v1.z)
						glVertex3f(o.points[p2].x,o.points[p2].y,o.points[p2].z)
						glVertex3f(o.points[p2].x + v2.x,o.points[p2].y + v2.y,o.points[p2].z + v2.z)
					glEnd()
				EndIf
			Next
		EndIf
	Next
	' second pass, stencil operation increases stencil value
	glFrontFace(GL_CW)
	glStencilOp(GL_KEEP, GL_KEEP, GL_DECR)
	For i=0 Until o.nPlanes
		If o.planes[i].visible Then
			For j=0 Until 3
				k = o.planes[i].neigh[j]
				If (Not k) Or (Not o.planes[k-1].visible) Then
					' here we have an edge, we must draw a polygon
					p1 = o.planes[i].p[j]
					jj = (j+1) Mod 3
					p2 = o.planes[i].p[jj]

					' calculate the length of the vector
					v1.x = (o.points[p1].x - lp[0])*100
					v1.y = (o.points[p1].y - lp[1])*100
					v1.z = (o.points[p1].z - lp[2])*100

					v2.x = (o.points[p2].x - lp[0])*100
					v2.y = (o.points[p2].y - lp[1])*100
					v2.z = (o.points[p2].z - lp[2])*100
					
					' draw the polygon
					glBegin(GL_TRIANGLE_STRIP)
						glVertex3f(o.points[p1].x,o.points[p1].y,o.points[p1].z)
						glVertex3f(o.points[p1].x + v1.x,o.points[p1].y + v1.y,o.points[p1].z + v1.z)
						glVertex3f(o.points[p2].x,o.points[p2].y,o.points[p2].z)
						glVertex3f(o.points[p2].x + v2.x,o.points[p2].y + v2.y,o.points[p2].z + v2.z)
					glEnd()
				EndIf
			Next
		EndIf
	Next

	glFrontFace(GL_CCW)
	glColorMask(1, 1, 1, 1)

	' draw a shadowing rectangle covering the entire screen
	glColor4f(0.0, 0.0, 0.0, 0.4)
	glEnable(GL_BLEND)
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
	glStencilFunc(GL_NOTEQUAL, 0, $ffffffff)
	glStencilOp(GL_KEEP, GL_KEEP, GL_KEEP)
	glPushMatrix()
	glLoadIdentity()
	glBegin(GL_TRIANGLE_STRIP)
		glVertex3f(-0.1, 0.1,-0.10)
		glVertex3f(-0.1,-0.1,-0.10)
		glVertex3f( 0.1, 0.1,-0.10)
		glVertex3f( 0.1,-0.1,-0.10)
	glEnd()
	glPopMatrix()
	glDisable(GL_BLEND)

	glDepthFunc(GL_LEQUAL)
	glDepthMask(GL_TRUE)
	glEnable(GL_LIGHTING)
	glDisable(GL_STENCIL_TEST)
	glShadeModel(GL_SMOOTH)
End Function