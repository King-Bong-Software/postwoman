import SwiftUI

/// View displaying HTTP response status information in a compact horizontal layout.
/// Shows status code, response time, content size, and provides copy-to-clipboard functionality.
/// Uses color coding to indicate success/error status ranges.
struct ResponseStatusView: View {
    /// The HTTP response to display status information for.
    let response: HTTPResponse

    /// The main view body displaying status code, timing, and size information.
    var body: some View {
        HStack(spacing: 16) {
            HStack(spacing: 6) {
                Circle()
                    .fill(statusColor)
                    .frame(width: 8, height: 8)
                Text("\(response.statusCode)")
                    .font(.system(.headline, design: .monospaced))
                Text(response.statusText)
                    .foregroundColor(.secondary)
            }

            Divider()
                .frame(height: 16)

            Label("\(Int(response.responseTime)) ms", systemImage: "clock")
                .font(.caption)
                .foregroundColor(.secondary)

            if let body = response.body {
                let size = body.data(using: .utf8)?.count ?? 0
                Label(formatBytes(size), systemImage: "doc")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button {
                if let body = response.body {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(body, forType: .string)
                }
            } label: {
                Image(systemName: "doc.on.doc")
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
            .help("Copy response body")
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(statusColor.opacity(0.08))
    }

    /// The color used to indicate the response status range.
    /// Green for success (200-299), orange for redirects (300-399), red for errors (400+).
    private var statusColor: Color {
        switch response.statusCode {
        case 200..<300: return .green
        case 300..<400: return .orange
        case 400..<500: return .red
        case 500..<600: return .red
        default: return .gray
        }
    }

    /// Formats a byte count into a human-readable string with appropriate units.
    /// Converts bytes to KB or MB for larger values.
    ///
    /// - Parameter bytes: The number of bytes to format
    /// - Returns: Formatted string with appropriate unit (B, KB, or MB)
    private func formatBytes(_ bytes: Int) -> String {
        if bytes < 1024 {
            return "\(bytes) B"
        } else if bytes < 1024 * 1024 {
            return String(format: "%.1f KB", Double(bytes) / 1024)
        } else {
            return String(format: "%.1f MB", Double(bytes) / (1024 * 1024))
        }
    }
}
