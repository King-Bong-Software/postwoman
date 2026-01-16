import SwiftUI

/// View displayed when no request is selected in the main editor.
/// Provides guidance to users on how to get started and quick actions
/// for creating new requests or folders via NotificationCenter.
struct EmptyStateView: View {
    /// The main view body displaying empty state message with action buttons.
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "arrow.left.arrow.right")
                .font(.system(size: 64))
                .foregroundColor(.secondary.opacity(0.5))

            Text("No Request Selected")
                .font(.title2)
                .fontWeight(.medium)

            Text("Select a request from the sidebar or create a new one to get started.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 300)

            HStack(spacing: 16) {
                Button(action: {
                    NotificationCenter.default.post(name: .createNewRequest, object: nil)
                }) {
                    Label("New Request", systemImage: "plus.circle")
                }
                .buttonStyle(.borderedProminent)

                Button(action: {
                    NotificationCenter.default.post(name: .createNewFolder, object: nil)
                }) {
                    Label("New Folder", systemImage: "folder.badge.plus")
                }
                .buttonStyle(.bordered)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(nsColor: .windowBackgroundColor))
    }
}

#Preview {
    EmptyStateView()
        .frame(width: 600, height: 400)
}
