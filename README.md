# Xojo Configuration Manager

A framework for managing local configuration in Xojo applications using YAML format.

## Overview

This framework provides a clean, object-oriented approach to managing application configuration in Xojo. The configuration is stored in YAML format using the Einhugur YAML plugin and is saved in the user's preferences folder.

## Features

- YAML-based configuration storage
- Automatic loading/saving of configuration
- Type-safe property access
- Error handling and validation
- Support for various data types:
  - Basic types (String, Integer, Boolean)
  - DateTime (ISO8601/RFC3339 format)
  - String arrays
  - Dictionaries (string:string maps)
  - Custom object types

## Requirements

- Xojo IDE
- [Einhugur YAML Plugin](https://www.einhugur.com/Html/YAMLPlugin/PluginMain.html)

## Installation

1. Add the ConfigManager class to your Xojo project
2. Add the ConfigManagerExtensions module to your project (optional, for extended functionality)
3. Make sure you have the Einhugur YAML Plugin installed

## Usage

### Basic Setup

In your App class:

```xojo
// In the App class
Public var Config As ConfigManager

Sub Open()
  // Initialize configuration manager
  Config = New ConfigManager("myapp.yaml")
  
  // Now you can access configuration properties
  If Config.DarkModeEnabled Then
    ApplyDarkMode()
  End If
End Sub

Sub Close()
  // Save window state to config
  Config.WindowWidth = MainWindow.Width
  Config.WindowHeight = MainWindow.Height
  
  // Config will be automatically saved in the destructor
  // But you can also save explicitly if needed
  Config.SaveConfig()
End Sub
```

### Working with Basic Properties

```xojo
// Read properties
var appName As String = App.Config.AppName
var isDarkMode As Boolean = App.Config.DarkModeEnabled

// Write properties
App.Config.AppName = "My Awesome App"
App.Config.DarkModeEnabled = True
```

### Working with Extended Types

```xojo
// Get the root node
var rootNode As EinhugurYAML.YAMLNode = App.Config.mYAMLDocument.RootNode

// Working with dates
var lastRunDate As New DateTime
lastRunDate.SQLDateTime = DateTime.Now.SQLDateTime
App.Config.SaveDateTime(rootNode, "LastRunDate", lastRunDate)

// Working with arrays
var recentFiles() As String = ["file1.txt", "file2.txt", "file3.txt"]
App.Config.SaveStringArray(rootNode, "RecentFiles", recentFiles)

// Working with dictionaries
var prefs As New Dictionary
prefs.Value("FontName") = "Arial"
prefs.Value("FontSize") = "12"
App.Config.SaveDictionary(rootNode, "Preferences", prefs)

// Save all changes
App.Config.SaveConfig()
```

### Working with Custom Types

See the CustomTypes.xojo_code example for how to extend the framework to handle custom object types.

## Structure

- **ConfigManager.xojo_code**: The main configuration manager class
- **ConfigManagerExtensions.xojo_code**: Extension methods for additional data types
- **CustomTypes.xojo_code**: Example showing how to handle custom object types
- **UsageExample.xojo_code**: Example showing various usage patterns

## Best Practices

- Initialize the ConfigManager early in your application lifecycle (App.Open)
- Define custom properties for your application's specific configuration needs
- Use appropriate data types for your properties
- Consider encrypting sensitive data (e.g., passwords) before storing
- For nested configuration, use the YAML mapping capabilities

## Notes on Formatting

This framework respects the locale where thousand separator is '.' and decimal separator is ','.

## License

This code is provided as open source. Feel free to use and modify it for your needs.
