import SwiftUI

struct StationDetailView: View {
    let match: StationMatch
    /// The fuel being searched, highlighted in the table.
    let fuel: FuelType
    let now: Date
    let onClose: () -> Void

    private var station: Station {
        match.station
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            header
            HStack(spacing: 6) {
                Tag(text: Formatters.distance(match.distance))
                if let type = station.type.localizedName {
                    Tag(text: String(localized: type))
                }
            }
            DirectionsButton(station: station)
            priceGrid
            Text("Prezzi comunicati dal gestore · aggiornati \(Formatters.age(of: match.price.updatedAt, now: now))")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text(Formatters.displayName(of: station))
                    .font(.title2.weight(.bold))
                Text(fullAddress)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button(action: onClose) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text("Chiudi"))
            .accessibilityIdentifier("detail.close")
        }
    }

    private var priceGrid: some View {
        Grid(alignment: .leading, horizontalSpacing: 12, verticalSpacing: 10) {
            GridRow {
                Text("Carburante")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("Self").gridColumnAlignment(.trailing)
                Text("Servito").gridColumnAlignment(.trailing)
            }
            .font(.caption.weight(.semibold))
            .textCase(.uppercase)
            .foregroundStyle(.secondary)
            ForEach(PriceTable.rows(for: station)) { row in
                Divider().gridCellUnsizedAxes(.horizontal)
                let isChosen = row.fuel == fuel
                GridRow {
                    VStack(alignment: .leading, spacing: 1) {
                        Text(row.fuel.localizedName)
                        if let caption = caption(for: row) {
                            Text(caption).font(.caption).foregroundStyle(.secondary)
                        }
                    }
                    priceCell(row.selfPrice, isChosen: isChosen)
                    priceCell(row.servedPrice, isChosen: isChosen)
                }
                .fontWeight(isChosen ? .bold : .regular)
                .accessibilityElement(children: .combine)
            }
        }
    }

    private func priceCell(_ price: Double?, isChosen: Bool) -> some View {
        Text(price.map { Formatters.price($0) } ?? "—")
            .monospacedDigit()
            .foregroundStyle(isChosen && price != nil ? AnyShapeStyle(.best) : AnyShapeStyle(.primary))
    }

    /// Product name for special fuels, and the unit when it is not per litre.
    private func caption(for row: PriceTableRow) -> String? {
        let unit = Formatters.unit(for: row.fuel)
        let parts = [row.label, unit == "€/l" ? nil : unit].compactMap(\.self)
        return parts.isEmpty ? nil : parts.joined(separator: " · ")
    }

    private var fullAddress: String {
        let street = station.address.localizedCapitalized
        let city = station.city.localizedCapitalized
        return station.province.isEmpty ? "\(street), \(city)" : "\(street), \(city) (\(station.province))"
    }
}

private struct Tag: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(.fill.tertiary, in: RoundedRectangle(cornerRadius: 6))
    }
}

extension StationType {
    /// Nil for `altro`, which tells the user nothing.
    var localizedName: LocalizedStringResource? {
        switch self {
        case .stradale: "Stradale"
        case .autostradale: "Autostradale"
        case .altro: nil
        }
    }
}

#Preview {
    StationDetailView(match: PreviewData.matches[0], fuel: .benzina, now: PreviewData.now) {}
        .padding()
}
