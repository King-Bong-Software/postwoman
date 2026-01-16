import SwiftUI
import SwiftData

/// View displaying the list of API requests contained within a specific folder.
/// Provides search functionality, request creation, duplication, and deletion.
/// Requests are sorted by their display order and can be selected for editing.
struct FolderRequestsListView: View {
    /// Access to the SwiftData model context for database operations.
    @Environment(\.modelContext) private var modelContext

    /// The folder whose requests are being displayed.
    let folder: Folder

    /// The currently selected request in the main editor, bound for selection changes.
    @Binding var selectedRequest: APIRequest?

    /// The current search text for filtering requests.
    @State private var searchText: String = ""

    /// The filtered list of requests based on search criteria, sorted by display order.
    private var filteredRequests: [APIRequest] {
        let requests = folder.requests?.sorted(by: { $0.sortOrder < $1.sortOrder }) ?? []
        if searchText.isEmpty {
            return requests
        }
        return requests.filter { $0.name.localizedCaseInsensitiveContains(searchText) || $0.url.localizedCaseInsensitiveContains(searchText) }
    }

    /// The main view body displaying searchable request list with toolbar actions.
    var body: some View {
        List(selection: $selectedRequest) {
            ForEach(filteredRequests) { request in
                RequestRowView(request: request)
                    .tag(request)
                    .contextMenu {
                        Button(action: { duplicateRequest(request) }) {
                            Label("Duplicate", systemImage: "plus.square.on.square")
                        }
                        Divider()
                        Button(role: .destructive, action: { deleteRequest(request) }) {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
        }
        .listStyle(.sidebar)
        .scrollContentBackground(.hidden)
        .background(.white)
        .navigationTitle(folder.name)
        .searchable(text: $searchText, prompt: "Search requests")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: createRequest) {
                    Label("New Request", systemImage: "plus")
                }
            }
        }
        .overlay {
            if filteredRequests.isEmpty {
                ContentUnavailableView(
                    "No Requests",
                    systemImage: "plus.circle",
                    description: Text("Create a new request to get started")
                )
            }
        }
    }

    /// Creates a new API request in the current folder and selects it for editing.
    private func createRequest() {
        let request = APIRequest(name: "New Request", folder: folder)
        request.sortOrder = folder.requests?.count ?? 0
        modelContext.insert(request)
        selectedRequest = request
    }

    /// Creates a duplicate of the specified request in the same folder.
    /// Copies all configuration including headers, body, and authentication.
    ///
    /// - Parameter request: The request to duplicate
    private func duplicateRequest(_ request: APIRequest) {
        let newRequest = APIRequest(
            name: "\(request.name) Copy",
            url: request.url,
            method: request.method,
            folder: folder
        )
        newRequest.headers = request.headers
        newRequest.queryParams = request.queryParams
        newRequest.bodyType = request.bodyType
        newRequest.bodyContent = request.bodyContent
        newRequest.authenticationType = request.authenticationType
        newRequest.sortOrder = (folder.requests?.count ?? 0)

        modelContext.insert(newRequest)
        selectedRequest = newRequest
    }

    /// Deletes the specified request from the database.
    /// Deselects the request if it was currently selected.
    ///
    /// - Parameter request: The request to delete
    private func deleteRequest(_ request: APIRequest) {
        modelContext.delete(request)
        if selectedRequest?.id == request.id {
            selectedRequest = nil
        }
    }
}
