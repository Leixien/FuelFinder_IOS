import Foundation
@testable import Fuel
import Testing

struct StationsDecoderTests {
    @Test func decodesRealFixture() throws {
        let payload = try StationsDecoder.decode(Fixture.sample)

        #expect(payload.schemaVersion == 1)
        #expect(payload.pricesReferenceDate == "2026-10-27")
        #expect(payload.source.license == "IODL 2.0")
        #expect(payload.stations.count == 30)

        let station = try #require(payload.stations.first { $0.id == 3513 })
        #expect(station.name == "S.PIETRO")
        #expect(station.brand == "Q8")
        #expect(station.operatorName == "SARNI S.R.L.")
        #expect(station.type == .autostradale)
        #expect(station.province == "NA")

        let price = try #require(station.prices.first)
        #expect(price.fuel == .benzina)
        #expect(price.price == 1.994)
        #expect(price.isSelf)
        #expect(price.updatedAt == Date(timeIntervalSince1970: 1_792_992_631))
    }

    @Test func keepsLabelOfSpecialFuels() throws {
        let payload = try StationsDecoder.decode(Fixture.sample)
        let specials = payload.stations.flatMap(\.prices).filter { $0.fuel == .gasolioSpecial }
        #expect(!specials.isEmpty)
        #expect(specials.allSatisfy { $0.label != nil })
    }

    @Test func skipsUnknownFuelsAndMapsUnknownTypesToAltro() throws {
        let data = Fixture.payload(stations: """
        [{ "id": 1, "name": "N", "brand": "B", "operator": "O", "type": "pompe_bianche",
           "address": "A", "city": "C", "province": "NA", "lat": 40.8, "lon": 14.2,
           "prices": [
             { "fuel": "hvo", "price": 1.9, "self": true, "updated_at": "2026-10-27T07:35:21Z" },
             { "fuel": "gasolio", "price": 1.7, "self": true, "updated_at": "2026-10-27T07:35:21Z", "extra": 1 }
           ] }]
        """)

        let station = try #require(try StationsDecoder.decode(data).stations.first)

        #expect(station.type == .altro)
        #expect(station.prices.map(\.fuel) == [.gasolio])
    }

    @Test func rejectsNewerSchemaEvenIfCompatible() {
        #expect(throws: DataError.unsupportedSchema(2)) {
            try StationsDecoder.decode(Fixture.payload(schemaVersion: 2))
        }
    }

    @Test func rejectsNewerIncompatibleSchema() {
        let data = Data(#"{ "schema_version": 3, "stations": "moved elsewhere" }"#.utf8)
        #expect(throws: DataError.unsupportedSchema(3)) {
            try StationsDecoder.decode(data)
        }
    }

    @Test func reportsMalformedData() {
        #expect(throws: DataError.decoding) {
            try StationsDecoder.decode(Data("<html>".utf8))
        }
    }
}
