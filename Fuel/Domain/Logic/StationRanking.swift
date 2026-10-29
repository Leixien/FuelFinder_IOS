import CoreLocation

enum StationSort: String, CaseIterable, Sendable {
    case price
    case distance
}

struct NearbyResult: Sendable, Equatable {
    /// Metres actually searched after widening.
    let radius: Double
    let matches: [StationMatch]
    let cheapest: StationMatch?
}

enum StationRanking {
    static let radii: [Double] = [5000, 10000, 25000]
    /// MIMIT keeps republishing the last price a station reported, even years old.
    static let maxPriceAge: TimeInterval = 7 * 24 * 3600

    static func isFresh(_ price: FuelPrice, now: Date) -> Bool {
        now.timeIntervalSince(price.updatedAt) <= maxPriceAge
    }

    /// Only fresh prices in the chosen mode can be "the cheapest": a fallback price is not what was asked for.
    static func qualifiesForCheapest(_ match: StationMatch, mode: ServiceMode, now: Date) -> Bool {
        match.price.isSelf == (mode == .selfService) && isFresh(match.price, now: now)
    }

    /// Searches the smallest radius that has a qualifying station, widening up to the last one.
    static func search( // swiftlint:disable:this function_parameter_count
        _ stations: [Station],
        fuel: FuelType,
        mode: ServiceMode,
        origin: CLLocationCoordinate2D,
        sort: StationSort,
        now: Date
    ) -> NearbyResult {
        var radius = radii[0]
        var matches: [StationMatch] = []
        var qualified: [StationMatch] = []
        for candidate in radii {
            radius = candidate
            matches = StationFilter.nearby(stations, fuel: fuel, mode: mode, origin: origin, radius: candidate)
            qualified = matches.filter { qualifiesForCheapest($0, mode: mode, now: now) }
            if !qualified.isEmpty {
                break
            }
        }
        let byPrice: (StationMatch, StationMatch) -> Bool = {
            ($0.price.price, $0.distance) < ($1.price.price, $1.distance)
        }
        return NearbyResult(
            radius: radius,
            // `nearby` is already sorted by distance.
            matches: sort == .price ? matches.sorted(by: byPrice) : matches,
            cheapest: qualified.min(by: byPrice)
        )
    }
}
