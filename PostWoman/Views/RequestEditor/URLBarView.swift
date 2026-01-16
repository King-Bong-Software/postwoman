import SwiftUI

/// A horizontal bar for configuring the HTTP method, URL, and sending requests.
/// Provides the primary interface for specifying the target endpoint and initiating requests.
/// Features method selection with color coding, URL input with monospace font, and a send button.
struct URLBarView: View {
    /// The request URL, bound to the parent view for real-time updates.
    @Binding var url: String

    /// The HTTP method for the request, bound to the parent view.
    @Binding var method: HTTPMethod

    /// Whether a request is currently being sent, controls button state.
    let isLoading: Bool

    /// Callback executed when the send button is pressed or Enter is pressed.
    let onSend: () -> Void

    /// The main view body containing method picker, URL field, and send button.
    var body: some View {
        HStack(spacing: 12) {
            Picker("Method", selection: $method) {
                ForEach(HTTPMethod.allCases) { method in
                    Text(method.rawValue)
                        .tag(method)
                }
            }
            .labelsHidden()
            .frame(width: 100)
            .tint(method.color)

            TextField("Enter request URL", text: $url)
                .textFieldStyle(.roundedBorder)
                .font(.system(.body, design: .monospaced))
                .onSubmit(onSend)

            Button(action: onSend) {
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.7)
                        .frame(width: 50)
                } else {
                    Text("Send")
                        .frame(width: 50)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(url.isEmpty || isLoading)
            .keyboardShortcut(.return, modifiers: .command)
        }
    }
}

#Preview {
    @Previewable @State var url = "https://api.example.com/users"
    @Previewable @State var method: HTTPMethod = .get

    URLBarView(
        url: $url,
        method: $method,
        isLoading: false,
        onSend: {}
    )
    .padding()
}
