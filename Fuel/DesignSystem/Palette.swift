import SwiftUI

/// Every brand color lives in `Assets.xcassets` so a redesign touches one place.
/// Light values are darkened to keep white text above 4.5:1 contrast.
extension ShapeStyle where Self == Color {
    static var best: Color {
        Color("Best")
    }

    static var onBest: Color {
        Color("OnBest")
    }

    static var stale: Color {
        Color("Stale")
    }
}
