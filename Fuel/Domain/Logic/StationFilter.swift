import CoreLocation

enum ServiceMode: String, CaseIterable, Sendable {
    case selfService
    case fullService
}

struct StationMatch: Sendable, Identifiable, Equatable {
    let station: Station
    let price: FuelPrice
    /// Metres from the search origin.
    let distance: Double

    var id: Int {
        station.id
    }
}

enum StationFilter {
    /// Stations selling `fuel` within `radius` metres of `origin`, nearest first.
    static func nearby(
        _ stations: [Station],
        fuel: FuelType,
        mode: ServiceMode,
        origin: CLLocationCoordinate2D,
        radius: Double
    ) -> [StationMatch] {
        stations
            .compactMap { station in
                guard let price = price(of: fuel, mode: mode, at: station) else { return nil }
                let distance = DistanceCalculator.distance(from: origin, to: station.coordinate)
                return distance <= radius ? StationMatch(station: station, price: price, distance: distance) : nil
            }
            .sorted { $0.distance < $1.distance }
    }

    /// Cheapest price in the requested mode; falls back to the other mode when the station lacks it
    /// (the UI flags it with a badge by comparing `isSelf` with the mode).
    static func price(of fuel: FuelType, mode: ServiceMode, at station: Station) -> FuelPrice? {
        let candidates = station.prices.filter { $0.fuel == fuel }
        let preferred = candidates.filter { $0.isSelf == (mode == .selfService) }
        return (preferred.isEmpty ? candidates : preferred).min { $0.price < $1.price }
    }
}
