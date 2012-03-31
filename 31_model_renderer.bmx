Strict
Import "framework.bmx"

New TNeHe31.Run(31,"Model Render")

' Mesh
Type Mesh
	Field m_materialIndex:Int
	Field m_numTriangles:Int
	Field m_pTriangleIndices:Int[]
End Type
' Material properties
Type Material
	Field m_ambient:Float[4], m_diffuse:Float[4], m_specular:Float[4], m_emissive:Float[4]
	Field m_shininess:Float
	Field m_texture:Int
	Field m_pTextureFilename:String
End Type
' Triangle structure
Type Triangle
	Field m_vertexNormals:Float[3,3]
	Field m_s:Float[3], m_t:Float[3]
	Field m_vertexIndices:Int[3]
End Type
' Vertex structure
Type Vertex
	Field m_boneID:Byte		' For skeletal animation
	Field m_location:Float[3]
End Type
' *********************************************************************************************
' Model class
' *********************************************************************************************
Type Model Abstract
	' Meshes used
	Field m_numMeshes:Int
	Field m_pMeshes:Mesh[]
	' Materials used
	Field m_numMaterials:Int
	Field m_pMaterials:Material[]
	' Triangles used
	Field m_numTriangles:Int
	Field m_pTriangles:Triangle[]
	' Vertices Used
	Field m_numVertices:Int
	Field m_pVertices:Vertex[]

	Method draw() 
		Local texEnabled:Byte=glIsEnabled(GL_TEXTURE_2D)
		' Draw by group
		For Local i:Int=0 Until m_numMeshes
			Local materialIndex:Int=m_pMeshes[i].m_materialIndex
			If materialIndex >= 0 Then
				glMaterialfv(GL_FRONT, GL_AMBIENT, m_pMaterials[materialIndex].m_ambient)
				glMaterialfv(GL_FRONT, GL_DIFFUSE, m_pMaterials[materialIndex].m_diffuse)
				glMaterialfv(GL_FRONT, GL_SPECULAR, m_pMaterials[materialIndex].m_specular)
				glMaterialfv(GL_FRONT, GL_EMISSION, m_pMaterials[materialIndex].m_emissive)
				glMaterialf(GL_FRONT, GL_SHININESS, m_pMaterials[materialIndex].m_shininess)

				If m_pMaterials[materialIndex].m_texture > 0 Then
					glBindTexture(GL_TEXTURE_2D, m_pMaterials[materialIndex].m_texture )
					glEnable(GL_TEXTURE_2D )
				Else
					glDisable(GL_TEXTURE_2D)
				EndIf
			Else
				' Material properties?
				glDisable(GL_TEXTURE_2D)
			EndIf
			glBegin(GL_TRIANGLES)
				For Local j:Int=0 Until m_pMeshes[i].m_numTriangles
					Local triangleIndex:Int = m_pMeshes[i].m_pTriangleIndices[j]
					For Local k:Int=0 Until 3
						Local index:Int = m_pTriangles[triangleIndex].m_vertexIndices[k]
						glNormal3fv(Varptr m_pTriangles[triangleIndex].m_vertexNormals[k,0])
						glTexCoord2f(m_pTriangles[triangleIndex].m_s[k], m_pTriangles[triangleIndex].m_t[k])
						glVertex3fv(Varptr m_pVertices[index].m_location[0])
					Next
				Next
			glEnd()
		Next
		If texEnabled Then
			glEnable(GL_TEXTURE_2D)
		Else
			glDisable(GL_TEXTURE_2D)
		EndIf
	End Method

	Method reloadTextures()
		For Local i:Int=0 Until m_numMaterials
			If m_pMaterials[i].m_pTextureFilename.length > 0 Then
				m_pMaterials[i].m_texture = LoadGLTexture(m_pMaterials[i].m_pTextureFilename)
			Else
				m_pMaterials[i].m_texture = 0
			EndIf
		Next
	End Method
