
Strict

Import "framework.bmx"

New TNeHe3.Run(3, "Adding color")

Type TNeHe3 Extends TNeHe
	Method Init()
		glClearColor(0.0, 0.0, 0.0, 0.0)
		glClearDepth 1.0
		glDepthFunc(GL_LESS)
		glEnable(GL_DEPTH_TEST)
		glFrontFace(GL_CW)
		glShadeModel(GL_SMOOTH)
		glViewport(0,0,ScreenWidth,ScreenHeight)
		glMatrixMode(GL_PROJECTION)
		glLoadIdentity()
		gluPerspective(45.0,Float(SCREENWIDTH)/Float(SCREENHEIGHT),1.0,100.0)
		glMatrixMode(GL_MODELVIEW)
	End Method
	
	Method Loop()
		glClear GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT
		glLoadIdentity()
		glTranslatef(-1.5,0.0,-6.0)
		glBegin GL_POLYGON
			glColor3f 1.0,0.0,0.0              ' Set The Color To Red
			glVertex3f  0.0, 1.0, 0.0          ' Top
			glColor3f 0.0,1.0,0.0              ' Set The Color To Green
			glVertex3f  1.0,-1.0, 0.0          ' Bottom Right
			glColor3f 0.0,0.0,1.0              ' Set The Color To Blue
			glVertex3f -1.0,-1.0, 0.0          ' Bottom Left
		glEnd
		glTranslatef 3.0,0.0,0.0
		glColor3f 0.5,0.5,1.0                   ' // Set The Color To Blue One Time Only
		glBegin GL_QUADS
			glVertex3f -1.0, 1.0, 0.0          ' Top Left
			glVertex3f  1.0, 1.0, 0.0          ' Top Right
			glVertex3f  1.0,-1.0, 0.0          ' Bottom Right
			glVertex3f -1.0,-1.0, 0.0          ' Bottom Left
		glEnd
	End Method	
End Type
