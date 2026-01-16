import SwiftUI

/// View for editing HTTP request headers.
/// Displays a list of key-value pairs representing HTTP headers sent with the request.
/// Includes a quick-add menu for commonly used headers like Content-Type, Accept, etc.
struct HeadersTabView: View {
    /// The list of HTTP headers, bound to the parent view for real-time updates.
    @Binding var headers: [KeyValuePair]

    /// Commonly used HTTP headers that can be quickly added via the menu.
    private let commonHeaders = [
        "Content-Type",
        "Accept",
        "Authorization",
        "Cache-Control",
        "User-Agent",
        "X-API-Key"
    ]

    /// The main view body displaying header editor with quick-add menu.
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("Request Headers")
                        .font(.headline)
                    Spacer()

                    Menu {
                        ForEach(commonHeaders, id: \.self) { header in
                            Button(header) {
                                addHeader(key: header)
                            }
                        }
                    } label: {
                        Label("Common Headers", systemImage: "list.bullet")
                    }
                    .menuStyle(.borderlessButton)
                    .frame(width: 150)
                }
                .padding()

                Divider()

                KeyValueEditorView(
                    pairs: $headers,
                    keyPlaceholder: "Header name",
                    valuePlaceholder: "Value"
                )
            }
        }
    }

    /// Adds a new header with the specified key to the headers list.
    /// The new header has an empty value that the user can fill in.
    ///
    /// - Parameter key: The header name to add
    private func addHeader(key: String) {
        headers.append(KeyValuePair(key: key, value: ""))
    }
}

#Preview {
    @Previewable @State var headers: [KeyValuePair] = [
        KeyValuePair(key: "Content-Type", value: "application/json"),
        KeyValuePair(key: "Accept", value: "application/json")
    ]

    HeadersTabView(headers: $headers)
        .frame(width: 600, height: 300)
}
