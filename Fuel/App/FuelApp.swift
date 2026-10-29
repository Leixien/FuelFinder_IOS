import SwiftUI

@main
struct FuelApp: App {
    @State private var model = HomeViewModel(environment: .resolve())

    var body: some Scene {
        WindowGroup {
            RootView(model: model)
        }
    }
}
