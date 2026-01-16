import SwiftUI

/// View for editing query parameters (URL parameters) of an HTTP request.
/// Displays a list of key-value pairs that are appended to the request URL.
/// Supports adding, removing, enabling/disabling, and reordering parameters.
struct ParamsTabView: View {
    /// The list of query parameters, bound to the parent view for real-time updates.
    @Binding var params: [KeyValuePair]

    /// The main view body displaying parameter header and key-value editor.
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("Query Parameters")
                        .font(.headline)
                    Spacer()
                    Text("\(params.filter { $0.isEnabled && !$0.key.isEmpty }.count) active")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()

                Divider()

                KeyValueEditorView(
                    pairs: $params,
                    keyPlaceholder: "Parameter name",
                    valuePlaceholder: "Value"
                )
            }
        }
    }
}

#Preview {
    @Previewable @State var params: [KeyValuePair] = [
        KeyValuePair(key: "page", value: "1"),
        KeyValuePair(key: "limit", value: "10")
    ]

    ParamsTabView(params: $params)
        .frame(width: 600, height: 300)
}
