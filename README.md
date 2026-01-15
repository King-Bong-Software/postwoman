# PostWoman 💅

A native macOS REST API client built with SwiftUI and SwiftData. A lightweight Postman alternative designed specifically for macOS.

![macOS](https://img.shields.io/badge/macOS-14.0+-blue)
![Swift](https://img.shields.io/badge/Swift-5.9+-orange)
![SwiftUI](https://img.shields.io/badge/SwiftUI-5.0+-green)

## Features

### Core Functionality
- **REST API Testing** - Support for GET, POST, PUT, DELETE methods
- **Folder Organization** - Organize requests into nested collections
- **Request Editor** - Configure URL, headers, query parameters, body, and authentication
- **Response Viewer** - View response status, headers, and formatted JSON body

### Environment Variables
- Define reusable variables like `{{baseUrl}}`, `{{apiKey}}`
- Switch between environments (Development, Staging, Production)
- Variables are interpolated in URLs, headers, body, and auth fields

### Authentication
- **Bearer Token** - JWT and OAuth token support
- **Basic Auth** - Username/password with Base64 encoding
- **OAuth 2.0** - Configuration structure (implementation in progress)

### Code Generation
Export requests as code in multiple languages:
- **cURL** - Command-line ready
- **Swift** - URLSession implementation
- **Python** - requests library

### Request History
- Automatic logging of all requests
- View past requests grouped by date
- Restore requests from history

## Requirements

- macOS 14.0 (Sonoma) or later
- Xcode 15.0 or later

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/postwoman.git
   cd postwoman
   ```

2. Open in Xcode:
   ```bash
   open PostWoman.xcodeproj
   ```

3. Build and run (⌘R)

## Usage

### Creating a Request
1. Click the **+** button in the sidebar
2. Select "New Request" or "New Folder"
3. Enter the URL and select HTTP method
4. Configure headers, parameters, body as needed
5. Press **⌘↩** or click "Send"

### Using Environment Variables
1. Navigate to **Environments** in the sidebar
2. Create a new environment
3. Add variables (e.g., `baseUrl` = `https://api.example.com`)
4. Select the environment from the toolbar dropdown
5. Use `{{variableName}}` syntax in your requests

### Keyboard Shortcuts

| Action | Shortcut |
|--------|----------|
| New Request | ⌘N |
| New Folder | ⇧⌘N |
| Send Request | ⌘↩ |
| Save Request | ⌘S |
| Duplicate Request | ⌘D |
| Generate Code | ⇧⌘G |
| Manage Environments | ⌥⌘E |

## Project Structure

```
PostWoman/
├── App/                    # App entry point and main views
├── Models/                 # SwiftData models
├── Views/
│   ├── Sidebar/           # Collection tree and history
│   ├── RequestEditor/     # URL bar and request tabs
│   ├── ResponseViewer/    # Response display
│   ├── Environment/       # Environment management
│   └── CodeGeneration/    # Code export
├── Services/
│   ├── HTTPClient.swift   # Networking
│   ├── EnvironmentInterpolator.swift
│   ├── AuthenticationHandler.swift
│   └── CodeGenerator/     # cURL, Swift, Python generators
└── Utilities/             # JSON formatting, helpers
```

## Tech Stack

- **UI Framework**: SwiftUI
- **Data Persistence**: SwiftData
- **Networking**: URLSession with async/await
- **Target Platform**: macOS 14+

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Inspired by [Postman](https://www.postman.com/)
- Built with assistance from Claude (Anthropic)
