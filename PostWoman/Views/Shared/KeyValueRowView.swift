import SwiftUI

/// Individual row view for editing a single key-value pair.
/// Displays enable/disable toggle, key and value text fields, and delete button.
/// Used for editing HTTP headers, query parameters, and form data.
struct KeyValueRowView: View {
    /// The key-value pair to edit, bound for real-time updates.
    @Binding var pair: KeyValuePair

    /// Placeholder text for the key text field.
    var keyPlaceholder: String = "Key"

    /// Placeholder text for the value text field.
    var valuePlaceholder: String = "Value"

    /// Callback executed when the delete button is pressed.
    var onDelete: () -> Void

    /// The main view body displaying toggle, text fields, and delete button.
    var body: some View {
        HStack(spacing: 8) {
            Toggle("", isOn: $pair.isEnabled)
                .toggleStyle(.checkbox)
                .labelsHidden()

            TextField(keyPlaceholder, text: $pair.key)
                .textFieldStyle(.roundedBorder)
                .frame(minWidth: 100)

            TextField(valuePlaceholder, text: $pair.value)
                .textFieldStyle(.roundedBorder)

            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
        }
        .opacity(pair.isEnabled ? 1.0 : 0.5)
    }
}

/// Editor view for managing a list of key-value pairs.
/// Displays multiple KeyValueRowView instances with an "Add" button.
/// Used throughout the app for editing headers, query parameters, and form data.
struct KeyValueEditorView: View {
    /// The list of key-value pairs to edit, bound for real-time updates.
    @Binding var pairs: [KeyValuePair]

    /// Placeholder text for key fields in all rows.
    var keyPlaceholder: String = "Key"

    /// Placeholder text for value fields in all rows.
    var valuePlaceholder: String = "Value"

    /// The main view body displaying all key-value pairs with add button.
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach($pairs) { $pair in
                KeyValueRowView(
                    pair: $pair,
                    keyPlaceholder: keyPlaceholder,
                    valuePlaceholder: valuePlaceholder
                ) {
                    if let index = pairs.firstIndex(where: { $0.id == pair.id }) {
                        pairs.remove(at: index)
                    }
                }
            }

            Button(action: addNewPair) {
                Label("Add", systemImage: "plus")
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
        .padding()
    }

    /// Adds a new empty key-value pair to the list.
    private func addNewPair() {
        pairs.append(KeyValuePair(key: "", value: ""))
    }
}

#Preview {
    @Previewable @State var pairs: [KeyValuePair] = [
        KeyValuePair(key: "Content-Type", value: "application/json"),
        KeyValuePair(key: "Authorization", value: "Bearer token123", isEnabled: false)
    ]

    KeyValueEditorView(pairs: $pairs)
        .frame(width: 500)
}
