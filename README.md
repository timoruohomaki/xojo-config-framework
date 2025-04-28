# Xojo Configuration Manager

A modern, flexible, and automated framework for managing local configuration in Xojo applications using YAML format.

## Overview

This framework provides a clean, object-oriented approach to managing application configuration in Xojo. The configuration is stored in YAML format using the Einhugur YAML plugin and is saved in the user's preferences folder.

The key feature of this framework is its use of introspection to automatically handle property serialization based on visibility - all public properties are automatically saved in the configuration file, while private properties (starting with "m") are ignored.

## Features

- **Automatic property handling** - All public properties are automatically serialized
- **YAML-based configuration** - Human-readable configuration format
- **Automatic loading/saving** - Configuration is loaded on instantiation and saved in the destructor
- **Type-safe property access** - Support for various data types including strings, numbers, booleans, dates, and collections
- **Error handling and validation** - Robust error recovery
- **Locale support** - Works with locale settings where thousand separator is "." and decimal separator is ","
- **Advanced features** - Support for sections, encryption, and more

## Requirements

- Xojo IDE
- [Einhugur YAML Plugin](https://www.einhugur.com/Html/YAMLPlugin/PluginMain.html)

## Installation

1. Add the ConfigManager.xojo_code class to your Xojo project
2. Add any additional extensions you need (AdvancedConfigManager, EncryptedConfigManager)
3. Make sure you have the Einhugur YAML Plugin installed

## Basic Usage

### 1. Create a configuration class

```xojo
Class AppConfig Inherits ConfigManager
  // All public properties will automatically be saved to the config file
  Public var AppName As String = "My Application"
  Public var AppVersion As String = "1.0.0"
  Public var WindowWidth As Integer = 800
  Public var WindowHeight As Integer = 600
  Public var DarkModeEnabled As Boolean = False
  
  // Private properties will NOT be saved to the config file
  Private var mTempValue As String = "" // Not saved
  
  // Constructor
  Sub Constructor()
    // Initialize with default filename
    Super.Constructor("myapp_config.yaml")
  End Sub
End Class
```

### 2. Integrate with your App class

```xojo
// In the App class
Public var Config As AppConfig

Sub Open()
  // Initialize configuration manager
  Config = New AppConfig
  
  // Now you can access configuration properties
  Window1.Title = Config.AppName + " " + Config.AppVersion
  Window1.Width = Config.WindowWidth
  Window1.Height = Config.WindowHeight
  
  If Config.DarkModeEnabled Then
    ApplyDarkMode()
  End If
End Sub

Sub Close()
  // Save window state to config
  Config.WindowWidth = Window1.Width
  Config.WindowHeight = Window1.Height
  
  // Config will be automatically saved in the destructor
  // But you can also save explicitly if needed
  Config.SaveConfig()
End Sub
```

### 3. Working with configuration properties

All public properties are automatically saved to and loaded from the YAML file. No additional code is needed to handle property serialization.

```xojo
// Reading properties
var appName As String = App.Config.AppName
var isDarkMode As Boolean = App.Config.DarkModeEnabled

// Writing properties
App.Config.AppName = "My Awesome App"
App.Config.DarkModeEnabled = True

// Explicitly save (optional - will happen automatically in destructor)
App.Config.SaveConfig()
```

## Advanced Features

### Sections (AdvancedConfigManager)

For more complex applications, you can use the AdvancedConfigManager which provides support for sections:

```xojo
var config As New MyAdvancedConfig

// Access section values
var dbSection As AdvancedConfigManager.ConfigSection = config.GetSection("Database")
var host As String = dbSection.GetString("Host")
var port As Integer = dbSection.GetInteger("Port")

// Access nested sections
var uiSection As AdvancedConfigManager.ConfigSection = config.GetSection("UI")
var colorsSection As AdvancedConfigManager.ConfigSection = uiSection.GetSection("Colors")
var backgroundColor As String = colorsSection.GetString("Background")
```

### Encryption (EncryptedConfigManager)

For sensitive data, you can use the EncryptedConfigManager which automatically encrypts properties that contain words like "Password", "ApiKey", etc.:

```xojo
var config As New SecureConfig("myapp.yaml", "encryption-key")

// Properties will be automatically encrypted/decrypted
config.ApiKey = "secret-api-key"
config.UserPassword = "secure-password"

// Add additional properties to encrypt
config.AddEncryptedProperty("Credentials")
```

## Supported Data Types

- String
- Integer
- Double (with proper locale handling for decimal separator)
- Boolean
- DateTime (stored in ISO8601/RFC3339 format)
- String Arrays
- Dictionaries (string:string maps)

## Locale Support

This framework supports locales where:
- Thousand separator is "."
- Decimal separator is ","

## Best Practices

1. **Default Values**: Always provide reasonable default values for your properties
2. **Property Naming**: Use public for properties that should be saved, private (with "m" prefix) for internal properties
3. **Save On Change**: For properties that change often, call `MarkAsModified()` to ensure saving
4. **Error Handling**: Check logs for any serialization errors
5. **Encryption**: Use EncryptedConfigManager for sensitive data

## Extended Example

Here's a more complete example showing various supported data types:

```xojo
Class CompleteConfig Inherits ConfigManager
  // Basic settings
  Public var AppName As String = "Complete App"
  Public var AppVersion As String = "1.0.0"
  
  // Numbers with locale support
  Public var TaxRate As Double = 19,5 // Using , as decimal separator
  Public var Quantity As Integer = 42
  
  // Boolean flags
  Public var DarkModeEnabled As Boolean = False
  Public var NotificationsEnabled As Boolean = True
  
  // Date/time values
  Public var LastRunDate As DateTime = New DateTime
  
  // Collections
  Public var RecentFiles() As String
  Public var CustomSettings As Dictionary
  
  Sub Constructor()
    Super.Constructor("complete_config.yaml")
    
    // Initialize collections
    If CustomSettings = Nil Then
      CustomSettings = New Dictionary
    End If
  End Sub
End Class
```

## License

This code is provided as open source. Feel free to use and modify it for your needs.
