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
		Private Function FormatDateTimeISO8601(dt as DateTime) As String
		  // Format: YYYY-MM-DDThh:mm:ss.sssZ
		  var formattedDate As String = dt.SQLDateTime.Replace(" ", "T")
		  
		  // Add milliseconds
		  var milliseconds As String = Format(dt.Nanosecond / 1000000, "000")
		  formattedDate = formattedDate + "." + milliseconds
		  
		  // Add timezone designator
		  formattedDate = formattedDate + "Z"
		  
		  Return formattedDate
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function GetBooleanValue(parentNode As EinhugurYAML.YAMLNode, key As String, defaultValue As Boolean) As Boolean
		  Try
		    // Find mapping key in the parent mapping node
		    For i As Integer = 0 To parentNode.MappingNodeCount - 1
		      var kvPair As EinhugurYAML.KeyValuePair = parentNode.MappingNode(i)
		      If kvPair.Key = key Then
		        If kvPair.Value.NodeType = EinhugurYAML.NodeTypes.SCALAR Then
		          Return kvPair.Value.ScalarValue.Lowercase = "true"
		        End If
		      End If
		    Next
		  Catch e As RuntimeException
		    // Ignore and return default
		  End Try
		  
		  Return defaultValue
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function GetDateTimeValue(parentNode As EinhugurYAML.YAMLNode, key As String, defaultValue As DateTime) As DateTime
		  Try
		    // Find mapping key in the parent mapping node
		    For i As Integer = 0 To parentNode.MappingNodeCount - 1
		      var kvPair As EinhugurYAML.KeyValuePair = parentNode.MappingNode(i)
		      If kvPair.Key = key Then
		        If kvPair.Value.NodeType = EinhugurYAML.NodeTypes.SCALAR Then
		          Return ParseDateTimeISO8601(kvPair.Value.ScalarValue)
		        End If
		      End If
		    Next
		  Catch e As RuntimeException
		    // Ignore and return default
		  End Try
		  
		  Return defaultValue
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function GetDictionaryValue(parentNode As EinhugurYAML.Node, key As String) As Dictionary
		  var result As New Dictionary
		  
		  Try
		    // Find mapping key in the parent mapping node
		    For i As Integer = 0 To parentNode.MappingNodeCount - 1
		      var kvPair As EinhugurYAML.KeyValuePair = parentNode.MappingNode(i)
		      If kvPair.Key = key Then
		        If kvPair.Value.NodeType = EinhugurYAML.NodeTypes.MAPPING Then
		          // Found a mapping node, extract all key-value pairs
		          var dictNode As EinhugurYAML.Node = kvPair.Value
		          
		          For j As Integer = 0 To dictNode.MappingNodeCount - 1
		            var dictKvPair As EinhugurYAML.KeyValuePair = dictNode.MappingNode(j)
		            If dictKvPair.Value.NodeType = EinhugurYAML.NodeTypes.SCALAR Then
		              result.Value(dictKvPair.Key) = dictKvPair.Value.ScalarValue
		            End If
		          Next
		        End If
		        
		        Return result
		      End If
		    Next
		  Catch e As RuntimeException
		    System.DebugLog("ConfigManager: Error loading dictionary: " + e.Message)
		  End Try
		  
		  Return result
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function GetDoubleValue(parentNode As EinhugurYAML.YAMLNode, key As String, defaultValue As Double) As Double
		  Try
		    // Find mapping key in the parent mapping node
		    For i As Integer = 0 To parentNode.MappingNodeCount - 1
		      var kvPair As EinhugurYAML.KeyValuePair = parentNode.MappingNode(i)
		      If kvPair.Key = key Then
		        If kvPair.Value.NodeType = EinhugurYAML.NodeTypes.SCALAR Then
		          // Handle localized decimal separator (comma instead of period)
		          var valueStr As String = kvPair.Value.ScalarValue.ReplaceAll(",", ".")
		          Return Double.FromString(valueStr)
		        End If
		      End If
		    Next
		  Catch e As RuntimeException
		    // Ignore and return default
		  End Try
		  
		  Return defaultValue
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function GetIntegerValue(parentNode As EinhugurYAML.Node, key As String, defaultValue As Integer) As Integer
		  Try
		    // Find mapping key in the parent mapping node
		    For i As Integer = 0 To parentNode.MappingNodeCount - 1
		      var kvPair As EinhugurYAML.KeyValuePair = parentNode.MappingNode(i)
		      If kvPair.Key = key Then
		        If kvPair.Value.NodeType = EinhugurYAML.NodeTypes.SCALAR Then
		          Return Integer.FromString(kvPair.Value.ScalarValue)
		        End If
		      End If
		    Next
		  Catch e As RuntimeException
		    // Ignore and return default
		  End Try
		  
		  Return defaultValue
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function GetStringArrayValue(parentNode As EinhugurYAML.Node, key As String) As String()
		  var result() As String
		  
		  Try
		    // Find mapping key in the parent mapping node
		    For i As Integer = 0 To parentNode.MappingNodeCount - 1
		      var kvPair As EinhugurYAML.KeyValuePair = parentNode.MappingNode(i)
		      If kvPair.Key = key Then
		        If kvPair.Value.NodeType = EinhugurYAML.NodeTypes.SEQUENCE Then
		          // Found a sequence node, extract all items
		          var seqNode As EinhugurYAML.Node = kvPair.Value
		          
		          For j As Integer = 0 To seqNode.SequenceNodeCount - 1
		            var itemNode As EinhugurYAML.Node = seqNode.SequenceNode(j)
		            If itemNode.NodeType = EinhugurYAML.NodeTypes.SCALAR Then
		              result.Add(itemNode.ScalarValue)
		            End If
		          Next
		        End If
		        
		        Return result
		      End If
		    Next
		  Catch e As RuntimeException
		    System.DebugLog("ConfigManager: Error loading string array: " + e.Message)
		  End Try
		  
		  Return result
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function GetStringValue(parentNode As EinhugurYAML.YAMLNode, key As String, defaultValue As String) As string
		  Try
		    // Find mapping key in the parent mapping node
		    For i As Integer = 0 To parentNode.MappingNodeCount - 1
		      var kvPair As EinhugurYAML.KeyValuePair = parentNode.MappingNode(i)
		      If kvPair.Key = key Then
		        If kvPair.Value.NodeType = EinhugurYAML.NodeTypes.SCALAR Then
		          Return kvPair.Value.ScalarValue
		        End If
		      End If
		    Next
		  Catch e As RuntimeException
		    // Ignore and return default
		  End Try
		  
		  Return defaultValue
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function IsPublicProperty(prop As Introspection.PropertyInfo) As Boolean
		  // Get the actual scope of the property
		  var scope As Introspection.PropertyInfo.Scopes = prop.Scope
		  
		  // Check if the scope is public
		  Return scope = Introspection.PropertyInfo.Scopes.Public
		End Function
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
		      
		      // Parse the YAML content - using shared Parse method
		      mYAMLDocument = EinhugurYAML.Document.Parse(yamlData)
		      
		      // Load values into properties using introspection
		      LoadPropertiesFromYAML()
		    Else
		      // Config file doesn't exist, create a new one with default values
		      mYAMLDocument = New EinhugurYAML.Document
		      SaveConfig() // This will create an empty config file
		    End If
		    
		  Catch e As RuntimeException
		    System.DebugLog("ConfigManager: Error loading configuration: " + e.Message)
		    
		    // Create a new document
		    mYAMLDocument = New EinhugurYAML.Document
		    SaveConfig() // This will create an empty config file
		  End Try
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub LoadPropertiesFromYAML()
		  If mYAMLDocument = Nil Then Return
		  
		  // Root node
		  var rootNode As EinhugurYAML.Node = mYAMLDocument.RootNode
		  If rootNode = Nil Then
		    // Create root node if it doesn't exist
		    var mappingId As Integer = mYAMLDocument.AddMapping()
		    rootNode = mYAMLDocument.RootNode
		    Return
		  End If
		  
		  // Check if root node is a mapping
		  If rootNode.NodeType <> EinhugurYAML.NodeTypes.MAPPING Then
		    System.DebugLog("ConfigManager: Root node is not a mapping")
		    Return
		  End If
		  
		  // Use introspection to iterate through properties
		  var typeInfo As Introspection.TypeInfo = Introspection.GetType(Self)
		  var properties() As Introspection.PropertyInfo = typeInfo.GetProperties
		  
		  For Each prop As Introspection.PropertyInfo In properties
		    // Only process public properties - check scope
		    If prop.Scope <> Introspection.PropertyInfo.Scopes.Public Then Continue
		    
		    // Skip properties of the base ConfigManager class
		    If prop.Name = "mConfigFileName" Or prop.Name = "mConfigFilePath" Or _
		      prop.Name = "mYAMLDocument" Or prop.Name = "mConfigModified" Then
		      Continue
		    End If
		    
		    // Get property's type
		    var propType As Introspection.TypeInfo = prop.PropertyType
		    
		    // Load property based on its type
		    If propType = GetTypeInfo(String) Then
		      // String property
		      var value As String = GetStringValue(rootNode, prop.Name, "")
		      prop.Value(Self) = value
		      
		    ElseIf propType = GetTypeInfo(Integer) Then
		      // Integer property
		      var value As Integer = GetIntegerValue(rootNode, prop.Name, 0)
		      prop.Value(Self) = value
		      
		    ElseIf propType = GetTypeInfo(Double) Then
		      // Double property
		      var value As Double = GetDoubleValue(rootNode, prop.Name, 0.0)
		      prop.Value(Self) = value
		      
		    ElseIf propType = GetTypeInfo(Boolean) Then
		      // Boolean property
		      var value As Boolean = GetBooleanValue(rootNode, prop.Name, False)
		      prop.Value(Self) = value
		      
		    ElseIf propType = GetTypeInfo(DateTime) Then
		      // DateTime property
		      var value As DateTime = GetDateTimeValue(rootNode, prop.Name, New DateTime)
		      prop.Value(Self) = value
		      
		    ElseIf propType = GetTypeInfo(Dictionary) Then
		      // Dictionary property
		      var value As Dictionary = GetDictionaryValue(rootNode, prop.Name)
		      prop.Value(Self) = value
		      
		    ElseIf propType.IsArray Then
		      // Array property - only handle string arrays for now
		      If propType.Name = "String()" Then
		        var value() As String = GetStringArrayValue(rootNode, prop.Name)
		        prop.Value(Self) = value
		      End If
		    End If
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function MyTypeInfo(dataType As Object) As Introspection.TypeInfo
		  Return Introspection.GetType(dataType)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ParseDateTimeISO8601(isoDateString As String) As DateTime
		  Try
		    var dt As New DateTime
		    
		    // Handle basic format: YYYY-MM-DDThh:mm:ss.sssZ
		    // Remove timezone indicator for now
		    var dateStr As String = isoDateString.Replace("Z", "")
		    
		    // Split into date and time parts
		    var parts() As String = dateStr.Split("T")
		    If parts.Count < 2 Then
		      Return dt // Return empty DateTime if format is incorrect
		    End If
		    
		    var datePart As String = parts(0)
		    var timePart As String = parts(1)
		    
		    // Parse date components
		    var dateComponents() As String = datePart.Split("-")
		    If dateComponents.Count >= 3 Then
		      dt.Year = Integer.FromString(dateComponents(0))
		      dt.Month = Integer.FromString(dateComponents(1))
		      dt.Day = Integer.FromString(dateComponents(2))
		    End If
		    
		    // Parse time components
		    var timeAndMillis() As String = timePart.Split(".")
		    var timeComponents() As String = timeAndMillis(0).Split(":")
		    
		    If timeComponents.Count >= 3 Then
		      dt.Hour = Integer.FromString(timeComponents(0))
		      dt.Minute = Integer.FromString(timeComponents(1))
		      dt.Second = Integer.FromString(timeComponents(2))
		    End If
		    
		    // Handle milliseconds if present
		    If timeAndMillis.Count > 1 Then
		      dt.Nanosecond = Integer.FromString(timeAndMillis(1)) * 1000000
		    End If
		    
		    Return dt
		  Catch e As RuntimeException
		    System.DebugLog("ConfigManager: Error parsing ISO8601 date: " + e.Message)
		    Return New DateTime // Return empty DateTime on error
		  End Try
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub SaveConfig()
		  Try
		    // Update YAML document with current property values
		    SavePropertiesToYAML()
		    
		    // Export YAML to string using ToString method
		    var yamlData As String = mYAMLDocument.ToString()
		    
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
		Private Sub SavePropertiesToYAML()
		  If mYAMLDocument = Nil Then
		    mYAMLDocument = New EinhugurYAML.Document
		  End If
		  
		  // Create or get root node
		  var rootNode As EinhugurYAML.Node
		  If mYAMLDocument.RootNode = Nil Then
		    var mappingId As Integer = mYAMLDocument.AddMapping()
		    rootNode = mYAMLDocument.RootNode
		  Else
		    rootNode = mYAMLDocument.RootNode
		  End If
		  
		  // Check if root node is a mapping
		  If rootNode.NodeType <> EinhugurYAML.NodeTypes.MAPPING Then
		    System.DebugLog("ConfigManager: Root node is not a mapping")
		    Return
		  End If
		  
		  // Use introspection to iterate through properties
		  var typeInfo As Introspection.TypeInfo = Introspection.GetType(Self)
		  var properties() As Introspection.PropertyInfo = typeInfo.GetProperties
		  
		  For Each prop As Introspection.PropertyInfo In properties
		    // Only process public properties - check scope
		    If prop.Scope <> Introspection.PropertyInfo.Scopes.Public Then Continue
		    
		    // Skip properties of the base ConfigManager class
		    If prop.Name = "mConfigFileName" Or prop.Name = "mConfigFilePath" Or _
		      prop.Name = "mYAMLDocument" Or prop.Name = "mConfigModified" Then
		      Continue
		    End If
		    
		    // Get property's value and type
		    var propValue As Variant = prop.Value(Self)
		    var propType As Introspection.TypeInfo = prop.PropertyType
		    
		    // Save property based on its type
		    If propType = GetTypeInfo(String) Then
		      // String property
		      SetStringValue(rootNode, prop.Name, propValue.StringValue)
		      
		    ElseIf propType = GetTypeInfo(Integer) Then
		      // Integer property
		      SetIntegerValue(rootNode, prop.Name, propValue.IntegerValue)
		      
		    ElseIf propType = GetTypeInfo(Double) Then
		      // Double property
		      SetDoubleValue(rootNode, prop.Name, propValue.DoubleValue)
		      
		    ElseIf propType = GetTypeInfo(Boolean) Then
		      // Boolean property
		      SetBooleanValue(rootNode, prop.Name, propValue.BooleanValue)
		      
		    ElseIf propType = GetTypeInfo(DateTime) Then
		      // DateTime property
		      SetDateTimeValue(rootNode, prop.Name, propValue)
		      
		    ElseIf propType = GetTypeInfo(Dictionary) Then
		      // Dictionary property
		      SetDictionaryValue(rootNode, prop.Name, propValue)
		      
		    ElseIf propType.IsArray Then
		      // Array property - only handle string arrays for now
		      If propType.Name = "String()" Then
		        var strArray() As String = propValue
		        SetStringArrayValue(rootNode, prop.Name, strArray)
		      End If
		    End If
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub SetBooleanValue(parentNode As EinhugurYAML.Node, key As String, value As Boolean)
		  Try
		    // Convert to "true" or "false" string and set as scalar
		    SetStringValue(parentNode, key, If(value, "true", "false"))
		  Catch e As RuntimeException
		    System.DebugLog("ConfigManager: Error setting boolean value: " + e.Message)
		  End Try
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub SetDateTimeValue(parentNode As EinhugurYAML.Node, key As String, value As DateTime)
		  Try
		    var formattedDate As String = FormatDateTimeISO8601(value)
		    
		    // Set as scalar
		    SetStringValue(parentNode, key, formattedDate)
		  Catch e As RuntimeException
		    System.DebugLog("ConfigManager: Error saving DateTime value: " + e.Message)
		  End Try
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub SetDictionaryValue(parentNode As EinhugurYAML.Node, key As String, dict As Dictionary)
		  Try
		    // Create mapping for this dictionary
		    var mapId As Integer = mYAMLDocument.AddMapping()
		    
		    // Add all items to the mapping
		    For Each entry As DictionaryEntry In dict
		      var dictKey As String = entry.Key.StringValue
		      var dictValue As String = entry.Value.StringValue
		      
		      // Add the key-value pair to the mapping
		      mYAMLDocument.AddMappingItem(dictKey, dictValue)
		    Next
		    
		    // Connect the mapping to the parent node with the given key
		    mYAMLDocument.AddMappingItem(key, mapId)
		    
		    mConfigModified = True
		  Catch e As RuntimeException
		    System.DebugLog("ConfigManager: Error saving dictionary: " + e.Message)
		  End Try
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub SetDoubleValue(parentNode As EinhugurYAML.Node, key As String, value As Double)
		  Try
		    // Format with comma as decimal separator
		    var valueStr As String = Format(value, "0.000000").ReplaceAll(".", ",")
		    
		    // Set as scalar
		    SetStringValue(parentNode, key, valueStr)
		  Catch e As RuntimeException
		    System.DebugLog("ConfigManager: Error setting double value: " + e.Message)
		  End Try
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub SetIntegerValue(parentNode As EinhugurYAML.Node, key As String, value As Integer)
		  Try
		    // Convert to string and set as scalar
		    SetStringValue(parentNode, key, value.ToString)
		  Catch e As RuntimeException
		    System.DebugLog("ConfigManager: Error setting integer value: " + e.Message)
		  End Try
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub SetStringArrayValue(parentNode As EinhugurYAML.Node, key As String, values() As String)
		  Try
		    // Create sequence for this array
		    var seqId As Integer = mYAMLDocument.AddSequence()
		    
		    // Add all items to the sequence
		    For Each value As String In values
		      // Add the value to the sequence
		      mYAMLDocument.AddSequenceItem(seqId, value)
		    Next
		    
		    // Connect the sequence to the parent node with the given key
		    mYAMLDocument.AddMappingItem(key, seqId)
		    
		    mConfigModified = True
		  Catch e As RuntimeException
		    System.DebugLog("ConfigManager: Error saving string array: " + e.Message)
		  End Try
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub SetStringValue(parentNode As EinhugurYAML.Node, key As String, value As String)
		  Try
		    // Check if the key already exists
		    var existingNodeIndex As Integer = -1
		    
		    For i As Integer = 0 To parentNode.MappingNodeCount - 1
		      var kvPair As EinhugurYAML.KeyValuePair = parentNode.MappingNode(i)
		      If kvPair.Key = key Then
		        existingNodeIndex = i
		        Exit
		      End If
		    Next
		    
		    If existingNodeIndex >= 0 Then
		      // Key exists, update value
		      var existingPair As EinhugurYAML.KeyValuePair = parentNode.MappingNode(existingNodeIndex)
		      var scalarNodeId As Integer = mYAMLDocument.AddScalar(value)
		      mYAMLDocument.AddMappingItem(key, scalarNodeId)
		    Else
		      // Key doesn't exist, add new mapping item
		      mYAMLDocument.AddMappingItem(key, value)
		    End If
		    
		    mConfigModified = True
		  Catch e As RuntimeException
		    System.DebugLog("ConfigManager: Error setting string value: " + e.Message)
		  End Try
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
			Name="AppName"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="AppVersion"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
