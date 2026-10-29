import CoreLocation
import Foundation
@testable import Fuel
import Testing

struct StationRankingTests {
    private let origin = CLLocationCoordinate2D(latitude: 40.85, longitude: 14.27)
    private let now = Date(timeIntervalSince1970: 1_793_188_800) // 2026-10-28T12:00:00Z

    private func search(_ stations: [Station], mode: ServiceMode = .selfService, sort: StationSort = .price) -> NearbyResult {
        StationRanking.search(stations, fuel: .benzina, mode: mode, origin: origin, sort: sort, now: now)
    }

    @Test func cheapestIgnoresPricesOlderThanSevenDays() {
        let old = Station.stub(id: 1, prices: [.stub(.benzina, 1.60, updatedAt: now.addingTimeInterval(-8 * 86400))])
        let fresh = Station.stub(id: 2, lat: 40.86, prices: [.stub(.benzina, 1.70, updatedAt: now)])

        let result = search([old, fresh])

        #expect(result.cheapest?.id == 2)
        #expect(result.matches.map(\.id).contains(1))
    }

    @Test func cheapestIgnoresFallbackMode() {
        let servedOnly = Station.stub(id: 1, prices: [.stub(.benzina, 1.50, isSelf: false, updatedAt: now)])
        let selfService = Station.stub(id: 2, lat: 40.86, prices: [.stub(.benzina, 1.80, updatedAt: now)])

        let result = search([servedOnly, selfService])

        #expect(result.cheapest?.id == 2)
        #expect(result.matches.count == 2)
    }

    @Test func tieOnPriceGoesToNearest() {
        let far = Station.stub(id: 1, lat: 40.88, prices: [.stub(.benzina, 1.70, updatedAt: now)])
        let near = Station.stub(id: 2, lat: 40.86, prices: [.stub(.benzina, 1.70, updatedAt: now)])

        #expect(search([far, near]).cheapest?.id == 2)
    }

    @Test func widensRadiusUntilAQualifiedStation() {
        let station = Station.stub(lat: 40.922, prices: [.stub(.benzina, 1.70, updatedAt: now)]) // ~8 km

        let result = search([station])

        #expect(result.radius == 10000)
        #expect(result.cheapest != nil)
    }

    @Test func emptyWithinMaxRadiusHasNoCheapest() {
        let station = Station.stub(lat: 41.21, prices: [.stub(.benzina, 1.70, updatedAt: now)]) // ~40 km

        let result = search([station])

        #expect(result.radius == 25000)
        #expect(result.matches.isEmpty)
        #expect(result.cheapest == nil)
    }

    @Test func staleOnlyStationsDoNotStopWidening() {
        let stale = Station.stub(id: 1, lat: 40.86, prices: [
            .stub(.benzina, 1.60, updatedAt: now.addingTimeInterval(-30 * 86400))
        ])
        let fresh = Station.stub(id: 2, lat: 40.922, prices: [.stub(.benzina, 1.70, updatedAt: now)])

        let result = search([stale, fresh])

        #expect(result.radius == 10000)
        #expect(result.cheapest?.id == 2)
    }

    @Test func otherModeWinsWhenChosenModeIsMissingEverywhere() {
        // GPL is almost never self-service in Italy: the default Self mode must still give an answer.
        let served = Station.stub(prices: [.stub(.benzina, 0.72, isSelf: false, updatedAt: now)])

        let result = search([served])

        #expect(result.cheapest?.id == served.id)
        // The fallback restarts from the smallest radius: the nearest served pump, not one 25 km away.
        #expect(result.radius == 5000)
    }

    @Test func oldCheapProductDoesNotHideCurrentPrice() {
        let station = Station.stub(prices: [
            .stub(.benzina, 1.60, label: "Old", updatedAt: now.addingTimeInterval(-3650 * 86400)),
            .stub(.benzina, 1.90, label: "Current", updatedAt: now)
        ])

        let result = search([station])

        #expect(result.cheapest?.price.price == 1.90)
        #expect(result.matches.first?.price.price == 1.90)
    }

    @Test func sortByPriceAndByDistance() {
        let nearExpensive = Station.stub(id: 1, lat: 40.86, prices: [.stub(.benzina, 1.90, updatedAt: now)])
        let farCheap = Station.stub(id: 2, lat: 40.88, prices: [.stub(.benzina, 1.70, updatedAt: now)])

        #expect(search([nearExpensive, farCheap], sort: .price).matches.map(\.id) == [2, 1])
        #expect(search([nearExpensive, farCheap], sort: .distance).matches.map(\.id) == [1, 2])
    }
}
