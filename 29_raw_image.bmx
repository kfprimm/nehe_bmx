Strict
Import "framework.bmx"

New TNeHe29.Run(29,"Raw Image")
	
Type TEXTURE_IMAGE
	Field width:Int							' Width of image in pixels
	Field height:Int							' Height of image in pixels
	Field format:Int							' Number of bytes per pixel
	Field data:Byte Ptr						' Texture data
End Type

Type TNeHe29 Extends TNeHe	
	
	Field xrot:Float								' X Rotation
	Field yrot:Float								' Y Rotation
	Field zrot:Float								' Z Rotation
	
	Field texture:Int							' Storage for 1 texture
	
	
	Field t1:TEXTURE_IMAGE						' Pointer to the texture image data type
	Field t2:TEXTURE_IMAGE						' Pointer to the texture image data type
	
	Field ShowMenu:Int = 0
	
	Method Init()
		t1 = AllocateTextureBuffer( 256, 256, 4 )							' Get An Image Structure
		If ReadTextureData("Data\Monitor.raw",t1) = 0 Then					' Fill The Image Structure With Data
			' Nothing Read?
			Notify("Could Not Read 'Monitor.raw' Image Data",True)
			End
		EndIf
		t2 = AllocateTextureBuffer( 256, 256, 4 )							' Second Image Structure
		If ReadTextureData("Data\GL.raw",t2) = 0 Then						' Fill The Image Structure With Data
			' Nothing Read?
			Notify("Could Not Read 'GL.raw' Image Data",True)
			End
		EndIf
		' Image To Blend In, Original Image, Src Start X & Y, Src Width & Height, Dst Location X & Y, Blend Flag, Alpha Value
		Blit(t2,t1,127,127,128,128,64,64,1,127)								' Call The Blitter Routine
		BuildTexture(t1)													' Load The Texture Map Into Texture Memory
		DeallocateTexture(t1)												' Clean Up Image Memory Because Texture Is
		DeallocateTexture(t2)												' In GL Texture Memory Now
		glEnable(GL_TEXTURE_2D)											' Enable Texture Mapping
		glShadeModel(GL_SMOOTH)											' Enables Smooth Color Shading
		glClearColor(0.0, 0.0, 0.0, 0.0)									' This Will Clear The Background Color To Black
		glClearDepth(1.0)													' Enables Clearing Of The Depth Buffer
		glEnable(GL_DEPTH_TEST)											' Enables Depth Testing
		glDepthFunc(GL_LESS)												' The Type Of Depth Test To Do
		
		glViewport(0,0,ScreenWidth,ScreenHeight)							' Reset The Current Viewport
		glMatrixMode(GL_PROJECTION)										' Select The Projection Matrix
		glLoadIdentity()													' Reset The Projection Matrix
		gluPerspective(45.0,Float(ScreenWidth)/Float(ScreenHeight),0.1,100.0)	' Calculate The Aspect Ratio Of The Window
		glMatrixMode(GL_MODELVIEW)											' Select The Modelview Matrix
		glLoadIdentity()
	End Method
	
	Method BuildTexture(tex:TEXTURE_IMAGE)
		glGenTextures(1, Varptr texture)
		glBindTexture(GL_TEXTURE_2D, texture)
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
		gluBuild2DMipmaps(GL_TEXTURE_2D, GL_RGB, tex.width, tex.height, GL_RGBA, GL_UNSIGNED_BYTE, tex.data)
	End Method
	
	Method Loop()
		If KeyHit(KEY_F1) Then ShowMenu=Not ShowMenu
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)					' Clear The Screen And The Depth Buffer
		glLoadIdentity()													' Reset The View
		glTranslatef(0.0,0.0,-5.0)
		glRotatef(xrot,1.0,0.0,0.0)
		glRotatef(yrot,0.0,1.0,0.0)
		glRotatef(zrot,0.0,0.0,1.0)
		glBindTexture(GL_TEXTURE_2D, texture)
		glBegin(GL_QUADS)
			' Front Face
			glNormal3f( 0.0, 0.0, 1.0)
			glTexCoord2f(1.0, 1.0); glVertex3f( 1.0,  1.0,  1.0)
			glTexCoord2f(0.0, 1.0); glVertex3f(-1.0,  1.0,  1.0)
			glTexCoord2f(0.0, 0.0); glVertex3f(-1.0, -1.0,  1.0)
			glTexCoord2f(1.0, 0.0); glVertex3f( 1.0, -1.0,  1.0)
			' Back Face
			glNormal3f( 0.0, 0.0,-1.0)
			glTexCoord2f(1.0, 1.0); glVertex3f(-1.0,  1.0, -1.0)
			glTexCoord2f(0.0, 1.0); glVertex3f( 1.0,  1.0, -1.0)
			glTexCoord2f(0.0, 0.0); glVertex3f( 1.0, -1.0, -1.0)
			glTexCoord2f(1.0, 0.0); glVertex3f(-1.0, -1.0, -1.0)
			' Top Face
			glNormal3f( 0.0, 1.0, 0.0)
			glTexCoord2f(1.0, 1.0); glVertex3f( 1.0,  1.0, -1.0)
			glTexCoord2f(0.0, 1.0); glVertex3f(-1.0,  1.0, -1.0)
			glTexCoord2f(0.0, 0.0); glVertex3f(-1.0,  1.0,  1.0)
			glTexCoord2f(1.0, 0.0); glVertex3f( 1.0,  1.0,  1.0)
			' Bottom Face
			glNormal3f( 0.0,-1.0, 0.0)
			glTexCoord2f(0.0, 0.0); glVertex3f( 1.0, -1.0,  1.0)
			glTexCoord2f(1.0, 0.0); glVertex3f(-1.0, -1.0,  1.0)
			glTexCoord2f(1.0, 1.0); glVertex3f(-1.0, -1.0, -1.0)
			glTexCoord2f(0.0, 1.0); glVertex3f( 1.0, -1.0, -1.0)
			' Right Face
			glNormal3f( 1.0, 0.0, 0.0)
			glTexCoord2f(1.0, 0.0); glVertex3f( 1.0, -1.0, -1.0)
			glTexCoord2f(1.0, 1.0); glVertex3f( 1.0,  1.0, -1.0)
			glTexCoord2f(0.0, 1.0); glVertex3f( 1.0,  1.0,  1.0)
			glTexCoord2f(0.0, 0.0); glVertex3f( 1.0, -1.0,  1.0)
			' Left Face
			glNormal3f(-1.0, 0.0, 0.0)
			glTexCoord2f(0.0, 0.0); glVertex3f(-1.0, -1.0, -1.0)
			glTexCoord2f(1.0, 0.0); glVertex3f(-1.0, -1.0,  1.0)
			glTexCoord2f(1.0, 1.0); glVertex3f(-1.0,  1.0,  1.0)
			glTexCoord2f(0.0, 1.0); glVertex3f(-1.0,  1.0, -1.0)
		glEnd()
	
		xrot:+0.3
		yrot:+0.2
		zrot:+0.4
		DrawMenu()
	End Method
	
	Method DrawMenu()
		glDisable(GL_TEXTURE_2D)	
		glDisable(GL_DEPTH_TEST)
		glColor3f(1.0,1.0,1.0)
		GLDrawText("F1 : Hide/Show menu",10,ScreenHeight-16-8)
		If ShowMenu Then
			GLDrawText("Andreas Loffler, Rob Fletcher & NeHe's Blitter & Raw Image Loading Tutorial (lesson 29)",10,24)
		EndIf
		glEnable(GL_TEXTURE_2D	)
		glEnable(GL_DEPTH_TEST)
	End Method
	
	' Allocate An Image Structure And Inside Allocate Its Memory Requirements
	Method AllocateTextureBuffer:TEXTURE_IMAGE( w:Int, h:Int, f:Int)
		Local ti:TEXTURE_IMAGE=New TEXTURE_IMAGE					' Create a new structure image
		Local c:Byte Ptr											' Pointer to block memory for image
	
		If ti <> Null Then
			ti.width=w											' Set Width
			ti.height=h											' Set Height
			ti.format=f											' Set Format
			c=MemAlloc(w * h * f)									' Allocate memory for data image
			If c Then
				ti.data = c
			Else
				Notify("Could Not Allocate Memory For A Texture Buffer",True)
				Return Null
			EndIf
		Else
			Notify("Could Not Allocate An Image Structure",True)
			Return Null
		EndIf
		Return ti												' Return structure image
	End Method
	
	' Free up the image data
	Method DeallocateTexture(t:TEXTURE_IMAGE)
		If t Then
			If t.data Then
				MemFree(t.data)
			EndIf
			t=Null
		EndIf
	End Method
	
	' Read A .RAW File In To The Allocated Image Buffer Using Data In The Image Structure Header.
	' Flip The Image Top To Bottom.  Returns 0 For Failure Of Read, Or Number Of Bytes Read.
	Method ReadTextureData(filename:String, t:TEXTURE_IMAGE)
		Local i:Int, j:Int, done:Int=0
		Local stride:Int=t.width*t.format							' Size of a row (Width * Bytes Per Pixel)
		Local p:Byte Ptr=t.data
		
		Local file:TStream=OpenFile(filename)
		If file Then
			For i=t.height-1 To 0 Step -1
				p=t.data + (i * stride)
				For j=0 Until t.width
					For Local k:Int=0 Until t.format-1
						p[0]=ReadByte(file)
						p:+1
						done:+1
					Next
					p[0]=255
					p:+1
				Next
			Next
			CloseFile(file)
		Else
			Notify("Unable To Open Image File",True)
		EndIf
		Return done
	End Method
	
	Method Blit(src:TEXTURE_IMAGE, dst:TEXTURE_IMAGE, src_xstart:Int, src_ystart:Int, src_width:Int, src_height:Int ,..
	              dst_xstart:Int, dst_ystart:Int, blend:Int, alpha:Int)
		Local i:Int ,j:Int ,k:Int
		Local s:Byte Ptr=src.data									' Source data
		Local d:Byte Ptr=dst.data									' Destination data
		
		' Clamp Alpha If Value Is Out Of Range
		If alpha>255 Then alpha=255
		If alpha<0 Then alpha=0
		
		' Check For Incorrect Blend Flag Values
		If blend<0 Then blend=0
		If blend>1 Then blend=1
	
		d = dst.data + (dst_ystart * dst.width * dst.format)			' Start Row - dst (Row * Width In Pixels * Bytes Per Pixel)
		s = src.data + (src_ystart * src.width * src.format)			' Start Row - src (Row * Width In Pixels * Bytes Per Pixel)
	
		For i=0 Until src_height									' Height Loop
			s = s + (src_xstart * src.format)						' Move Through Src Data By Bytes Per Pixel
			d = d + (dst_xstart * dst.format)						' Move Through Dst Data By Bytes Per Pixel
			For j=0 Until src_width								' Width Loop
				For k=0 Until src.format							' "n" Bytes At A Time
					If blend										' If Blending Is On
						d[0]=((s[0]*alpha)+(d[0]*(255-alpha))) Shr 8	' Multiply Src Data*alpha Add Dst Data*(255-alpha)
					Else											' Keep in 0-255 Range With >> 8
						d[0] = s[0]								' No Blending Just Do A Straight Copy
					EndIf
					d:+1
					s:+1
				Next
			Next
			d = d + (dst.width - (src_width + dst_xstart))*dst.format	' Add End Of Row
			s = s + (src.width - (src_width + src_xstart))*src.format	' Add End Of Row
		Next
	End Method

End Type