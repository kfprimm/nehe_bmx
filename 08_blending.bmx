
Strict

Import "framework.bmx"

New TNeHe8.Run(8, "Blending")

Type TNeHe8 Extends TNeHe
	Field texname[3]
	Field lp,filter,bp
	Field z#=-5.0,xspeed#,yspeed#,zspeed#
	Field xrot#,yrot#
	
	Method Init()
		Local tex:TPixmap=ConvertPixmap(LoadPixmap("data\glass.bmp"),PF_RGB888)
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
	
		glClearColor(0.0, 0.0, 0.0, 0.0)
		glClearDepth 1.0
		glDepthFunc(GL_LESS)
		glEnable(GL_DEPTH_TEST)
		glShadeModel(GL_SMOOTH)
		glViewport(0,0,ScreenWidth,ScreenHeight)
		glMatrixMode(GL_PROJECTION)
		glLoadIdentity()
		gluPerspective(45.0,Float(ScreenWidth)/Float(ScreenHeight),1.0,100.0)
		glMatrixMode(GL_MODELVIEW)		

		glLightfv GL_LIGHT1, GL_AMBIENT, [0.5, 0.5, 0.5, 1.0]
		glLightfv GL_LIGHT1, GL_DIFFUSE, [1.0, 1.0, 1.0, 1.0]
		glLightfv GL_LIGHT1, GL_POSITION, [0.0, 0.0, 2.0, 1.0]
		glEnable GL_LIGHT1
		glColor4f 1.0,1.0,1.0,0.25
		glBlendFunc GL_SRC_ALPHA,GL_ONE
	End Method
	
	Method Loop()
		If  KeyHit(KEY_L) Then
			lp = Not lp
			If lp=0 Then
				glDisable(GL_LIGHTING)
			Else
				glEnable(GL_LIGHTING)
			EndIf
		EndIf
		
		
		If KeyHit(KEY_F)
			Filter:+1
			If Filter>2 Then Filter=0
		EndIf
		If KeyHit(KEY_B) Then
			Bp = Not Bp
			If Bp=0 Then
				glEnable GL_BLEND
				glDisable GL_DEPTH_TEST
			Else
				glDisable GL_BLEND
				glEnable GL_DEPTH_TEST
			EndIf
		EndIf		
		
		If KeyDown(KEY_PAGEUP) Then z:-0.02
		If KeyDown(KEY_PAGEDOWN) Then z:+ 0.02
		If KeyHit(KEY_UP) Then xspeed:-0.3
		If KeyHit(KEY_DOWN) Then xspeed:+0.3
		If KeyHit(KEY_RIGHT) Then yspeed:+0.3
		If KeyHit(KEY_LEFT) Then yspeed:-0.3
		
		glClear GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT
		glEnable GL_LIGHT1
		glEnable(GL_TEXTURE_2D)
		glBindTexture GL_TEXTURE_2D, Texname[Filter]
		
		glLoadIdentity
		glTranslatef 0.0,0.0,z
		glRotatef xrot,1.0,0.0,0.0
		glRotatef yrot,0.0,1.0,0.0
		glBegin GL_QUADS
			' Front Face
			glNormal3f  0.0, 0.0, 1.0
			glTexCoord2f 0.0, 0.0; glVertex3f -1.0, -1.0,  1.0
			glTexCoord2f 1.0, 0.0; glVertex3f  1.0, -1.0,  1.0
			glTexCoord2f 1.0, 1.0; glVertex3f  1.0,  1.0,  1.0
			glTexCoord2f 0.0, 1.0; glVertex3f -1.0,  1.0,  1.0
			' Back Face
			glNormal3f  0.0, 0.0,-1.0
			glTexCoord2f 1.0, 0.0; glVertex3f -1.0, -1.0, -1.0
			glTexCoord2f 1.0, 1.0; glVertex3f -1.0,  1.0, -1.0
			glTexCoord2f 0.0, 1.0; glVertex3f  1.0,  1.0, -1.0
			glTexCoord2f 0.0, 0.0; glVertex3f  1.0, -1.0, -1.0
			' Top Face
			glNormal3f  0.0, 1.0, 0.0
			glTexCoord2f 0.0, 1.0; glVertex3f -1.0,  1.0, -1.0
			glTexCoord2f 0.0, 0.0; glVertex3f -1.0,  1.0,  1.0
			glTexCoord2f 1.0, 0.0; glVertex3f  1.0,  1.0,  1.0
			glTexCoord2f 1.0, 1.0; glVertex3f  1.0,  1.0, -1.0
			' Bottom Face
			glNormal3f  0.0,-1.0, 0.0
			glTexCoord2f 1.0, 1.0; glVertex3f -1.0, -1.0, -1.0
			glTexCoord2f 0.0, 1.0; glVertex3f  1.0, -1.0, -1.0
			glTexCoord2f 0.0, 0.0; glVertex3f  1.0, -1.0,  1.0
			glTexCoord2f 1.0, 0.0; glVertex3f -1.0, -1.0,  1.0
			' Right face
			glNormal3f  1.0, 0.0, 0.0
			glTexCoord2f 1.0, 0.0; glVertex3f  1.0, -1.0, -1.0
			glTexCoord2f 1.0, 1.0; glVertex3f  1.0,  1.0, -1.0
			glTexCoord2f 0.0, 1.0; glVertex3f  1.0,  1.0,  1.0
			glTexCoord2f 0.0, 0.0; glVertex3f  1.0, -1.0,  1.0
			' Left Face
			glNormal3f -1.0, 0.0, 0.0
			glTexCoord2f 0.0, 0.0; glVertex3f -1.0, -1.0, -1.0
			glTexCoord2f 1.0, 0.0; glVertex3f -1.0, -1.0,  1.0
			glTexCoord2f 1.0, 1.0; glVertex3f -1.0,  1.0,  1.0
			glTexCoord2f 0.0, 1.0; glVertex3f -1.0,  1.0, -1.0
		glEnd
	
		xrot = xrot + xspeed
		yrot = yrot + yspeed
		glDisable(GL_TEXTURE_2D)
		glDisable GL_LIGHT1
	End Method	
End Type