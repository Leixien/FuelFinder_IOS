import CoreLocation
@testable import Fuel
import Testing

struct StationFilterTests {
    private let origin = CLLocationCoordinate2D(latitude: 40.85, longitude: 14.27)

    @Test func prefersRequestedModeAndCheapestPrice() {
        let station = Station.stub(prices: [
            .stub(.benzina, 1.90, isSelf: false),
            .stub(.benzina, 1.80),
            .stub(.benzina, 1.75, label: "Special"),
            .stub(.gasolio, 1.50)
        ])

        #expect(StationFilter.price(of: .benzina, mode: .selfService, at: station)?.price == 1.75)
        #expect(StationFilter.price(of: .benzina, mode: .fullService, at: station)?.price == 1.90)
    }

    @Test func fallsBackToOtherMode() {
        let station = Station.stub(prices: [.stub(.benzina, 1.90, isSelf: false)])

        let price = StationFilter.price(of: .benzina, mode: .selfService, at: station)

        #expect(price?.price == 1.90)
        #expect(price?.isSelf == false)
    }

    @Test func returnsNilWhenFuelMissing() {
        let station = Station.stub(prices: [.stub(.benzina, 1.80)])
        #expect(StationFilter.price(of: .metano, mode: .selfService, at: station) == nil)
    }

    @Test func nearbyFiltersByFuelAndRadiusSortedByDistance() {
        let far = Station.stub(id: 1, lat: 40.95, prices: [.stub(.benzina, 1.70)]) // ~11 km
        let near = Station.stub(id: 2, lat: 40.86, prices: [.stub(.benzina, 1.90)]) // ~1 km
        let mid = Station.stub(id: 3, lat: 40.88, prices: [.stub(.benzina, 1.80)]) // ~3 km
        let noFuel = Station.stub(id: 4, lat: 40.85, prices: [.stub(.gpl, 0.70)])

        let matches = StationFilter.nearby(
            [far, near, mid, noFuel], fuel: .benzina, mode: .selfService, origin: origin, radius: 5000
        )

        #expect(matches.map(\.id) == [2, 3])
        #expect(matches.allSatisfy { $0.distance <= 5000 })
    }

    @Test func nearbyOnRealFixture() throws {
        let stations = try StationsDecoder.decode(Fixture.sample).stations

        let matches = StationFilter.nearby(stations, fuel: .gasolio, mode: .selfService, origin: origin, radius: 20000)

        #expect(!matches.isEmpty)
        #expect(matches.map(\.distance) == matches.map(\.distance).sorted())
        #expect(matches.allSatisfy { $0.price.fuel == .gasolio })
    }
}
