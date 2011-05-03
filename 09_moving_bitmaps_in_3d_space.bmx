
Strict

Import "framework.bmx"

Const STARCOUNT = 50

New TNeHe9.Run(9, "Moving bitmaps in 3D space")

Type TStar
   Field r:Byte
   Field g:Byte
   Field b:Byte
   Field dist:Float
   Field angle:Float
End Type

Type TNeHe9 Extends TNeHe
	Field texname
	Field twinkle,zoom#,tilt#,spin#
	Field stars:TStar[]
	
	Method Init()
		Local tex:TPixmap=ConvertPixmap(LoadPixmap("data\Star.bmp"),PF_RGB888)
		Local width=tex.Width,height=tex.Height,data:Byte Ptr=PixmapPixelPtr(tex,0,0)

		' Create Nearest Filtered Texture
		glGenTextures 1, Varptr Texname
		glBindTexture GL_TEXTURE_2D,Texname
		glTexParameteri GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_NEAREST
		glTexParameteri GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST
		glTexImage2D GL_TEXTURE_2D, 0, 3, width, height, 0, GL_RGB, GL_UNSIGNED_BYTE, data
		
		glClearColor(0.0, 0.0, 0.0, 0.0)
		glShadeModel(GL_SMOOTH)
		glViewport(0,0,ScreenWidth,ScreenHeight)
		glMatrixMode(GL_PROJECTION)
		glLoadIdentity()
		gluPerspective(45.0,Float(SCREENWIDTH)/Float(SCREENHEIGHT),1.0,100.0)
		glMatrixMode(GL_MODELVIEW)
		glBlendFunc GL_SRC_ALPHA,GL_ONE
		glEnable GL_BLEND
		For Local i=0 To STARCOUNT-1
			stars=stars[..i+1]
			stars[i]=New TStar
			stars[i].angle=0.0
			stars[i].dist=(Float(i)/Float(50))*5.0
			stars[i].r=Rand(255)
			stars[i].g=Rand(255)
			stars[i].b=Rand(255)
		Next
	End Method
	
	Method Loop()
		If  KeyHit(KEY_T) Then
			twinkle= Not twinkle
		EndIf
		If KeyDown(KEY_UP) Then tilt:-0.005
		If KeyDown(KEY_DOWN) Then tilt:+0.005
		If KeyDown(KEY_RIGHT) Then zoom:-0.002
		If KeyDown(KEY_LEFT) Then zoom:+0.002
	
		glClear GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT
		glEnable(GL_TEXTURE_2D)
		glBindTexture GL_TEXTURE_2D, Texname
		For Local i = 0 To 20
			glLoadIdentity
			glTranslatef 0.0,0.0,zoom
			glRotatef tilt,1.0,0.0,0.0
			glRotatef stars[i].angle,0.0,1.0,0.0
			glTranslatef stars[i].dist,0.0,0.0
			glRotatef -stars[i].angle,0.0,1.0,0.0
			glRotatef -tilt,1.0,0.0,0.0
			If twinkle Then
				' Assign A Color Using Bytes
				glColor4ub stars[(50-i)-1].r,stars[(50-i)-1].g,stars[(50-i)-1].b,255
				glBegin GL_QUADS
					glTexCoord2f 0.0, 0.0; glVertex3f -1.0,-1.0, 0.0
					glTexCoord2f 1.0, 0.0; glVertex3f  1.0,-1.0, 0.0
					glTexCoord2f 1.0, 1.0; glVertex3f  1.0, 1.0, 0.0
					glTexCoord2f 0.0, 1.0; glVertex3f -1.0, 1.0, 0.0
				glEnd
			End If
			glRotatef spin,0.0,0.0,1.0
			' Assign A Color Using Bytes
			glColor4ub stars[i].r,stars[i].g,stars[i].b,255
			glBegin GL_QUADS
				glTexCoord2f 0.0, 0.0; glVertex3f -1.0,-1.0, 0.0
				glTexCoord2f 1.0, 0.0; glVertex3f  1.0,-1.0, 0.0
				glTexCoord2f 1.0, 1.0; glVertex3f  1.0, 1.0, 0.0
				glTexCoord2f 0.0, 1.0; glVertex3f -1.0, 1.0, 0.0
			glEnd
			spin = spin + 0.0001
			stars[i].angle = stars[i].angle + ((Float(i)/Float(50))/3.0)
			stars[i].dist = stars[i].dist - 0.001
			If stars[i].dist < 0.0 Then
				stars[i].dist = stars[i].dist + 10.0
				stars[i].r =Rand(255)
				stars[i].g =Rand(255)
				stars[i].b =Rand(255)
			End If
		Next
		glDisable(GL_TEXTURE_2D)
	End Method	
End Type