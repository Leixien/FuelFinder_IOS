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
    static func payload(schemaVersion: Int = 1, stations: String = "[]") -> Data {
        Data("""
        {
          "schema_version": \(schemaVersion),
          "generated_at": "2026-10-28T06:30:00Z",
          "prices_reference_date": "2026-10-27",
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
