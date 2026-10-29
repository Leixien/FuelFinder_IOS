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
        radius: Double,
        now: Date = .now
    ) -> [StationMatch] {
        stations
            .compactMap { station in
                guard let price = price(of: fuel, mode: mode, at: station, now: now) else { return nil }
                let distance = DistanceCalculator.distance(from: origin, to: station.coordinate)
                return distance <= radius ? StationMatch(station: station, price: price, distance: distance) : nil
            }
            .sorted { $0.distance < $1.distance }
    }

    /// Cheapest price in the requested mode; falls back to the other mode when the station lacks it
    /// (the UI flags it with a badge by comparing `isSelf` with the mode).
    /// Fresh prices come first: a product last reported years ago must not hide today's price.
    static func price(of fuel: FuelType, mode: ServiceMode, at station: Station, now: Date = .now) -> FuelPrice? {
        let candidates = station.prices.filter { $0.fuel == fuel }
        let inMode: (FuelPrice) -> Bool = { $0.isSelf == (mode == .selfService) }
        let fresh: (FuelPrice) -> Bool = { StationRanking.isFresh($0, now: now) }
        let tiers: [(FuelPrice) -> Bool] = [
            { fresh($0) && inMode($0) }, fresh, inMode, { _ in true }
        ]
        for tier in tiers {
            if let best = candidates.filter(tier).min(by: { $0.price < $1.price }) {
                return best
            }
        }
        return nil
    }
}
