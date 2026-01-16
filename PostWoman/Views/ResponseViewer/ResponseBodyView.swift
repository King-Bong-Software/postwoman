import SwiftUI

/// View for displaying HTTP response body content with formatting options.
/// Supports pretty-printing JSON responses and provides raw/plain text views.
/// Includes copy-to-clipboard functionality and content type display.
struct ResponseBodyView: View {
    /// The raw response body content as a string.
    let responseBody: String?

    /// The Content-Type header value from the response.
    let contentType: String?

    /// The current view mode (pretty-formatted or raw text).
    @State private var viewMode: ViewMode = .pretty

    /// The formatted/pretty-printed version of the response body.
    @State private var formattedBody: String = ""

    /// Enumeration representing the different display modes for response body.
    enum ViewMode: String, CaseIterable {
        case pretty = "Pretty"
        case raw = "Raw"
    }

    /// The main view body displaying response body with formatting controls.
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Picker("View Mode", selection: $viewMode) {
                    ForEach(ViewMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 150)

                Spacer()

                if let ct = contentType {
                    Text(ct)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(4)
                }

                Button {
                    copyToClipboard()
                } label: {
                    Image(systemName: "doc.on.doc")
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .help("Copy to clipboard")
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            Divider()

            if let bodyContent = responseBody, !bodyContent.isEmpty {
                ScrollView([.horizontal, .vertical]) {
                    Text(viewMode == .pretty ? formattedBody : bodyContent)
                        .font(.system(.body, design: .monospaced))
                        .textSelection(.enabled)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            } else {
                VStack {
                    Text("No response body")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            formatBody()
        }
        .onChange(of: responseBody) { _, _ in
            formatBody()
        }
    }

    /// Formats the response body for pretty display.
    /// Applies JSON formatting for JSON content types, otherwise leaves as-is.
    private func formatBody() {
        guard let body = responseBody else {
            formattedBody = ""
            return
        }

        if contentType?.contains("json") == true {
            formattedBody = JSONFormatter.format(body) ?? body
        } else {
            formattedBody = body
        }
    }

    /// Copies the current view content (pretty or raw) to the system clipboard.
    private func copyToClipboard() {
        let content = viewMode == .pretty ? formattedBody : (responseBody ?? "")
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(content, forType: .string)
    }
}

#Preview {
    ResponseBodyView(
        responseBody: """
        {"id": 1, "name": "John Doe", "email": "john@example.com", "nested": {"key": "value"}}
        """,
        contentType: "application/json"
    )
    .frame(width: 600, height: 400)
}
