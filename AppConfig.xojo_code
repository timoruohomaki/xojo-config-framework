#tag Class
Protected Class AppConfig
Inherits ConfigManager
	#tag Method, Flags = &h0
		Sub AddRecentFile(filePath as String)
		  // Check if it's already in the list
		  var index As Integer = RecentFiles.IndexOf(filePath)
		  
		  // If it exists, remove it first (so it will be added at the top)
		  If index >= 0 Then
		    RecentFiles.Remove(index)
		  End If
		  
		  // Add at the beginning
		  RecentFiles.AddAt(0, filePath)
		  
		  // Limit the list size to 10 items
		  While RecentFiles.Count > 10
		    RecentFiles.RemoveAt(RecentFiles.LastIndex)
		  Wend
		  
		  // Mark as modified
		  MarkAsModified()
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ClearRecentFiles()
		  RecentFiles.ResizeTo(-1) // Clear the array
		  MarkAsModified()
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor()
		  // Initialize with default filename
		  Super.Constructor("myapp.config")
		  
		  // Initialize collections if they're nil after loading
		  If CustomSettings = Nil Then
		    CustomSettings = New Dictionary
		  End If
		  If RecentFiles = Nil Then
		    RecentFiles = New String()
		  End If
		  
		  // Initialize private data
		  mCachedData = New Dictionary
		  
		  // Set last run date to now
		  LastRunDate = DateTime.Now
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h0
		AppName As String = "MyApp"
	#tag EndProperty

	#tag Property, Flags = &h0
		AppVersion As String = "1.0.0"
	#tag EndProperty

	#tag Property, Flags = &h0
		CustomSettings As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h0
		DarkModeEnabled As Boolean = False
	#tag EndProperty

	#tag Property, Flags = &h0
		FontName As String
	#tag EndProperty

	#tag Property, Flags = &h0
		FontSize As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		LastRunDate As DateTime
	#tag EndProperty

	#tag Property, Flags = &h0
		LogLevel As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		MarkAsModified As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mCachedData As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mTempValue As String
	#tag EndProperty

	#tag Property, Flags = &h0
		PreferredLanguage As String
	#tag EndProperty

	#tag Property, Flags = &h0
		RecentFiles() As String
	#tag EndProperty

	#tag Property, Flags = &h0
		UserName As String
	#tag EndProperty

	#tag Property, Flags = &h0
		WindowHeight As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		WindowPositionX As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		WindowPositionY As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		WindowWidth As Integer
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
