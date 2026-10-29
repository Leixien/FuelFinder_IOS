import SwiftUI

struct StationRow: View {
    let match: StationMatch
    let mode: ServiceMode
    let isBest: Bool
    let now: Date

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(match.station.title(for: match.price))
                    .font(.body.weight(.semibold))
                    .lineLimit(1)
                HStack(spacing: 4) {
                    Text(Formatters.distance(match.distance))
                    Text(verbatim: "·")
                    Text(Formatters.age(of: match.price.updatedAt, now: now))
                        .foregroundStyle(StationRanking.isFresh(match.price, now: now) ? AnyShapeStyle(.secondary) : AnyShapeStyle(.stale))
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
            Spacer(minLength: 8)
            if match.price.isSelf != (mode == .selfService) {
                ModeBadge(isSelf: match.price.isSelf)
            }
            Text(Formatters.price(match.price.price))
                .font(.title3.weight(.bold))
                .monospacedDigit()
                .foregroundStyle(isBest ? AnyShapeStyle(.best) : AnyShapeStyle(.primary))
        }
        .contentShape(Rectangle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Formatters.accessibilityLabel(for: match))
        .accessibilityAddTraits(.isButton)
    }
}

/// Shown when a station lacks the chosen mode and its other-mode price is used instead.
struct ModeBadge: View {
    let isSelf: Bool

    var body: some View {
        Text(isSelf ? ServiceMode.selfService.localizedName : ServiceMode.fullService.localizedName)
            .font(.caption2.weight(.bold))
            .textCase(.uppercase)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(.fill.tertiary, in: RoundedRectangle(cornerRadius: 5))
    }
}

extension Station {
    /// Display name plus the commercial product name for special fuels, e.g. "Q8 · Hi-Q Diesel".
    func title(for price: FuelPrice) -> String {
        let name = Formatters.displayName(of: self)
        guard let label = price.label, !label.isEmpty else { return name }
        return "\(name) · \(label)"
    }
}

#Preview {
    List(PreviewData.matches) { match in
        StationRow(match: match, mode: .selfService, isBest: match.id == PreviewData.matches.first?.id, now: PreviewData.now)
    }
}
