#tag Class
Protected Class App
Inherits DesktopApplication
	#tag Event
		Sub Closing()
		  // Save current window position and size to config
		  If MainWindow <> Nil Then
		    Config.WindowPositionX = MainWindow.Left
		    Config.WindowPositionY = MainWindow.Top
		    Config.WindowWidth = MainWindow.Width
		    Config.WindowHeight = MainWindow.Height
		  End If
		  
		  // Example of updating a nested configuration property
		  If Config.CustomSettings = Nil Then
		    Config.CustomSettings = New Dictionary
		  End If
		  Config.CustomSettings.Value("LastExitTime") = DateTime.Now.SQLDateTime
		  
		  // Config.SaveConfig() will be called automatically in the Config destructor
		  // But you can call it explicitly here if you want to ensure it's saved
		  Config.SaveConfig()
		End Sub
	#tag EndEvent

	#tag Event
		Sub Opening()
		  // Initialize the configuration manager
		  Config = New AppConfig
		  
		  // Now you can access configuration properties
		  // All public properties are automatically loaded from the YAML file
		  
		  // Example: Set window properties based on saved config
		  If MainWindow <> Nil Then
		    MainWindow.Left = Config.WindowPositionX
		    MainWindow.Top = Config.WindowPositionY
		    MainWindow.Width = Config.WindowWidth
		    MainWindow.Height = Config.WindowHeight
		    MainWindow.Title = Config.AppName + " " + Config.AppVersion
		    
		    // Apply dark mode if enabled
		    If Config.DarkModeEnabled Then
		      ApplyDarkMode()
		    End If
		    
		    // Apply font settings
		    ApplyFontSettings()
		  End If
		  
		  // Log application start
		  If Config.LogLevel >= 1 Then
		    System.DebugLog(Config.AppName + " " + Config.AppVersion + " started")
		  End If
		  
		  // Display user name if available
		  If Config.UserName <> "" Then
		    System.DebugLog("Welcome back, " + Config.UserName + "!")
		  End If
		  
		  // Remember to handle the first run case
		  var isFirstRun As Boolean = (Config.LastRunDate.Year < 2000)
		  If isFirstRun Then
		    // Show welcome/setup dialog
		    ShowWelcomeDialog()
		  End If
		  
		  // Update the last run date
		  Config.LastRunDate = DateTime.Now
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h0
		Sub ApplyDarkMode()
		  // Implementation would depend on how your app handles theming
		  // This is just a placeholder
		  #If TargetMacOS Then
		    If MacOSLib.Available Then
		      // Use MacOSLib to set dark appearance
		      // MacOSLib.NSApplication.sharedApplication.appearance = MacOSLib.NSAppearance.appearanceNamed(MacOSLib.NSAppearance.NSAppearanceNameDarkAqua)
		    End If
		  #ElseIf TargetWindows Then
		    // Windows-specific dark mode implementation
		  #EndIf
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ApplyFontSettings()
		  // Apply font settings to various UI elements
		  
		  If Config.FontName <> "" And MainWindow <> Nil Then
		    // Set application-wide font
		    var fontHeight As Integer = Config.FontSize
		    
		    // Apply to controls recursively
		    ApplyFontToControl(MainWindow, Config.FontName, fontHeight)
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ApplyFontToControl()
		  // Set font for this control
		  control.FontName = fontName
		  control.FontSize = fontSize
		  
		  // Process child controls if any
		  For i As Integer = 0 To control.ControlCount - 1
		    var childControl As Control = control.Control(i)
		    If childControl IsA RectControl Then
		      ApplyFontToControl(RectControl(childControl), fontName, fontSize)
		    End If
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ShowWelcomeDialog()
		  // This is just a stub implementation
		  // In a real app, you would show a welcome window
		  
		  System.DebugLog("Welcome to " + Config.AppName + "!")
		  System.DebugLog("This appears to be your first time running the application.")
		  
		  // You could show setup options for initial preferences
		  Config.UserName = "New User"
		  Config.PreferredLanguage = System.Language
		  
		  // And save the initial configuration
		  Config.MarkAsModified()
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub UpdateUserPreference(name As String, value As Variant)
		  Select Case name
		  Case "UserName"
		    Config.UserName = value.StringValue
		    
		  Case "DarkMode"
		    Config.DarkModeEnabled = value.BooleanValue
		    ApplyDarkMode()
		    
		  Case "FontSize"
		    Config.FontSize = value.DoubleValue
		    ApplyFontSettings()
		    
		  Case "FontName"
		    Config.FontName = value.StringValue
		    ApplyFontSettings()
		    
		  Case "Language"
		    Config.PreferredLanguage = value.StringValue
		    // Would trigger language reload in a real app
		    
		  End Select
		  
		  // Mark as modified so it gets saved
		  Config.MarkAsModified()
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h0
		Config As AppConfig
	#tag EndProperty


	#tag Constant, Name = kEditClear, Type = String, Dynamic = False, Default = \"&Delete", Scope = Public
		#Tag Instance, Platform = Windows, Language = Default, Definition  = \"&Delete"
		#Tag Instance, Platform = Linux, Language = Default, Definition  = \"&Delete"
	#tag EndConstant

	#tag Constant, Name = kFileQuit, Type = String, Dynamic = False, Default = \"&Quit", Scope = Public
		#Tag Instance, Platform = Windows, Language = Default, Definition  = \"E&xit"
	#tag EndConstant

	#tag Constant, Name = kFileQuitShortcut, Type = String, Dynamic = False, Default = \"", Scope = Public
		#Tag Instance, Platform = Mac OS, Language = Default, Definition  = \"Cmd+Q"
		#Tag Instance, Platform = Linux, Language = Default, Definition  = \"Ctrl+Q"
	#tag EndConstant


	#tag ViewBehavior
		#tag ViewProperty
			Name="Name"
			Visible=false
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=false
			Group="ID"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=false
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=false
			Group="Position"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=false
			Group="Position"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="AllowAutoQuit"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="AllowHiDPI"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="BugVersion"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Copyright"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Description"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="LastWindowIndex"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="MajorVersion"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="MinorVersion"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="NonReleaseVersion"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="RegionCode"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="StageCode"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Version"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="string"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="_CurrentEventTime"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Config"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
