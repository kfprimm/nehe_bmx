
Strict

Import "framework.bmx"

New TNeHe5.Run(5, "3D Shapes")

Type TNeHe5 Extends TNeHe
	Field rtri#,rquad#

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
		gluPerspective(45.0,Float(ScreenWidth)/Float(ScreenHeight),1.0,100.0)
		glMatrixMode(GL_MODELVIEW)
	End Method
	
	Method Loop()
		glClear GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT
		glLoadIdentity
		glTranslatef -1.5,0.0,-6.0
		glRotatef rtri,0.0,1.0,0.0              '; Rotate The Triangle On The Y axis ( New )
		glBegin GL_POLYGON
			';Front
			glColor3f 1.0,0.0,0.0               '; Red
			glVertex3f  0.0, 1.0, 0.0           '; Top Of Triangle (Front)
			glColor3f 0.0,1.0,0.0               '; Green
			glVertex3f -1.0,-1.0, 1.0           '; Left Of Triangle (Front)
			glColor3f 0.0,0.0,1.0               '; Blue
			glVertex3f  1.0,-1.0, 1.0           '; Right Of Triangle (Front)
			';Right
			glColor3f 1.0,0.0,0.0               '; Red
			glVertex3f  0.0, 1.0, 0.0           '; Top Of Triangle (Right)
			glColor3f 0.0,0.0,1.0               '; Blue
			glVertex3f  1.0,-1.0, 1.0           '; Left Of Triangle (Right)
			glColor3f 0.0,1.0,0.0               '; Green
			glVertex3f  1.0,-1.0, -1.0          '; Right Of Triangle (Right)
			';Back
			glColor3f 1.0,0.0,0.0               '; Red
			glVertex3f  0.0, 1.0, 0.0           '; Top Of Triangle (Back)
			glColor3f 0.0,1.0,0.0               '; Green
			glVertex3f  1.0,-1.0, -1.0          '; Left Of Triangle (Back)
			glColor3f 0.0,0.0,1.0               '; Blue
			glVertex3f -1.0,-1.0, -1.0          '; Right Of Triangle (Back)
			';Left
			glColor3f 1.0,0.0,0.0               '; Red
			glVertex3f  0.0, 1.0, 0.0           '; Top Of Triangle (Left)
			glColor3f 0.0,0.0,1.0               '; Blue
			glVertex3f -1.0,-1.0,-1.0           '; Left Of Triangle (Left)
			glColor3f 0.0,1.0,0.0               '; Green
			glVertex3f -1.0,-1.0, 1.0           '; Right Of Triangle (Left)
		glEnd
	
		glLoadIdentity
		glTranslatef 1.5,0.0,-7.0               '; Move Right 1.5 Units And Into The Screen 1
		glRotatef rquad,1.0,1.0,1.0             '; Rotate The Quad On The X axis ( New )
		glColor3f 0.5,0.5,1.0                   '; Set The Color To Blue One Time Only
		glBegin GL_QUADS
			glColor3f 0.0,1.0,0.0               '; Set The Color To Blue
			glVertex3f  1.0, 1.0,-1.0           '; Top Right Of The Quad (Top)
			glVertex3f -1.0, 1.0,-1.0           '; Top Left Of The Quad (Top)
			glVertex3f -1.0, 1.0, 1.0           '; Bottom Left Of The Quad (Top)
			glVertex3f  1.0, 1.0, 1.0           '; Bottom Right Of The Quad (Top)
	
			glColor3f 1.0,0.5,0.0               '; Set The Color To Orange
			glVertex3f  1.0,-1.0, 1.0           '; Top Right Of The Quad (Bottom)
			glVertex3f -1.0,-1.0, 1.0           '; Top Left Of The Quad (Bottom)
			glVertex3f -1.0,-1.0,-1.0           '; Bottom Left Of The Quad (Bottom)
			glVertex3f  1.0,-1.0,-1.0           '; Bottom Right Of The Quad (Bottom)
	
			glColor3f 1.0,0.0,0.0               '; Set The Color To Red
			glVertex3f  1.0, 1.0, 1.0           '; Top Right Of The Quad (Front)
			glVertex3f -1.0, 1.0, 1.0           '; Top Left Of The Quad (Front)
			glVertex3f -1.0,-1.0, 1.0           '; Bottom Left Of The Quad (Front)
			glVertex3f  1.0,-1.0, 1.0           '; Bottom Right Of The Quad (Front)
	
			glColor3f 1.0,1.0,0.0               '; Set The Color To Yellow
			glVertex3f  1.0,-1.0,-1.0           '; Top Right Of The Quad (Back)
			glVertex3f -1.0,-1.0,-1.0           '; Top Left Of The Quad (Back)
			glVertex3f -1.0, 1.0,-1.0           '; Bottom Left Of The Quad (Back)
			glVertex3f  1.0, 1.0,-1.0           '; Bottom Right Of The Quad (Back)
	
			glColor3f 0.0,0.0,1.0               '; Set The Color To Blue
			glVertex3f -1.0, 1.0, 1.0           '; Top Right Of The Quad (Left)
			glVertex3f -1.0, 1.0,-1.0           '; Top Left Of The Quad (Left)
			glVertex3f -1.0,-1.0,-1.0           '; Bottom Left Of The Quad (Left)
			glVertex3f -1.0,-1.0, 1.0           '; Bottom Right Of The Quad (Left)
	
			glColor3f 1.0,0.0,1.0               '; Set The Color To Violet
			glVertex3f  1.0, 1.0,-1.0           '; Top Right Of The Quad (Right)
			glVertex3f  1.0, 1.0, 1.0           '; Top Left Of The Quad (Right)
			glVertex3f  1.0,-1.0, 1.0           '; Bottom Left Of The Quad (Right)
			glVertex3f  1.0,-1.0,-1.0           '; Bottom Right Of The Quad (Right)
		glEnd
	
		rtri = rtri + 0.5                      '; Increase The Rotation Variable For The Triangle ( New )
		rquad = rquad + 0.5                   '; Decrease The Rotation Variable For The Quad ( New )    
	End Method	
End Type
