import SwiftUI
import SwiftData

/// The main request editor interface that allows users to configure and execute HTTP requests.
/// This view provides a comprehensive interface for editing all aspects of an API request
/// including URL, method, headers, parameters, body, and authentication. It also displays
/// the response from executed requests in a split-view layout.
struct RequestEditorView: View {
    /// Access to the SwiftData model context for database operations.
    @Environment(\.modelContext) private var modelContext

    /// The API request being edited. Changes are automatically bound to the model.
    @Bindable var request: APIRequest

    /// The currently selected tab in the request editor (params, headers, body, auth).
    @State private var selectedTab: RequestTab = .params

    /// The response from the most recently executed request, if any.
    @State private var response: HTTPResponse?

    /// Whether a request is currently being executed.
    @State private var isLoading: Bool = false

    /// Controls the visibility of the code generator sheet.
    @State private var showCodeGenerator: Bool = false

    /// Whether the request name is currently being edited inline.
    @State private var isRenaming: Bool = false

    /// HTTP client instance for executing requests.
    private let httpClient = HTTPClient()

    /// The main view body implementing a vertical split layout with request editor and response viewer.
    var body: some View {
        VSplitView {
            VStack(spacing: 0) {
                requestHeader
                    .padding()

                Divider()

                URLBarView(
                    url: $request.url,
                    method: $request.method,
                    isLoading: isLoading,
                    onSend: sendRequest
                )
                .padding(.horizontal)
                .padding(.vertical, 12)

                Divider()

                RequestTabView(selectedTab: $selectedTab, request: request)

                Divider()

                tabContent
            }
            .frame(minHeight: 300)

            ResponseViewerView(response: response, isLoading: isLoading)
                .frame(minHeight: 200)
        }
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button(action: { showCodeGenerator = true }) {
                    Image(systemName: "chevron.left.forwardslash.chevron.right")
                }
                .help("Generate Code")

                Button(action: saveRequest) {
                    Image(systemName: "square.and.arrow.down")
                }
                .help("Save Request")
            }
        }
        .sheet(isPresented: $showCodeGenerator) {
            CodeGeneratorView(request: request)
        }
        .onReceive(NotificationCenter.default.publisher(for: .sendRequest)) { _ in
            sendRequest()
        }
        .onReceive(NotificationCenter.default.publisher(for: .saveRequest)) { _ in
            saveRequest()
        }
        .onReceive(NotificationCenter.default.publisher(for: .generateCode)) { _ in
            showCodeGenerator = true
        }
        .onReceive(NotificationCenter.default.publisher(for: .duplicateRequest)) { _ in
            duplicateRequest()
        }
    }

    /// Header section showing the request name and folder information.
    /// Supports inline renaming via double-click on the request name.
    private var requestHeader: some View {
        HStack {
            if isRenaming {
                TextField("Request Name", text: $request.name)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: 300)
                    .onSubmit {
                        isRenaming = false
                    }
            } else {
                Text(request.name)
                    .font(.headline)
                    .onTapGesture(count: 2) {
                        isRenaming = true
                    }
            }

            Spacer()

            if let folder = request.folder {
                HStack(spacing: 4) {
                    Image(systemName: "folder")
                        .font(.caption)
                    Text(folder.name)
                        .font(.caption)
                }
                .foregroundColor(.secondary)
            }
        }
    }

    /// The content view for the currently selected tab (params, headers, body, auth).
    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case .params:
            ParamsTabView(params: $request.queryParams)
        case .headers:
            HeadersTabView(headers: $request.headers)
        case .body:
            BodyTabView(bodyType: $request.bodyType, bodyContent: $request.bodyContent)
        case .auth:
            AuthTabView(request: request)
        }
    }

    /// Executes the current request and displays the response.
    /// Updates the loading state and saves the request to history upon completion.
    private func sendRequest() {
        guard !request.url.isEmpty else { return }

        Task {
            isLoading = true
            defer { isLoading = false }

            do {
                response = try await httpClient.execute(request: request)
                saveToHistory()
            } catch {
                response = HTTPResponse.error(error)
            }
        }
    }

    /// Saves the current request configuration to the database.
    /// Updates the modified timestamp.
    private func saveRequest() {
        request.updatedAt = Date()
        try? modelContext.save()
    }

    /// Creates a duplicate of the current request with all configuration copied.
    /// The duplicate is inserted into the same folder with "(Copy)" appended to the name.
    private func duplicateRequest() {
        let duplicate = APIRequest(
            name: "\(request.name) (Copy)",
            url: request.url,
            method: request.method,
            folder: request.folder
        )
        duplicate.headers = request.headers
        duplicate.queryParams = request.queryParams
        duplicate.bodyType = request.bodyType
        duplicate.bodyContent = request.bodyContent
        duplicate.authenticationType = request.authenticationType
        duplicate.authBearerToken = request.authBearerToken
        duplicate.authBasicUsername = request.authBasicUsername
        duplicate.authBasicPassword = request.authBasicPassword
        duplicate.authOAuthConfig = request.authOAuthConfig

        modelContext.insert(duplicate)
    }

    /// Saves the executed request and its response to the history for later reference.
    /// Captures all request details and response metrics for debugging and replay.
    private func saveToHistory() {
        let history = RequestHistory(
            url: request.url,
            method: request.method,
            requestHeaders: request.headers,
            requestBody: request.bodyContent.isEmpty ? nil : request.bodyContent
        )
        history.statusCode = response?.statusCode
        history.responseHeaders = response?.headers
        history.responseBody = response?.body
        history.responseTime = response?.responseTime
        history.responseSize = response?.body?.data(using: .utf8)?.count
        history.wasSuccessful = response?.isSuccess ?? false
        history.savedRequestID = request.id

        modelContext.insert(history)
    }
}
