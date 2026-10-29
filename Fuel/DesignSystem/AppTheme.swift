import SwiftUI

/// The user's appearance override; `system` follows the device until the corner toggle is first used.
enum AppTheme: String, CaseIterable, Sendable {
    case system
    case light
    case dark

    static let storageKey = "appTheme"

    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }

    /// The toggle flips what is on screen now, whatever produced it.
    static func toggled(from current: ColorScheme) -> AppTheme {
        current == .dark ? .light : .dark
    }
}
