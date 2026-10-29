import CoreLocation
import Foundation

/// The test fixture (30 real Campania stations), bundled for previews and UI tests.
/// ponytail: it ships in Release too (a few KB); move it to a development asset if that ever matters.
enum PreviewData {
    /// 2026-10-28T12:00:00Z, the day after the fixture's prices.
    static let now = Date(timeIntervalSince1970: 1_793_188_800)
    /// Naples, Piazza Garibaldi.
    static let origin = CLLocationCoordinate2D(latitude: 40.8518, longitude: 14.2681)

    static let fixtureData: Data = {
        guard let url = Bundle.main.url(forResource: "stations_sample", withExtension: "json"),
              let data = try? Data(contentsOf: url)
        else { fatalError("stations_sample.json missing from the app bundle") }
        return data
    }()

    static let payload: StationsPayload = {
        guard let payload = try? StationsDecoder.decode(fixtureData) else { fatalError("stations_sample.json is invalid") }
        return payload
    }()

    static let matches: [StationMatch] = StationRanking.search(
        payload.stations, fuel: .benzina, mode: .selfService, origin: origin, sort: .price, now: now
    ).matches
}
