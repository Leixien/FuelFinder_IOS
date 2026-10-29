import Foundation

struct PriceTableRow: Sendable, Equatable, Identifiable {
    let fuel: FuelType
    /// Commercial product name; a station can sell two products of the same category.
    let label: String?
    let selfPrice: Double?
    let servedPrice: Double?
    /// The more recent of the two cells.
    let updatedAt: Date

    var id: String {
        "\(fuel.rawValue)|\(label ?? "")"
    }
}

enum PriceTable {
    /// One row per (fuel, label), in `FuelType.allCases` order, then by label.
    static func rows(for station: Station) -> [PriceTableRow] {
        let order = Dictionary(uniqueKeysWithValues: FuelType.allCases.enumerated().map { ($1, $0) })
        return Dictionary(grouping: station.prices) { PriceTableRow.Key(fuel: $0.fuel, label: $0.label) }
            .map { key, prices in
                PriceTableRow(
                    fuel: key.fuel,
                    label: key.label,
                    selfPrice: prices.filter(\.isSelf).map(\.price).min(),
                    servedPrice: prices.filter { !$0.isSelf }.map(\.price).min(),
                    updatedAt: prices.map(\.updatedAt).max() ?? .distantPast
                )
            }
            .sorted { (order[$0.fuel] ?? 0, $0.label ?? "") < (order[$1.fuel] ?? 0, $1.label ?? "") }
    }
}

private extension PriceTableRow {
    struct Key: Hashable {
        let fuel: FuelType
        let label: String?
    }
}
