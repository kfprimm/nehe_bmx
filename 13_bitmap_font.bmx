
Strict

Import "framework.bmx"

New TNeHe13.Run(13, "Bitmap Font")

Type TNeHe13 Extends TNeHe
	Field base:Int			' Base Display List For The Font
	Field cnt1:Float			' 1st Counter Used To Move Text & For Coloring
	Field cnt2:Float			' 2nd Counter Used To Move Text & For Coloring

	Method Init()
		glShadeModel(GL_SMOOTH)												' Enable Smooth Shading
		glClearColor(0.0, 0.0, 0.0, 0.5)										' Black Background
		glClearDepth(1.0)														' Depth Buffer Setup
		glEnable(GL_DEPTH_TEST)												' Enables Depth Testing
		glDepthFunc(GL_LEQUAL)													' The Type Of Depth Testing To Do
		glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST)						' Really Nice Perspective Calculations
		base=glFixedFontBitmaps()												' Bmax helper for font bitmap
	
		glViewport(0,0,ScreenWidth,ScreenHeight)								' Set viewport
		glMatrixMode(GL_PROJECTION)											' Select The Projection Matrix
		glLoadIdentity()														' Reset The Projection Matrix
		gluPerspective(45.0,Float(ScreenWidth)/Float(ScreenHeight),0.5,100.0)		' Calculate The Aspect Ratio Of The Window
		glMatrixMode(GL_MODELVIEW)												' Select The Modelview Matrix
		glLoadIdentity()														' Reset The Current Modelview Matrix
	End Method
	
	Method Loop()
		glClear GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT						' Clear The Screen And The Depth Buffer
		glLoadIdentity()														' Reset The Current Modelview Matrix
		glTranslatef(0.0,0.0,-1.0)												' Move One Unit Into The Screen
		' Pulsing Colors Based On Text Position
		glColor3f(1.0*Float(Cos(cnt1)),1.0*Float(Sin(cnt2)),1.0-0.5*Float(Cos(cnt1+cnt2)))
		' Position The Text On The Screen
		glRasterPos2f(-0.45+0.05*Float(Cos(cnt1)), 0.32*Float(Sin(cnt2)))
		glPrint("Active OpenGL Text With NeHe " + "".FromFloat(cnt1))				' Print GL Text To The Screen
		cnt1:+0.051															' Increase The First Counter
		cnt2:+0.005															' Increase The First Counter
		If cnt1>=360.0 Then cnt1=0.0
		If cnt2>=360.0 Then cnt2=0.0
	End Method	
End Type

Function glPrint(phrase:String)												' Custom GL "Print" Routine
	glPushAttrib(GL_LIST_BIT)												' Pushes The Display List Bits
	glListBase(base)														' Sets The Base Character To 32
	glCallLists(phrase.length, GL_UNSIGNED_BYTE, Byte Ptr phrase)				' Draws The Display List Text (Don't use Varptr)
	glPopAttrib()															' Pops The Display List Bits
End Function
