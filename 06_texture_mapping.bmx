
Strict

Import "framework.bmx"

New TNeHe6.Run(0, "Texture mapping")

Type TNeHe6 Extends TNeHe
	Field texname
	Field xrot#,yrot#,zrot#
	
	Method Init()
		Local PointeurImg:Byte Ptr
		Local TexWidth
		Local TexHeight
		Local tex01:TPixmap=LoadPixmap("data\NeHe.bmp")
		
		Local Checkimage:Byte[256,256,4]
		
		TexWidth=tex01.Width
		TexHeight=tex01.Height
		PointeurImg=PixmapPixelPtr(tex01,0,0)
		Local pp=0
		For Local y=TexHeight-1 To 0 Step -1
			For Local x=0 To TexWidth-1
				Checkimage[y,x,0]=PointeurImg[pp]
				Checkimage[y,x,1]=PointeurImg[pp+1]
				Checkimage[y,x,2]=PointeurImg[pp+2]
				Checkimage[y,x,3]=100
				pp=pp+3
			Next
		Next
		tex01=Null
		glPixelStorei(GL_UNPACK_ALIGNMENT,1)
		glGenTextures(1, Varptr Texname)
		glBindTexture(GL_TEXTURE_2D, Texname)
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT)
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT)
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST)
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST)
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, TexWidth, TexHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, Checkimage)
				
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
	End Method
	
	Method Loop()
		glClear GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT
   	glEnable(GL_TEXTURE_2D)
		glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE)
		glBindTexture GL_TEXTURE_2D,Texname
		
		glLoadIdentity
		glTranslatef 0.0,0.0,-5.0
		glRotatef xrot,1.0,0.0,0.0                         ' Rotate On The X Axis
		glRotatef yrot,0.0,1.0,0.0                         ' Rotate On The Y Axis
		glRotatef zrot,0.0,0.0,1.0                         ' Rotate On The Z Axis
	
		glBegin GL_QUADS
			' Front Face
			glTexCoord2f 0.0, 0.0; glVertex3f -1.0, -1.0, 1.0       ' Bottom Left Of The Texture And Quad
			glTexCoord2f 1.0, 0.0; glVertex3f  1.0, -1.0, 1.0       ' Bottom Right Of The Texture And Quad
			glTexCoord2f 1.0, 1.0; glVertex3f  1.0,  1.0, 1.0       ' Top Right Of The Texture And Quad
			glTexCoord2f 0.0, 1.0; glVertex3f -1.0,  1.0, 1.0       ' Top Left Of The Texture And Quad
			' Back Face
			glTexCoord2f 1.0, 0.0; glVertex3f -1.0, -1.0, -1.0      ' Bottom Right Of The Texture And Quad
			glTexCoord2f 1.0, 1.0; glVertex3f -1.0,  1.0, -1.0      ' Top Right Of The Texture And Quad
			glTexCoord2f 0.0, 1.0; glVertex3f  1.0,  1.0, -1.0      ' Top Left Of The Texture And Quad
			glTexCoord2f 0.0, 0.0; glVertex3f  1.0, -1.0, -1.0      ' Bottom Left Of The Texture And Quad
			' Top Face
			glTexCoord2f 0.0, 1.0; glVertex3f -1.0,  1.0, -1.0      ' Top Left Of The Texture And Quad
			glTexCoord2f 0.0, 0.0; glVertex3f -1.0,  1.0,  1.0      ' Bottom Left Of The Texture And Quad
			glTexCoord2f 1.0, 0.0; glVertex3f  1.0,  1.0,  1.0      ' Bottom Right Of The Texture And Quad
			glTexCoord2f 1.0, 1.0; glVertex3f  1.0,  1.0, -1.0      ' Top Right Of The Texture And Quad
			' Bottom Face
			glTexCoord2f 1.0, 1.0; glVertex3f -1.0, -1.0, -1.0      ' Top Right Of The Texture And Quad
			glTexCoord2f 0.0, 1.0; glVertex3f  1.0, -1.0, -1.0      ' Top Left Of The Texture And Quad
			glTexCoord2f 0.0, 0.0; glVertex3f  1.0, -1.0,  1.0      ' Bottom Left Of The Texture And Quad
			glTexCoord2f 1.0, 0.0; glVertex3f -1.0, -1.0,  1.0      ' Bottom Right Of The Texture And Quad
			' Right face
			glTexCoord2f 1.0, 0.0; glVertex3f  1.0, -1.0, -1.0      ' Bottom Right Of The Texture And Quad
			glTexCoord2f 1.0, 1.0; glVertex3f  1.0,  1.0, -1.0      ' Top Right Of The Texture And Quad
			glTexCoord2f 0.0, 1.0; glVertex3f  1.0,  1.0,  1.0      ' Top Left Of The Texture And Quad
			glTexCoord2f 0.0, 0.0; glVertex3f  1.0, -1.0,  1.0      ' Bottom Left Of The Texture And Quad
			' Left Face
			glTexCoord2f 0.0, 0.0; glVertex3f -1.0, -1.0, -1.0      ' Bottom Left Of The Texture And Quad
			glTexCoord2f 1.0, 0.0; glVertex3f -1.0, -1.0,  1.0      ' Bottom Right Of The Texture And Quad
			glTexCoord2f 1.0, 1.0; glVertex3f -1.0,  1.0,  1.0      ' Top Right Of The Texture And Quad
			glTexCoord2f 0.0, 1.0; glVertex3f -1.0,  1.0, -1.0      ' Top Left Of The Texture And Quad
		glEnd
	
		xrot = xrot + 0.081                     ' X Axis Rotation
		yrot = yrot + 0.054                     ' Y Axis Rotation
		zrot = zrot + 0.108                     ' Z Axis Rotation
		glDisable(GL_TEXTURE_2D)
	End Method	
End Type
