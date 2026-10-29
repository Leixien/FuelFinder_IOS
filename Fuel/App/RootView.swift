import SwiftUI

/// Placeholder until the Nearby and Map features land (Fase 2).
struct RootView: View {
    var body: some View {
        ContentUnavailableView("Prezzi carburanti in arrivo", systemImage: "fuelpump")
            .accessibilityIdentifier("root.placeholder")
    }
}

#Preview {
    RootView()
}
