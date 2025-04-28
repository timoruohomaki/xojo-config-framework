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


	#tag Method, Flags = &h21
		Private Sub ApplyCustomDarkTheme()
		  // Apply custom styling for controls that don't automatically
		  // respond to system dark mode changes
		  
		  // Example: Apply to main window if it exists
		  If MainWindow <> Nil Then
		    // Custom styling for specific controls if needed
		    For i As Integer = 0 To MainWindow.ControlCount - 1
		      var control As Control = MainWindow.Control(i)
		      
		      // Add custom control-specific styling here
		      // For example, third-party controls or controls with custom drawing
		      If control IsA MyCustomControl Then
		        // Apply custom dark mode styling
		      End If
		    Next
		  End If
		  
		  // Apply to any other windows that are open
		  For i As Integer = 0 To WindowCount - 1
		    var win As Window = Window(i)
		    If win <> Nil And win <> MainWindow Then
		      // Apply custom styling as needed
		    End If
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ApplyDarkMode()
		  // Set the application-wide dark mode setting
		  #If DebugBuild Then
		    System.DebugLog("Applying dark mode")
		  #EndIf
		  
		  #If TargetMacOS Or TargetWindows Then
		    // Use Xojo's built-in dark mode support
		    App.DarkModeEnabled = True
		    
		    // Update the system colors based on the new dark mode setting
		    // This will affect default control colors automatically
		    App.UpdateSystemColors
		    
		    // For custom controls that don't automatically respond to system colors,
		    // we can manually update them
		    ApplyCustomDarkTheme()
		  #ElseIf TargetLinux Then
		    // Linux implementation - may require more custom work
		    App.DarkModeEnabled = True
		    App.UpdateSystemColors
		    ApplyCustomDarkTheme()
		    System.DebugLog("Dark mode applied for Linux - custom theming may be required")
		  #EndIf
		  
		  // Store the setting in config
		  Config.DarkModeEnabled = True
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ApplyDarkThemeToControls(control as Control)
		  // Apply dark theme colors based on control type
		  If control IsA DesktopTextField Then
		    DesktopTextField(control).BackgroundColor = &c333333
		    DesktopTextField(control).TextColor = &cEEEEEE
		  ElseIf control IsA DesktopTextArea Then
		    DesktopTextArea(control).BackgroundColor = &c333333
		    DesktopTextArea(control).TextColor = &cEEEEEE
		  ElseIf control IsA DesktopButton Then
		    DesktopButton(control).BackgroundColor = &c444444
		  ElseIf control IsA DesktopListBox Then
		    DesktopListBox(control).BackgroundColor = &c333333
		    DesktopListBox(control).TextColor = &cEEEEEE
		  End If
		  
		  // Check if the control is a container and process its children
		  If control IsA DesktopContainer Then
		    var container As DesktopContainer = DesktopContainer(control)
		    For i As Integer = 0 To container.ControlCount - 1
		      ApplyDarkThemeToControls(container.Control(i))
		    Next
		  ElseIf control IsA DesktopWindow Then
		    var window As DesktopWindow = DesktopWindow(control)
		    For i As Integer = 0 To window.ControlCount - 1
		      ApplyDarkThemeToControls(window.Control(i))
		    Next
		  End If
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
