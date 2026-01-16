# PostWoman

A native macOS REST API client built with SwiftUI and SwiftData. A lightweight Postman alternative designed specifically for macOS.

![macOS](https://img.shields.io/badge/macOS-14.0+-blue)
![Swift](https://img.shields.io/badge/Swift-5.9+-orange)
![SwiftUI](https://img.shields.io/badge/SwiftUI-5.0+-green)
![License](https://img.shields.io/badge/License-MIT-yellow)

## Features

### Core Functionality
- **REST API Testing** - Support for GET, POST, PUT, DELETE methods
- **Folder Organization** - Organize requests into nested collections
- **Request Editor** - Configure URL, headers, query parameters, body, and authentication
- **Response Viewer** - View response status, headers, and formatted JSON body

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

## Installation

### Download (Recommended)

Download the latest DMG installer from the [Releases](../../releases) page:

1. Download `PostWoman-vX.X.X.dmg`
2. Open the DMG file
3. Drag PostWoman to your Applications folder
4. Eject the DMG and launch PostWoman from Applications

### Build from Source

#### Requirements
- macOS 14.0 (Sonoma) or later
- Xcode 15.0 or later

#### Steps

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/postwoman.git
   cd postwoman
   ```

2. Open in Xcode:
   ```bash
   open PostWoman.xcodeproj
   ```

3. Build and run (Cmd+R)

#### Build DMG Installer

To create a distributable DMG:

```bash
./scripts/build-dmg.sh
```

Options:
- `-v, --version VERSION` - Set version string
- `-d, --debug` - Build debug configuration

The DMG will be created in the `dist/` directory.

## Usage

### Creating a Request
1. Click the **+** button in the sidebar
2. Select "New Request" or "New Folder"
3. Enter the URL and select HTTP method
4. Configure headers, parameters, body as needed
5. Press **Cmd+Return** or click "Send"

### Keyboard Shortcuts

| Action | Shortcut |
|--------|----------|
| New Request | Cmd+N |
| New Folder | Shift+Cmd+N |
| Send Request | Cmd+Return |
| Save Request | Cmd+S |
| Duplicate Request | Cmd+D |
| Generate Code | Shift+Cmd+G |

## Project Structure

```
PostWoman/
├── App/                    # App entry point and main views
├── Models/                 # SwiftData models
├── Views/
│   ├── Sidebar/           # Collection tree and history
│   ├── RequestEditor/     # URL bar and request tabs
│   ├── ResponseViewer/    # Response display
│   └── CodeGeneration/    # Code export
├── Services/
│   ├── HTTPClient.swift   # Networking
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

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details on:

- Setting up your development environment
- Our coding standards and conventions
- The pull request process

### Quick Start for Contributors

```bash
# Fork and clone
git clone https://github.com/YOUR_USERNAME/postwoman.git
cd postwoman

# Create a feature branch
git checkout -b feature/your-feature

# Make changes, then submit a PR
```

### Good First Issues

Check out issues labeled [`good first issue`](../../issues?q=is%3Aissue+is%3Aopen+label%3A%22good+first+issue%22) for beginner-friendly tasks.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Inspired by [Postman](https://www.postman.com/)
- Built with SwiftUI and SwiftData
