import MapKit
import SwiftUI

/// The answer to "where is fuel cheapest near me", readable from a phone mount.
struct CheapestCard: View {
    let match: StationMatch
    let radius: Double
    let now: Date
    let onSelect: () -> Void

    @ScaledMetric(relativeTo: .largeTitle) private var priceSize = 56

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Più economico · entro \(Formatters.radius(radius))")
                .font(.caption.weight(.semibold))
                .textCase(.uppercase)
                .foregroundStyle(.secondary)
            Button(action: onSelect) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text(Formatters.price(match.price.price))
                            .font(.system(size: priceSize, weight: .bold, design: .rounded))
                            .monospacedDigit()
                            .minimumScaleFactor(0.6)
                        Text(Formatters.unit(for: match.price.fuel))
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                    Text(match.station.title(for: match.price))
                        .font(.headline)
                    if !match.station.address.isEmpty {
                        Text(match.station.address.localizedCapitalized)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                    Text(meta)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Formatters.accessibilityLabel(for: match))
            DirectionsButton(station: match.station)
                .padding(.top, 8)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("home.cheapestCard")
    }

    private var meta: String {
        let mode = match.price.isSelf ? String(localized: "Self") : String(localized: "Servito")
        let age = Formatters.age(of: match.price.updatedAt, now: now)
        return [Formatters.distance(match.distance), mode, age].joined(separator: " · ")
    }
}

struct DirectionsButton: View {
    let station: Station

    var body: some View {
        if #available(iOS 26, *) {
            button.buttonStyle(.glassProminent)
        } else {
            button.buttonStyle(.borderedProminent)
        }
    }

    private var button: some View {
        Button {
            let item = MKMapItem(placemark: MKPlacemark(coordinate: station.coordinate))
            item.name = Formatters.displayName(of: station)
            item.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
        } label: {
            Label("Indicazioni", systemImage: "arrow.triangle.turn.up.right.diamond.fill")
                .font(.headline)
                .frame(maxWidth: .infinity)
        }
        .controlSize(.large)
        .tint(.best)
        .foregroundStyle(.onBest)
    }
}

#Preview {
    CheapestCard(match: PreviewData.matches[0], radius: 5000, now: PreviewData.now) {}
        .padding()
}
