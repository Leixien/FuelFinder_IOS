@testable import Fuel
import SwiftUI
import Testing

struct AppThemeTests {
    @Test func toggledFlipsEffectiveScheme() {
        #expect(AppTheme.toggled(from: .light) == .dark)
        #expect(AppTheme.toggled(from: .dark) == .light)
    }

    @Test func systemHasNoColorScheme() {
        #expect(AppTheme.system.colorScheme == nil)
        #expect(AppTheme.dark.colorScheme == .dark)
        #expect(AppTheme.light.colorScheme == .light)
    }
}
