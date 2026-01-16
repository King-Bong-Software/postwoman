import SwiftUI

/// View for displaying HTTP response data from executed requests.
/// Shows response status, headers, and body content with appropriate formatting.
/// Handles loading states and empty states when no response is available.
struct ResponseViewerView: View {
    /// The HTTP response to display, if any.
    let response: HTTPResponse?

    /// Whether a request is currently being executed.
    let isLoading: Bool

    /// The currently selected tab for viewing response data.
    @State private var selectedTab: ResponseTab = .body

    /// Enumeration representing the different response data tabs.
    enum ResponseTab: String, CaseIterable {
        case body = "Body"
        case headers = "Headers"
    }

    /// The main view body displaying appropriate content based on loading/response state.
    var body: some View {
        VStack(spacing: 0) {
            if let response = response {
                ResponseStatusView(response: response)
                Divider()
            }

            if isLoading {
                loadingView
            } else if let response = response {
                responseContent(response)
            } else {
                emptyResponseView
            }
        }
        .background(Color(nsColor: .windowBackgroundColor))
    }

    /// View displayed while a request is being executed.
    /// Shows a progress indicator and loading message.
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Sending request...")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    /// View displayed when no response is available (no request has been sent yet).
    /// Provides guidance to the user about how to see response data.
    private var emptyResponseView: some View {
        VStack(spacing: 12) {
            Image(systemName: "arrow.down.doc")
                .font(.system(size: 48))
                .foregroundColor(.secondary.opacity(0.5))
            Text("Response")
                .font(.title2)
                .foregroundColor(.secondary)
            Text("Send a request to see the response here")
                .font(.body)
                .foregroundColor(.secondary.opacity(0.7))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    /// Displays the response content with tab navigation between body and headers.
    /// Includes the response status bar and tabbed content area.
    ///
    /// - Parameter response: The HTTP response to display
    @ViewBuilder
    private func responseContent(_ response: HTTPResponse) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 4) {
                ForEach(ResponseTab.allCases, id: \.self) { tab in
                    Button {
                        selectedTab = tab
                    } label: {
                        Text(tab.rawValue)
                            .fontWeight(selectedTab == tab ? .semibold : .regular)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(selectedTab == tab ? Color.accentColor.opacity(0.15) : Color.clear)
                            .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                }
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(nsColor: .controlBackgroundColor))

            Divider()

            switch selectedTab {
            case .body:
                ResponseBodyView(responseBody: response.body, contentType: response.contentType)
            case .headers:
                ResponseHeadersView(headers: response.headers)
            }
        }
    }
}
