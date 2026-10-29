import SwiftUI

struct RootView: View {
    let model: HomeViewModel

    var body: some View {
        HomeView(model: model)
    }
}

#if DEBUG
    #Preview {
        RootView(model: HomeViewModel(environment: .uiTest()))
    }
#endif
