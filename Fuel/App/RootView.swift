import SwiftUI

struct RootView: View {
    let model: HomeViewModel
    @AppStorage(AppTheme.storageKey) private var theme: AppTheme = .system

    var body: some View {
        HomeView(model: model)
            .preferredColorScheme(theme.colorScheme)
    }
}

#if DEBUG
    #Preview {
        RootView(model: HomeViewModel(environment: .uiTest()))
    }
#endif
