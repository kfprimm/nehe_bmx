
Strict

Const SCREENWIDTH  = 800
Const SCREENHEIGHT = 600
Const SCREENDEPTH  = 0
Const SCREENHERTZ  = 60

Type TNeHe
	Method Init() Abstract
	Method Loop() Abstract
	
	Method Run(lesson_number, lesson_name$,flags:Int=GRAPHICS_BACKBUFFER|GRAPHICS_DEPTHBUFFER)
		AppTitle = "NeHe Tutorial "+lesson_number+": "+lesson_name 
		GLGraphics SCREENWIDTH,SCREENHEIGHT,SCREENDEPTH,SCREENHERTZ,flags
		
		Init
		
		While Not KeyDown(KEY_ESCAPE) And Not AppTerminate()
			Loop
			glDisable GL_LIGHTING
			glColor3f 1.0,1.0,1.0
			GLDrawText "FPS : "+GetFPS(),0,0
			Flip
		Wend
	End Method
	
	Function GetFPS()
		Global _fps,_ticks,_lastupdate
		If _lastupdate+1000<MilliSecs()
			_fps=_ticks
			_ticks=0
			_lastupdate=MilliSecs()
		Else
			_ticks:+1
		EndIf
		Return _fps
	End Function
End Type
