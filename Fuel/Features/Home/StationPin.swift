import SwiftUI

/// Map marker carrying the price itself, so the map answers "where is it cheaper" without taps.
struct StationPin: View {
    let match: StationMatch
    let isBest: Bool
    let isSelected: Bool

    var body: some View {
        Text(Formatters.price(match.price.price))
            .font(isBest ? .subheadline.weight(.bold) : .caption.weight(.bold))
            .monospacedDigit()
            .foregroundStyle(isBest ? AnyShapeStyle(.onBest) : AnyShapeStyle(.primary))
            .padding(.horizontal, isBest ? 10 : 7)
            .padding(.vertical, isBest ? 6 : 4)
            .background(isBest ? AnyShapeStyle(.best) : AnyShapeStyle(.background), in: Capsule())
            .overlay {
                if isSelected {
                    Capsule().strokeBorder(Color.accentColor, lineWidth: 3)
                }
            }
            .shadow(color: .black.opacity(0.25), radius: 3, y: 1)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Formatters.accessibilityLabel(for: match))
            .accessibilityAddTraits(.isButton)
    }
}

#Preview {
    HStack {
        StationPin(match: PreviewData.matches[0], isBest: true, isSelected: false)
        StationPin(match: PreviewData.matches[1], isBest: false, isSelected: true)
    }
    .padding()
}
