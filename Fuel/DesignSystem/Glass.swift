import SwiftUI

extension View {
    /// Liquid Glass on iOS 26 and later; the frosted material it replaces on earlier versions.
    /// Only for chrome floating over the map: prices stay on solid surfaces so they read from a phone mount.
    @ViewBuilder
    func glassSurface(in shape: some Shape, interactive: Bool = false) -> some View {
        if #available(iOS 26, *) {
            glassEffect(interactive ? .regular.interactive() : .regular, in: shape)
        } else {
            background(.regularMaterial, in: shape)
                .shadow(color: .black.opacity(0.12), radius: 4, y: 1)
        }
    }
}

/// Lets neighbouring glass shapes blend and morph into each other on iOS 26; a pass-through earlier.
struct GlassGroup<Content: View>: View {
    /// Must match the spacing of the layout inside, or the glass shapes merge at the wrong distance.
    let spacing: CGFloat
    @ViewBuilder var content: Content

    var body: some View {
        if #available(iOS 26, *) {
            GlassEffectContainer(spacing: spacing) { content }
        } else {
            content
        }
    }
}
