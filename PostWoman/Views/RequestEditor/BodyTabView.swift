import SwiftUI

/// View for editing HTTP request body content.
/// Supports different content types including JSON, XML, form data, and plain text.
/// Provides appropriate editors based on the selected content type.
struct BodyTabView: View {
    /// The type of content for the request body, bound to the parent view.
    @Binding var bodyType: ContentType

    /// The raw body content as a string, bound to the parent view.
    @Binding var bodyContent: String

    /// The main view body displaying content type picker and appropriate editor.
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Request Body")
                    .font(.headline)

                Spacer()

                Picker("Body Type", selection: $bodyType) {
                    ForEach(ContentType.allCases) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .labelsHidden()
                .frame(width: 120)
            }
            .padding()

            Divider()

            if bodyType == .none {
                VStack {
                    Spacer()
                    Text("This request does not have a body")
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if bodyType == .formData || bodyType == .urlEncoded {
                FormDataEditorView(bodyContent: $bodyContent)
            } else {
                TextEditor(text: $bodyContent)
                    .font(.system(.body, design: .monospaced))
                    .scrollContentBackground(.hidden)
                    .padding(8)
                    .background(Color(nsColor: .textBackgroundColor))
                    .cornerRadius(4)
                    .padding()
            }
        }
    }
}

/// Specialized editor for form data (URL-encoded or multipart form data).
/// Converts between structured key-value pairs and URL-encoded string format.
/// Automatically parses existing form data and serializes changes back to string format.
struct FormDataEditorView: View {
    /// The raw form data content as URL-encoded string, bound to the parent view.
    @Binding var bodyContent: String

    /// Parsed form data as structured key-value pairs for editing.
    @State private var formPairs: [KeyValuePair] = []

    /// The main view body displaying the key-value editor for form fields.
    var body: some View {
        ScrollView {
            KeyValueEditorView(
                pairs: $formPairs,
                keyPlaceholder: "Field name",
                valuePlaceholder: "Value"
            )
        }
        .onAppear {
            parseFormData()
        }
        .onChange(of: formPairs) { _, newValue in
            serializeFormData(newValue)
        }
    }

    /// Parses URL-encoded form data string into structured key-value pairs.
    /// Splits on '&' and '=' delimiters, handling URL decoding automatically.
    private func parseFormData() {
        guard !bodyContent.isEmpty else { return }
        formPairs = bodyContent.split(separator: "&").compactMap { pair in
            let parts = pair.split(separator: "=", maxSplits: 1)
            guard let key = parts.first else { return nil }
            let value = parts.count > 1 ? String(parts[1]) : ""
            return KeyValuePair(
                key: String(key).removingPercentEncoding ?? String(key),
                value: value.removingPercentEncoding ?? value
            )
        }
    }

    /// Serializes structured key-value pairs back into URL-encoded form data string.
    /// Only includes enabled pairs with non-empty keys, properly URL-encoding values.
    ///
    /// - Parameter pairs: The key-value pairs to serialize
    private func serializeFormData(_ pairs: [KeyValuePair]) {
        bodyContent = pairs
            .filter { $0.isEnabled && !$0.key.isEmpty }
            .map { pair in
                let key = pair.key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? pair.key
                let value = pair.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? pair.value
                return "\(key)=\(value)"
            }
            .joined(separator: "&")
    }
}

#Preview {
    @Previewable @State var bodyType: ContentType = .json
    @Previewable @State var bodyContent = """
    {
        "name": "John Doe",
        "email": "john@example.com"
    }
    """

    BodyTabView(bodyType: $bodyType, bodyContent: $bodyContent)
        .frame(width: 600, height: 400)
}
