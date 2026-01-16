import SwiftUI
import SwiftData

/// View displaying a chronological list of executed API requests.
/// Shows request history grouped by date (Today, Yesterday, or specific dates).
/// Supports searching by URL or HTTP method and provides request restoration.
struct HistoryListView: View {
    /// Access to the SwiftData model context for database operations.
    @Environment(\.modelContext) private var modelContext

    /// Query for all request history entries, sorted by timestamp descending.
    @Query(sort: \RequestHistory.timestamp, order: .reverse) private var history: [RequestHistory]

    /// The currently selected request in the main editor, bound for restoration.
    @Binding var selectedRequest: APIRequest?

    /// The current search text for filtering history entries.
    @State private var searchText: String = ""

    /// History entries grouped by date categories (Today, Yesterday, or specific dates).
    private var groupedHistory: [(String, [RequestHistory])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: filteredHistory) { item -> String in
            if calendar.isDateInToday(item.timestamp) {
                return "Today"
            } else if calendar.isDateInYesterday(item.timestamp) {
                return "Yesterday"
            } else {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                return formatter.string(from: item.timestamp)
            }
        }
        return grouped.sorted { $0.value.first?.timestamp ?? Date() > $1.value.first?.timestamp ?? Date() }
    }

    /// History entries filtered by search text, if any search is active.
    private var filteredHistory: [RequestHistory] {
        if searchText.isEmpty {
            return history
        }
        return history.filter { item in
            item.url.localizedCaseInsensitiveContains(searchText) ||
            item.method.rawValue.localizedCaseInsensitiveContains(searchText)
        }
    }

    /// The main view body displaying grouped, searchable history list with toolbar actions.
    var body: some View {
        List {
            ForEach(groupedHistory, id: \.0) { date, items in
                Section(date) {
                    ForEach(items) { item in
                        HistoryRowView(item: item)
                            .contextMenu {
                                Button("Restore to New Request") {
                                    restoreRequest(from: item)
                                }
                                Divider()
                                Button(role: .destructive) {
                                    deleteHistoryItem(item)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
            }
        }
        .listStyle(.sidebar)
        .scrollContentBackground(.hidden)
        .background(.white)
        .searchable(text: $searchText, prompt: "Search history")
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button(action: clearHistory) {
                    Image(systemName: "trash")
                }
                .help("Clear History")
                .disabled(history.isEmpty)
            }
        }
        .overlay {
            if history.isEmpty {
                ContentUnavailableView(
                    "No History",
                    systemImage: "clock",
                    description: Text("Your request history will appear here")
                )
            }
        }
    }

    /// Creates a new request from a history entry and selects it for editing.
    /// Restores the URL, method, headers, and request body from the history record.
    ///
    /// - Parameter historyItem: The history entry to restore as a new request
    private func restoreRequest(from historyItem: RequestHistory) {
        let request = APIRequest(
            name: "Restored: \(historyItem.url)",
            url: historyItem.url,
            method: historyItem.method
        )
        request.headers = historyItem.requestHeaders
        if let body = historyItem.requestBody {
            request.bodyContent = body
            request.bodyType = .json
        }
        modelContext.insert(request)
        selectedRequest = request
    }

    /// Deletes a single history entry from the database.
    ///
    /// - Parameter item: The history item to delete
    private func deleteHistoryItem(_ item: RequestHistory) {
        modelContext.delete(item)
    }

    /// Deletes all history entries from the database.
    private func clearHistory() {
        for item in history {
            modelContext.delete(item)
        }
    }
}

/// Individual row view for displaying a history entry in the sidebar.
/// Shows method, status code, timestamp, and URL in a compact format.
struct HistoryRowView: View {
    /// The history entry to display in this row.
    let item: RequestHistory

    /// The main view body displaying method, status, time, and URL.
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(item.method.rawValue)
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(item.method.color)

                if let statusCode = item.statusCode {
                    Text("\(statusCode)")
                        .font(.caption)
                        .foregroundColor(statusColor(for: statusCode))
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .background(statusColor(for: statusCode).opacity(0.15))
                        .cornerRadius(3)
                }

                Spacer()

                Text(item.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            Text(item.url)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(1)
                .truncationMode(.middle)
        }
        .padding(.vertical, 2)
    }

    /// Returns the appropriate color for an HTTP status code.
    /// Green for success (200-299), orange for redirects (300-399), red for errors (400+).
    ///
    /// - Parameter code: The HTTP status code
    /// - Returns: Color representing the status code category
    private func statusColor(for code: Int) -> Color {
        switch code {
        case 200..<300: return .green
        case 300..<400: return .orange
        case 400..<500: return .red
        case 500..<600: return .red
        default: return .gray
        }
    }
}
