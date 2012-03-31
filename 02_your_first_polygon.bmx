
Strict

Import "framework.bmx"

New TNeHe2.Run(2, "Your first polygon")

Type TNeHe2 Extends TNeHe
	Method Init()		
		glClearColor(0.0, 0.0, 0.0, 0.0)
		glClearDepth 1.0
		glDepthFunc(GL_LESS)
		glEnable(GL_DEPTH_TEST)
		glFrontFace(GL_CW)
		glShadeModel(GL_SMOOTH)
		glViewport(0,0,SCREENWIDTH,SCREENHEIGHT)
		glMatrixMode(GL_PROJECTION)
		glLoadIdentity()
		gluPerspective(45.0,Float(SCREENWIDTH)/Float(SCREENHEIGHT),1.0,100.0)
		glMatrixMode(GL_MODELVIEW)
	End Method
	
	Method Loop()
		glClear GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT
		glLoadIdentity
		glTranslatef -1.5,0.0,-6.0
		glBegin GL_POLYGON
			glVertex3f  0.0, 1.0, 0.0          ' Top
			glVertex3f  1.0,-1.0, 0.0          ' Bottom Right
			glVertex3f -1.0,-1.0, 0.0          ' Bottom Left
		glEnd
		glTranslatef 3.0,0.0,0.0
		glBegin GL_QUADS
			glVertex3f -1.0, 1.0, 0.0          ' Top Left
			glVertex3f  1.0, 1.0, 0.0          ' Top Right
			glVertex3f  1.0,-1.0, 0.0          ' Bottom Right
			glVertex3f -1.0,-1.0, 0.0          ' Bottom Left
		glEnd
	End Method
End Type