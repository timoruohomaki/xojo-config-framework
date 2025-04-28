#tag Class
Protected Class ConfigManager
	#tag Method, Flags = &h0
		Sub Constructor(configFileName as String)
		  // Allow custom filename if provided
		  
		  If configFileName <> "" Then
		    mConfigFileName = configFileName
		  End If
		  
		  // Set up the full path to the config file
		  
		  Try
		    var prefsFolder As FolderItem = SpecialFolder.Preferences
		    If prefsFolder <> Nil And prefsFolder.Exists Then
		      mConfigFilePath = prefsFolder.Child(mConfigFileName).NativePath
		    Else
		      Raise New IOException("Preferences folder not available")
		    End If
		  Catch e As IOException
		    System.DebugLog("ConfigManager: Error accessing preferences folder: " + e.Message)
		    Return
		  End Try
		  
		  // Load the configuration
		  LoadConfig()
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Destructor()
		  If mConfigModified Then
		    SaveConfig()
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub LoadConfig()
		  Try
		    
		    var configFile As New FolderItem(mConfigFilePath, FolderItem.PathModes.Native)
		    
		    // Check if the config file exists
		    If configFile.Exists Then
		      // Read the YAML file
		      var fileStream As BinaryStream = BinaryStream.Open(configFile, BinaryStream.AccessModes.Read)
		      If fileStream = Nil Then
		        Raise New IOException("Failed to open config file for reading")
		      End If
		      
		      var yamlData As String = fileStream.Read(fileStream.Length)
		      fileStream.Close()
		      
		      // Parse the YAML content
		      mYAMLDocument = New EinhugurYAML.Document
		      mYAMLDocument.Parse(yamlData)
		      
		      // Load values into properties
		      LoadPropertiesFromYAML()
		    Else
		      // Config file doesn't exist, create a new one with default values
		      mYAMLDocument = New EinhugurYAML.YAMLDocument
		      SetDefaultValues()
		      SaveConfig()
		    End If
		    
		  Catch e As RuntimeException
		    System.DebugLog("ConfigManager: Error loading configuration: " + e.Message)
		    
		    // Create a new document with default values
		    mYAMLDocument = New EinhugurYAML.YAMLDocument
		    SetDefaultValues()
		    SaveConfig()
		  End Try
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub LoadPropertiesFromYAML()
		  If mYAMLDocument = Nil Then Return
		  
		  // Root node
		  var rootNode As EinhugurYAML.YAMLNode = mYAMLDocument.RootNode
		  If rootNode = Nil Then Return
		  
		  // Read properties with type safety
		  AppName = GetStringValue(rootNode, "AppName", "MyApplication")
		  AppVersion = GetStringValue(rootNode, "AppVersion", "1.0.0")
		  // UserName = GetStringValue(rootNode, "UserName", "")
		  // LastOpenedFile = GetStringValue(rootNode, "LastOpenedFile", "")
		  // WindowPositionX = GetIntegerValue(rootNode, "WindowPositionX", 100)
		  // WindowPositionY = GetIntegerValue(rootNode, "WindowPositionY", 100)
		  // WindowWidth = GetIntegerValue(rootNode, "WindowWidth", 800)
		  // WindowHeight = GetIntegerValue(rootNode, "WindowHeight", 600)
		  // DarkModeEnabled = GetBooleanValue(rootNode, "DarkModeEnabled", False)
		  // LogLevel = GetIntegerValue(rootNode, "LogLevel", 1)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub SaveConfig()
		  Try
		    // Update YAML document with current property values
		    SavePropertiesToYAML()
		    
		    // Export YAML to string
		    var yamlData As String = mYAMLDocument.YAML
		    
		    // Save to file
		    var configFile As New FolderItem(mConfigFilePath, FolderItem.PathModes.Native)
		    var fileStream As BinaryStream = BinaryStream.Create(configFile, BinaryStream.AccessModes.Write)
		    If fileStream = Nil Then
		      Raise New IOException("Failed to open config file for writing")
		    End If
		    
		    fileStream.Write(yamlData)
		    fileStream.Close()
		    
		    // Reset modified flag
		    mConfigModified = False
		    
		  Catch e As RuntimeException
		    System.DebugLog("ConfigManager: Error saving configuration: " + e.Message)
		  End Try
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub SetDefaultValues()
		  AppName = "MyApplication"
		  AppVersion = "1.0.0"
		  // UserName = ""
		  // LastOpenedFile = ""
		  // WindowPositionX = 100
		  // WindowPositionY = 100
		  // WindowWidth = 800
		  // WindowHeight = 600
		  // DarkModeEnabled = False
		  // LogLevel = 1 // Default to info level
		  
		  // Mark as modified to ensure initial save
		  mConfigModified = True
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h0
		AppName As String
	#tag EndProperty

	#tag Property, Flags = &h0
		AppVersion As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mConfigFileName As String = "myapp.config"
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mConfigFilePath As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mConfigModified As Boolean = False
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mYAMLDocument As EinhugurYAML.Document
	#tag EndProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="mConfigFileName"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
