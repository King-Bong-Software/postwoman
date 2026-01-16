import SwiftUI

/// Enumeration representing the different tabs available in the request editor.
/// Each tab corresponds to a different aspect of configuring an HTTP request.
enum RequestTab: String, CaseIterable, Identifiable {
    case params = "Params"
    case headers = "Headers"
    case body = "Body"
    case auth = "Auth"

    var id: String { rawValue }
}

/// A horizontal tab bar for navigating between different request configuration sections.
/// Displays tabs for Params, Headers, Body, and Auth with badges showing configured items.
/// Provides visual feedback about which request aspects have been configured.
struct RequestTabView: View {
    /// The currently selected tab, bound to the parent view.
    @Binding var selectedTab: RequestTab

    /// The API request being configured, used to calculate badge counts.
    let request: APIRequest

    /// The number of enabled query parameters configured for the request.
    var paramsCount: Int {
        request.queryParams.filter { $0.isEnabled && !$0.key.isEmpty }.count
    }

    /// The number of enabled headers configured for the request.
    var headersCount: Int {
        request.headers.filter { $0.isEnabled && !$0.key.isEmpty }.count
    }

    /// The main view body displaying horizontal tab buttons with badges.
    var body: some View {
        HStack(spacing: 4) {
            ForEach(RequestTab.allCases) { tab in
                TabButton(
                    title: tab.rawValue,
                    isSelected: selectedTab == tab,
                    badge: badgeCount(for: tab)
                ) {
                    selectedTab = tab
                }
            }
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(nsColor: .controlBackgroundColor))
    }

    /// Calculates the badge count to display on each tab based on configured items.
    /// Returns nil for tabs with no configured items to hide the badge.
    ///
    /// - Parameter tab: The tab to calculate the badge count for
    /// - Returns: The number to display in the badge, or nil to hide the badge
    private func badgeCount(for tab: RequestTab) -> Int? {
        switch tab {
        case .params: return paramsCount > 0 ? paramsCount : nil
        case .headers: return headersCount > 0 ? headersCount : nil
        case .body: return request.bodyContent.isEmpty ? nil : 1
        case .auth: return request.authenticationType != .none ? 1 : nil
        }
    }
}

/// A reusable tab button component with optional badge support.
/// Displays the tab title with visual feedback for selection state and optional badge count.
struct TabButton: View {
    /// The text to display on the tab button.
    let title: String

    /// Whether this tab is currently selected.
    let isSelected: Bool

    /// Optional badge count to display on the tab.
    let badge: Int?

    /// The action to perform when the tab is tapped.
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(title)
                    .fontWeight(isSelected ? .semibold : .regular)

                if let badge = badge {
                    Text("\(badge)")
                        .font(.caption2)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 1)
                        .background(isSelected ? Color.accentColor : Color.secondary.opacity(0.3))
                        .foregroundColor(isSelected ? .white : .primary)
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.accentColor.opacity(0.15) : Color.clear)
            .cornerRadius(6)
        }
        .buttonStyle(.plain)
    }
}
