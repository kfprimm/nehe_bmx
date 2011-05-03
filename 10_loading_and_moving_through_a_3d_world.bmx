
Strict

Import "framework.bmx"

New TNeHe10.Run(10, "Loading and moving through a 3D world")

Type VERTEX
  Field x:Float, y:Float, z:Float
  Field u:Float, v:Float
End Type

Type TNeHe10 Extends TNeHe
	Field texname[3]
	Field numtriangles
	Field mytriangles:VERTEX[]
	Field worldfile$="data\world.txt"
	Field light,blend
	Field xrot#,yrot#
	Field walkbias#,walkbiasangle#
	Field lookupdown#
	Field heading#
	Field xpos#,zpos#
	Field filter 
	
	Method Init()
		Local tex:TPixmap=ConvertPixmap(LoadPixmap("data\mud.bmp"),PF_RGB888)
		Local width=tex.Width,height=tex.Height,data:Byte Ptr=PixmapPixelPtr(tex,0,0)
		
		' Create Nearest Filtered Texture
		glGenTextures 3, Varptr Texname[0]
		glBindTexture GL_TEXTURE_2D,Texname[0]
		glTexParameteri GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_NEAREST
		glTexParameteri GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST
		glTexImage2D GL_TEXTURE_2D, 0, 3, width, height, 0, GL_RGB, GL_UNSIGNED_BYTE, data
		' Create Linear Filtered Texture
		glBindTexture GL_TEXTURE_2D, Texname[1]
		glTexParameteri GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR
		glTexParameteri GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR
		glTexImage2D GL_TEXTURE_2D, 0, 3, width, height, 0, GL_RGB, GL_UNSIGNED_BYTE, data
		' Create MipMapped Texture
		glBindTexture GL_TEXTURE_2D, Texname[2]
		glTexParameteri GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR
		glTexParameteri GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR_MIPMAP_NEAREST
		gluBuild2DMipmaps GL_TEXTURE_2D, 3, width, height, GL_RGB, GL_UNSIGNED_BYTE, data

	
		glEnable GL_TEXTURE_2D
		glBlendFunc GL_SRC_ALPHA, GL_ONE
		glClearColor(0.0, 0.0, 0.0, 0.0)
		glClearDepth 1.0
		glDepthFunc GL_LESS
		glEnable GL_DEPTH_TEST
		glShadeModel(GL_SMOOTH)
		glViewport(0,0,SCREENWIDTH,SCREENHEIGHT)
		glMatrixMode(GL_PROJECTION)
		glLoadIdentity()
		gluPerspective(45.0,Float(SCREENWIDTH)/Float(SCREENHEIGHT),0.5,100.0)
		glMatrixMode(GL_MODELVIEW)

		glLightfv GL_LIGHT0, GL_AMBIENT, [0.5, 0.5, 0.5, 1.0]
		glLightfv GL_LIGHT0, GL_DIFFUSE, [1.0, 1.0, 1.0, 1.0]
		glLightfv GL_LIGHT0, GL_POSITION, [0.0, 0.0, 2.0, 1.0]
		glEnable GL_LIGHT0
		
		Local i:Int
		Local c:Int
		Local boom:Int
		Local vert:Int
		Local oneline:String
		Local sstring:String
	
		Local file:TStream=OpenFile(worldfile)
		Repeat  
			oneline=ReadLine(file)
			If Left(oneline, 11) = "NUMPOLLIES " Then
				sstring=Mid(oneline, 12)
				numtriangles=sstring.ToInt()
				Exit
			End If
		Until Eof(file)
	
		mytriangles=mytriangles:VERTEX[..numtriangles*3]
	
		For c = 0 To numtriangles - 1
			For vert = 0 To 2
				boom = 0
				Repeat
					oneline=ReadLine(file)
					oneline = Trim(oneline)
					If oneline <> "" Then
						If Left(oneline, 2) <> "//" Then
							mytriangles[c*3+vert]=New VERTEX
							mytriangles[c*3+vert].x = oneline.ToFloat()
							i = Instr(oneline, " ")
							oneline = Trim(Mid(oneline, i))
							mytriangles[c*3+vert].y = oneline.ToFloat()
							i = Instr(oneline, " ")
							oneline = Trim(Mid(oneline, i))
							mytriangles[c*3+vert].z = oneline.ToFloat()
							i = Instr(oneline, " ")
							oneline = Trim(Mid(oneline, i))
							mytriangles[c*3+vert].u = oneline.ToFloat()
							i = Instr(oneline, " ")
							oneline = Trim(Mid(oneline, i))
							mytriangles[c*3+vert].v = oneline.ToFloat()
							boom = 1
						End If
					End If
				Until boom = 1
			Next
		Next
		CloseStream file
	End Method
	
	Method Loop()
		Local x_m:Float; Local y_m:Float; Local z_m:Float; Local u_m:Float ; Local v_m:Float
		Local xtrans:Float; Local ztrans:Float; Local ytrans:Float
		Local sceneroty:Float
		Local loop_m:Int
	
		If KeyHit(KEY_B) Then
			blend = Not blend
		EndIf
		If blend = 0 Then
			glDisable GL_BLEND
			glEnable GL_DEPTH_TEST
		Else
			glEnable GL_BLEND
			glDisable GL_DEPTH_TEST
		End If
		
		If KeyHit(KEY_F)
			Filter:+1
			If Filter>2 Then Filter=0
		EndIf
		
		If KeyHit(KEY_L) Then
			light = Not light
		EndIf
		If light=0 Then
			glDisable(GL_LIGHTING)
		Else
			glEnable(GL_LIGHTING)
		EndIf
	
		If KeyDown(KEY_PAGEUP) Then
			lookupdown = lookupdown - 0.001
		End If
	
		If KeyDown(KEY_PAGEDOWN) Then
			lookupdown = lookupdown + 0.001
		End If
	
		If KeyDown(KEY_UP) Then
			xpos = xpos - Float(Sin(heading)) * 0.03
			zpos = zpos - Float(Cos(heading)) * 0.03
			If walkbiasangle >= 359.0 Then
				walkbiasangle = 0.0
			Else
				walkbiasangle = walkbiasangle + 10
			End If
			walkbias = Float(Sin(walkbiasangle)) / 200.0
		End If
	
		If KeyDown(KEY_DOWN) Then
			xpos = xpos + Float(Sin(heading)) * 0.03
			zpos = zpos + Float(Cos(heading)) * 0.03
			If walkbiasangle <= 1.0 Then
				walkbiasangle = 359.0
			Else
				walkbiasangle = walkbiasangle - 10
			End If
			walkbias = Float(Sin(walkbiasangle)) / 200.0
		End If
	
		If KeyDown(KEY_RIGHT) Then
			heading = heading - 0.6
			yrot = heading
		End If
	
		If KeyDown(KEY_LEFT) Then
			heading = heading + 0.6
			yrot = heading
		End If
	
		xtrans=-xpos
		ztrans=-zpos
		ytrans=-walkbias - 0.5
		sceneroty = 360.0 - yrot
		glClear GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT
		glLoadIdentity
		glRotatef lookupdown, 1.0, 0, 0
		glRotatef sceneroty, 0, 1.0, 0
		glTranslatef xtrans, ytrans, ztrans
		glBindTexture GL_TEXTURE_2D, Texname[filter]
	
		' Process Each Triangle
		For loop_m = 0 To (numtriangles - 1)*3 Step 3
			glBegin GL_TRIANGLES
				glNormal3f 0.0, 0.0, 1.0
				x_m = mytriangles[loop_m+0].x
				y_m = mytriangles[loop_m+0].y
				z_m = mytriangles[loop_m+0].z
				u_m = mytriangles[loop_m+0].u
				v_m = mytriangles[loop_m+0].v
				glTexCoord2f u_m,v_m ; glVertex3f x_m,y_m,z_m
	
				x_m = mytriangles[loop_m+1].x
				y_m = mytriangles[loop_m+1].y
				z_m = mytriangles[loop_m+1].z
				u_m = mytriangles[loop_m+1].u
				v_m = mytriangles[loop_m+1].v
				glTexCoord2f u_m,v_m ; glVertex3f x_m,y_m,z_m
	
				x_m = mytriangles[loop_m+2].x
				y_m = mytriangles[loop_m+2].y
				z_m = mytriangles[loop_m+2].z
				u_m = mytriangles[loop_m+2].u
				v_m = mytriangles[loop_m+2].v
				glTexCoord2f u_m,v_m ; glVertex3f x_m,y_m,z_m
			glEnd
		Next
	End Method	
End Type