End Type
'
' Those structures are for information only.
' MS3D STRUCTURES 
'' File header (structure size 14)
'Type MS3DHeader
'	Field m_ID:String
'	Field m_version:Int=0
'	Method New()
'		m_ID=m_ID[..10]
'	End Method
'End Type
'' Number of vertices
'nNumVertices:Short
'' Vertex information (structure size 15)
'Type MS3DVertex
'	Field m_flags:Byte
'	Field m_vertex:Float[3]
'	Field m_boneID:Byte
'	Field m_refCount:Byte
'End Type
'' Number of triangles
'nNumTriangles:Short
'' Triangle information (structure size 70)
'Type MS3DTriangle
'	Field m_flags:Short
'	Field m_vertexIndices:Short[3]
'	Field m_vertexNormals:Float[3,3]
'	Field m_s:Float[3], m_t:Float[3]
'	Field m_smoothingGroup:Byte
'	Field m_groupIndex:Byte
'End Type
'' Number of groups
'nNumGroups:Short
'' Group information (Structure size XX)
'Type MS3DGroup
'	Field m_flags:Byte
'	Field m_name:String
'	Field m_numtriangles:Short
'	Field m_triangleIndices:Short[]
'	Field m_materialIndex:Byte
'	Method New()
'		m_name=m_name[..32]
'		m_triangleIndices=m_triangleIndices[m_numtriangles]
'	End Method
'End Type
'' Material information (structure size 361)
'' Number of materials
'nNumMaterials:Short
'Type MS3DMaterial
'	Field m_name:String
'	Field m_ambient:Float[4]
'	Field m_diffuse:Float[4]
'	Field m_specular:Float[4]
'	Field m_emissive:Float[4]
'	Field m_shininess:Float		' 0.0 - 128.0
'	Field m_transparency:Float		' 0.0 - 1.0
'	Field m_mode:Byte				' 0, 1, 2 is unused now
'	Field m_texture:String
'	Field m_alphamap:String
'	Method New()
'		m_name=m_name[..32]
'		m_texture=m_texture[..128]
'		m_alphamap=m_alphamap[..128]
'	End Method
'End Type
'' Save some keyframer data
'fAnimationFPS:Float
'fCurrentTime:Float
'iTotalFrames:Int
'' Number of joints
'nNumJoints:Short
'' Joint information (Structure size XX)
'Type MS3DJoint
'	Field m_flags:Byte
'	Field m_name:String
'	Field m_parentName:String
'	Field m_rotation:Float[3]
'	Field m_translation:Float[3]
'	Field m_numRotationKeyframes:Short
'	Field m_numPositionKeyframes:Short
'	Field keyFramesRot:MS3SKeyframeRot[]	' Local animation matrices
'	Field keyFramesPos:MS3DKeyframePos[]	' Local animation matrices
'	Method New()
'		m_name=m_name[..32]
'		m_parentName=m_parentName[..32]
'		keyFramesRot=keyFramesRot[..m_numRotationKeyframes]
'		keyFramesPos=keyFramesPos[..m_numPositionKeyframes]
'	End Method
'End Type
'' Keyframe data (structure size 16 - 16)
'Type MS3DKeyframeRot
'	Field time:Float				' time in seconds
'	Field rotation:Float[3]		' x, y, z angles
'End Type
'Type MS3DKeyframePos
'	Field time:Float				' Time in seconds
'	Field position:Float[3]		' Local position
'End Type
'
' *********************************************************************************************
' Model MilkshapeModel
' *********************************************************************************************
Type MilkshapeModel Extends Model
	' Size of MS3D structure
	Field S_MS3DHeader:Int=14, S_MS3DVertex:Int=15, S_MS3DTriangle:Int=70
	Field S_MS3DMaterial:Int=361, S_MS3DJoint:Int=93, S_MS3DKeyframe:Int=16

	Method loadModelData(filename:String)
		Local In:TStream=OpenFile(filename)
		If Not In Then Return False
		Local File_Size:Int=FileSize(filename)

		Local i:Int, j:Int
		
		' Read headerfile
		Local ID:String=ReadString(In,10)
		' Is valid Milkshape3D model file
		If ID <> "MS3D000000" Then Return False
		Local Version:Int=ReadInt(In)
		' Is valid version (Version 1.3 and 1.4 is supported)
		If Version < 3 Or Version > 4 Then Return False
		
		' Read vertice info
		m_numVertices=ReadShort(In)													' Vertices count (stored)
		m_pVertices=m_pVertices[..m_numVertices]										' Resize vertice array
		For i=0 Until m_numVertices
			m_pVertices[i]=New VERTEX
			ReadByte(In)																' Read m_flags (discarded)
			m_pVertices[i].m_location[0]=ReadFloat(In)									' Read X coordinate (stored)
			m_pVertices[i].m_location[1]=ReadFloat(In)									' Read Y coordinate (stored)
			m_pVertices[i].m_location[2]=ReadFloat(In)									' Read Z coordinate (stored)
			m_pVertices[i].m_boneID=ReadByte(In)										' Read Bone ID (stored)
			ReadByte(In)																' Read Ref count (discarded)
		Next

		' Read triangle info
		m_numTriangles=ReadShort(In)													' Triangle count
		m_pTriangles=m_pTriangles[..m_numTriangles]										' Resize triangle array
		For i=0 Until m_numTriangles
			m_pTriangles[i]=New Triangle
			ReadShort(In)																' Read m_flags (discarded)
			m_pTriangles[i].m_vertexIndices[0]=ReadShort(In)								' Read vertex indice 1 (stored)
			m_pTriangles[i].m_vertexIndices[1]=ReadShort(In)								' Read vertex indice 2 (stored)
			m_pTriangles[i].m_vertexIndices[2]=ReadShort(In)								' Read vertex indice 3 (stored)
			m_pTriangles[i].m_vertexNormals[0,0]=ReadFloat(In)							' Read vertex 1 normal X (stored)
			m_pTriangles[i].m_vertexNormals[0,1]=ReadFloat(In)							' Read vertex 1 normal Y (stored)
			m_pTriangles[i].m_vertexNormals[0,2]=ReadFloat(In)							' Read vertex 1 normal Z (stored)
			m_pTriangles[i].m_vertexNormals[1,0]=ReadFloat(In)							' Read vertex 2 normal X (stored)
			m_pTriangles[i].m_vertexNormals[1,1]=ReadFloat(In)							' Read vertex 2 normal Y (stored)
			m_pTriangles[i].m_vertexNormals[1,2]=ReadFloat(In)							' Read vertex 2 normal Z (stored)			
			m_pTriangles[i].m_vertexNormals[2,0]=ReadFloat(In)							' Read vertex 3 normal X (stored)
			m_pTriangles[i].m_vertexNormals[2,1]=ReadFloat(In)							' Read vertex 3 normal Y (stored)
			m_pTriangles[i].m_vertexNormals[2,2]=ReadFloat(In)							' Read vertex 3 normal Z (stored)
			m_pTriangles[i].m_s[0]=ReadFloat(In)
			m_pTriangles[i].m_s[1]=ReadFloat(In)
			m_pTriangles[i].m_s[2]=ReadFloat(In)
			m_pTriangles[i].m_t[0]=ReadFloat(In)
			m_pTriangles[i].m_t[1]=ReadFloat(In)
			m_pTriangles[i].m_t[2]=ReadFloat(In)
			ReadByte(In)																' Read smooth group (discarded)
			ReadByte(In)																' Read group index (discarded)
		Next

		' Read mesh info
		m_numMeshes=ReadShort(In)														' Mesh count
		m_pMeshes=m_pMeshes[..m_numMeshes]												' Resize mesh array
		For i=0 Until m_numMeshes
			m_pMeshes[i]=New Mesh
			ReadByte(In)																' Read m_flags (discarded)
			ReadString(In,32)															' Read m_name (discarded)
			Local nTriangles:Int=ReadShort(In)													' Read triangle count
			m_pMeshes[i].m_pTriangleIndices=m_pMeshes[i].m_pTriangleIndices[..nTriangles]	' Resize array
			For j=0 Until nTriangles
				m_pMeshes[i].m_pTriangleIndices[j]=ReadShort(In)							' Read triangle index (stored)
			Next
			m_pMeshes[i].m_materialIndex = ReadByte(In)									' Read material index
			m_pMeshes[i].m_numTriangles = nTriangles
		Next

		' Read material info
		m_numMaterials=ReadShort(In)
		m_pMaterials=m_pMaterials[..m_numMaterials]
		For i=0 Until m_numMaterials
			m_pMaterials[i]=New Material
			ReadString(In,32)															' Read material name (discarded)
			m_pMaterials[i].m_ambient[0]=ReadFloat(In)									' Read ambient material (stored)
			m_pMaterials[i].m_ambient[1]=ReadFloat(In)									' Read ambient material (stored)
			m_pMaterials[i].m_ambient[2]=ReadFloat(In)									' Read ambient material (stored)
			m_pMaterials[i].m_ambient[3]=ReadFloat(In)									' Read ambient material (stored)
			m_pMaterials[i].m_diffuse[0]=ReadFloat(In)									' Read diffuse material (stored)
			m_pMaterials[i].m_diffuse[1]=ReadFloat(In)									' Read diffuse material (stored)
			m_pMaterials[i].m_diffuse[2]=ReadFloat(In)									' Read diffuse material (stored)
			m_pMaterials[i].m_diffuse[3]=ReadFloat(In)									' Read diffuse material (stored)			
			m_pMaterials[i].m_specular[0]=ReadFloat(In)									' Read specular material (stored)
			m_pMaterials[i].m_specular[1]=ReadFloat(In)									' Read specular material (stored)
			m_pMaterials[i].m_specular[2]=ReadFloat(In)									' Read specular material (stored)
			m_pMaterials[i].m_specular[3]=ReadFloat(In)									' Read specular material (stored)
			m_pMaterials[i].m_emissive[0]=ReadFloat(In)									' Read emissive material (stored)
			m_pMaterials[i].m_emissive[1]=ReadFloat(In)									' Read emissive material (stored)
			m_pMaterials[i].m_emissive[2]=ReadFloat(In)									' Read emissive material (stored)
			m_pMaterials[i].m_emissive[3]=ReadFloat(In)									' Read emissive material (stored)
			m_pMaterials[i].m_shininess=ReadFloat(In)									' Read shininess material (stored)
			ReadFloat(In)																' Read transparency (discarded)
			ReadByte(In)																' Read mode (discarded)
			m_pMaterials[i].m_pTextureFilename=ReadString(In,128)							' Read texture filename (stored)
			ReadString(In,128)														' Read alphamap (discarded)
		Next

		CloseStream(In)		
		Return True
	End Method
