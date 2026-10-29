import CoreLocation
import Foundation
@testable import Fuel
import Testing

private final class BundleToken {}

enum Fixture {
    static func data(_ name: String) throws -> Data {
        let url = try #require(Bundle(for: BundleToken.self).url(forResource: name, withExtension: "json"))
        return try Data(contentsOf: url)
    }

    static var sample: Data {
        get throws { try data("stations_sample") }
    }

    /// Minimal payload around the given `stations` JSON array, for edge cases the real fixture lacks.
    static func payload(schemaVersion: Int = 1, pricesReferenceDate: String = "2026-10-27", stations: String = "[]") -> Data {
        Data("""
        {
          "schema_version": \(schemaVersion),
          "generated_at": "2026-10-28T06:30:00Z",
          "prices_reference_date": "\(pricesReferenceDate)",
          "source": { "name": "MIMIT - Osservaprezzi Carburanti", "license": "IODL 2.0", "url": "https://www.mimit.gov.it" },
          "fuel_types": ["benzina"],
          "stations": \(stations)
        }
        """.utf8)
    }
}

extension Station {
    static func stub(id: Int = 1, lat: Double = 40.85, lon: Double = 14.27, prices: [FuelPrice]) -> Station {
        Station(
            id: id, name: "Test", brand: "Test", operatorName: "Test", type: .stradale,
            address: "Via Roma 1", city: "NAPOLI", province: "NA", lat: lat, lon: lon, prices: prices
        )
    }
}

extension FuelPrice {
    static func stub(
        _ fuel: FuelType, _ price: Double, isSelf: Bool = true, label: String? = nil, updatedAt: Date = .now
    ) -> FuelPrice {
        FuelPrice(fuel: fuel, price: price, isSelf: isSelf, updatedAt: updatedAt, label: label)
    }
}

func httpResponse(_ status: Int, etag: String? = nil) -> HTTPURLResponse {
    // swiftlint:disable:next force_unwrapping
    HTTPURLResponse(url: URL(filePath: "/"), statusCode: status, httpVersion: nil, headerFields: etag.map { ["ETag": $0] })!
}

/// Location provider for states `FixedLocation` cannot reach: denied, or authorized with no fix yet.
@MainActor
final class StubLocation: LocationProviding {
    let authorization: LocationAuthorization
    private let coordinate: CLLocationCoordinate2D?
    private(set) var requestedAuthorization = false

    init(_ authorization: LocationAuthorization, coordinate: CLLocationCoordinate2D? = nil) {
        self.authorization = authorization
        self.coordinate = coordinate
    }

    func requestAuthorization() {
        requestedAuthorization = true
    }

    func updates() -> AsyncStream<LocationUpdate> {
        AsyncStream { continuation in
            continuation.yield(.authorization(authorization))
            if let coordinate {
                continuation.yield(.location(coordinate))
            }
        }
    }
}

/// Polls `condition` on the main actor until it holds or `timeout` passes.
@MainActor
func eventually(timeout: Duration = .seconds(3), _ condition: () -> Bool) async -> Bool {
    let deadline = ContinuousClock.now + timeout
    while !condition() {
        if ContinuousClock.now > deadline {
            return false
        }
        try? await Task.sleep(for: .milliseconds(10))
    }
    return true
}
