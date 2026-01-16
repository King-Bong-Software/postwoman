import SwiftUI
import SwiftData

/// Row view for displaying a folder/collection in the sidebar.
/// Shows folder icon, name, request count, and provides actions for rename, export, and delete.
/// Supports inline renaming and hover-based action menu.
struct FolderRowView: View {
    /// Access to the SwiftData model context for database operations.
    @Environment(\.modelContext) private var modelContext

    /// The folder to display in this row, bound for real-time updates.
    @Bindable var folder: Folder

    /// Whether the folder name is currently being edited inline.
    @State private var isRenaming: Bool = false

    /// Whether the mouse is currently hovering over this row.
    @State private var isHovered: Bool = false

    /// The main view body displaying folder information with action menu.
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "folder")
                .foregroundColor(.secondary)

            if isRenaming {
                TextField("Folder Name", text: $folder.name)
                    .textFieldStyle(.plain)
                    .onSubmit {
                        isRenaming = false
                    }
            } else {
                Text(folder.name)
                    .lineLimit(1)
            }

            Spacer()

            if isHovered || isRenaming {
                Menu {
                    Button(action: { isRenaming = true }) {
                        Label("Rename Folder", systemImage: "pencil")
                    }
                    Button(action: exportFolder) {
                        Label("Export Collection...", systemImage: "square.and.arrow.up")
                    }
                    Divider()
                    Button(role: .destructive, action: deleteFolder) {
                        Label("Delete Folder", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle.fill")
                        .foregroundColor(.secondary)
                        .font(.system(size: 14))
                }
                .menuStyle(.button)
                .buttonStyle(.plain)
                .fixedSize()
            }

            Text("\(folder.requests?.count ?? 0)")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 2)
        .contentShape(Rectangle())
        .onHover { hovering in
            isHovered = hovering
        }
        .contextMenu {
            Button(action: { isRenaming = true }) {
                Label("Rename Folder", systemImage: "pencil")
            }
            Button(action: exportFolder) {
                Label("Export Collection...", systemImage: "square.and.arrow.up")
            }
            Divider()
            Button(role: .destructive, action: deleteFolder) {
                Label("Delete Folder", systemImage: "trash")
            }
        }
    }

    /// Deletes the folder from the database (cascade-deletes all contained requests).
    private func deleteFolder() {
        modelContext.delete(folder)
    }

    /// Shows a save dialog to export the folder and its requests as a JSON file.
    private func exportFolder() {
        ExportImportService.exportFolderWithDialog(folder)
    }
}