End Type
	
Type TNeHe31 Extends TNeHe
	'
	' ********************************************************************
	' fields vars
	' ********************************************************************
	'
	Field ScreenWidth:Int=800
	Field ScreenHeight:Int=600
	Field ScreenDepth:Int=32
	
	Field pModel:MilkshapeModel=New MilkshapeModel											' Holds The Model Data
	Field yrot:Float=0.0
	'
	' ********************************************************************
	' INITIALIZATION
	' ********************************************************************
	'
	Field ShowMenu:Int=0
	
	'
	'*************************************************************************************
	' FUNCTIONS
	'*************************************************************************************
	'
	Method Init()
		If Not pModel.loadModelData("data/model.ms3d") Then End					' Load Model
		pModel.reloadTextures()												' Load Model Texture
		
		glEnable(GL_TEXTURE_2D)												' Enable Texture Mapping ( New )
		glShadeModel(GL_SMOOTH)												' Enable Smooth Shading
		glClearColor(0.0, 0.0, 0.0, 0.5)										' Black Background
		glClearDepth(1.0)														' Depth Buffer Setup
		glEnable(GL_DEPTH_TEST)												' Enables Depth Testing
		glDepthFunc(GL_LEQUAL)													' The Type Of Depth Testing To Do
		glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST)						' Really Nice Perspective Calculations
	
		glViewport(0,0,ScreenWidth,ScreenHeight)								' Set viewport
		glMatrixMode(GL_PROJECTION)											' Select The Projection Matrix
		glLoadIdentity()														' Reset The Projection Matrix
		gluPerspective(45.0,Float(ScreenWidth)/Float(ScreenHeight),1.0,1000.0)		' Calculate The Aspect Ratio Of The Window
		glMatrixMode(GL_MODELVIEW)												' Select The Modelview Matrix
		glLoadIdentity()														' Reset The Modelview Matrix
																			' Initialization Went OK
	End Method
	
	Method Loop()
		If KeyHit(KEY_F1) Then ShowMenu=Not ShowMenu
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)						' Clear The Screen And The Depth Buffer
		glLoadIdentity()														' Reset The Modelview Matrix
		gluLookAt( 75, 75, 75, 0, 0, 0, 0, 1, 0 )								' (3) Eye Postion (3) Center Point (3) Y-Axis Up Vector
		glRotatef(yrot,0.0,1.0,0.0)											' Rotate On The Y-Axis By yrot
		pModel.draw()															' Draw The Model
		yrot:+0.5															' Increase yrot By 0.5
		DrawMenu()
	End Method
	
	' Draw menu
	Method DrawMenu()
		glDisable(GL_TEXTURE_2D)	
		glDisable(GL_DEPTH_TEST)
		glColor3f(1.0,1.0,1.0)
		GLDrawText("F1 : Hide/Show menu",10,ScreenHeight-16-8)
		If ShowMenu Then
			GLDrawText("Brett Porter & NeHe's Model Rendering Tutorial (lesson 31)",10,24)
		EndIf
		glEnable(GL_TEXTURE_2D	)
		glEnable(GL_DEPTH_TEST)
	End Method
End Type

' Load Bitmaps And Convert To Textures
Function LoadGLTexture(filename:String)
	Local TextureImage:TPixmap
	TextureImage:TPixmap=LoadPixmap(filename)							' Loads The Bitmap Specified By filename
	Local texture:Int=0												' Texture ID

	' Load The Bitmap, Check For Errors, If Bitmap's Not Found Quit
	If TextureImage <> Null											' If Texture Image Exists
		glGenTextures(1, Varptr texture)								' Create The Texture
		' Typical Texture Generation Using Data From The Bitmap
		glBindTexture(GL_TEXTURE_2D, texture)
		glTexImage2D(GL_TEXTURE_2D, 0, 3, TextureImage.width, TextureImage.height, 0, GL_RGB, GL_UNSIGNED_BYTE, TextureImage.pixels)
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR)
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR)
	EndIf
	Return texture													' Return The Status
End Function
	
