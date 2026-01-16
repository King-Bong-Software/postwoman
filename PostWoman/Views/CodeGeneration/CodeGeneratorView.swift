import SwiftUI

/// Modal sheet for generating code snippets from API requests.
/// Supports multiple programming languages (cURL, Swift, Python) with
/// a terminal-style interface for displaying generated code.
/// Provides copy-to-clipboard functionality and language switching.
struct CodeGeneratorView: View {
    /// The API request to generate code for.
    let request: APIRequest

    /// Environment value for dismissing the modal sheet.
    @Environment(\.dismiss) private var dismiss

    /// The currently selected programming language for code generation.
    @State private var selectedLanguage: CodeLanguage = .curl

    /// The generated code string for the selected language.
    @State private var generatedCode: String = ""

    /// Enumeration representing supported code generation languages.
    enum CodeLanguage: String, CaseIterable, Identifiable {
        case curl = "cURL"
        case swift = "Swift"
        case python = "Python"

        var id: String { rawValue }

        /// SF Symbol name for the icon representing this language.
        var icon: String {
            switch self {
            case .curl: return "terminal"
            case .swift: return "swift"
            case .python: return "chevron.left.forwardslash.chevron.right"
            }
        }
    }

    /// The main view body displaying header, language picker, and code display.
    var body: some View {
        VStack(spacing: 0) {
            header
                .padding()

            Divider()

            languagePicker
                .padding()

            Divider()

            codeView
        }
        .frame(width: 700, height: 500)
        .onAppear {
            generateCode()
        }
        .onChange(of: selectedLanguage) { _, _ in
            generateCode()
        }
    }

    /// Header section with title, description, and close button.
    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Generate Code")
                    .font(.headline)
                Text("Export this request as code in various languages")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button("Done") {
                dismiss()
            }
            .keyboardShortcut(.escape)
        }
    }

    /// Horizontal picker for selecting the programming language.
    /// Displays language buttons with icons and copy button.
    private var languagePicker: some View {
        HStack(spacing: 12) {
            ForEach(CodeLanguage.allCases) { language in
                Button {
                    selectedLanguage = language
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: language.icon)
                        Text(language.rawValue)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(selectedLanguage == language ? Color.accentColor : Color.secondary.opacity(0.1))
                    .foregroundColor(selectedLanguage == language ? .white : .primary)
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
            }

            Spacer()

            Button {
                copyToClipboard()
            } label: {
                Label("Copy", systemImage: "doc.on.doc")
            }
            .buttonStyle(.bordered)
        }
    }

    /// Terminal-style code display area with syntax highlighting.
    /// Includes terminal window chrome and scrollable code text.
    private var codeView: some View {
        VStack(spacing: 0) {
            // Terminal Header
            HStack(spacing: 6) {
                Circle()
                    .fill(Color.red.opacity(0.8))
                    .frame(width: 10, height: 10)
                Circle()
                    .fill(Color.yellow.opacity(0.8))
                    .frame(width: 10, height: 10)
                Circle()
                    .fill(Color.green.opacity(0.8))
                    .frame(width: 10, height: 10)

                Spacer()

                Text(selectedLanguage.rawValue.lowercased())
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(white: 0.15))

            ScrollView([.horizontal, .vertical]) {
                Text(generatedCode)
                    .font(.system(size: 13, weight: .regular, design: .monospaced))
                    .lineSpacing(4)
                    .foregroundColor(Color(red: 0.4, green: 1.0, blue: 0.4)) // Classic terminal green
                    .textSelection(.enabled)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .background(Color(white: 0.1)) // Dark terminal background
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .padding()
    }

    /// Generates code for the selected language using the appropriate generator.
    private func generateCode() {
        switch selectedLanguage {
        case .curl:
            generatedCode = CURLGenerator().generate(from: request)
        case .swift:
            generatedCode = SwiftGenerator().generate(from: request)
        case .python:
            generatedCode = PythonGenerator().generate(from: request)
        }
    }

    /// Copies the generated code to the system clipboard.
    private func copyToClipboard() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(generatedCode, forType: .string)
    }
}

#Preview {
    CodeGeneratorView(
        request: {
            let req = APIRequest(name: "Test Request", url: "https://api.example.com/users")
            req.method = .post
            req.headers = [
                KeyValuePair(key: "Content-Type", value: "application/json"),
                KeyValuePair(key: "Accept", value: "application/json")
            ]
            req.bodyType = .json
            req.bodyContent = """
            {
                "name": "John Doe",
                "email": "john@example.com"
            }
            """
            return req
        }()
    )
}
