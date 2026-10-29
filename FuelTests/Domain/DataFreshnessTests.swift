import Foundation
@testable import Fuel
import Testing

struct DataFreshnessTests {
    private let now = Date(timeIntervalSince1970: 1_793_188_800) // 2026-10-28T12:00:00Z

    @Test func freshnessNilWithin48Hours() {
        #expect(DataFreshness.staleDays(pricesReferenceDate: "2026-10-27", now: now) == nil)
    }

    /// Prices for day D are published on D+1 morning, so the next file is due D+2 morning: no banner before then.
    @Test func freshnessCountsFromTheEndOfTheReferenceDay() {
        let morningAfterTwoNights = Date(timeIntervalSince1970: 1_793_257_200) // 2026-10-29T07:00:00Z, 08:00 in Rome
        #expect(DataFreshness.staleDays(pricesReferenceDate: "2026-10-27", now: morningAfterTwoNights) == nil)
        let threeNightsLater = Date(timeIntervalSince1970: 1_793_347_200) // 2026-10-30T08:00:00Z
        #expect(DataFreshness.staleDays(pricesReferenceDate: "2026-10-27", now: threeNightsLater) == 3)
    }

    @Test func freshnessReportsDays() {
        #expect(DataFreshness.staleDays(pricesReferenceDate: "2026-10-20", now: now) == 8)
    }

    @Test func unparsableDateIsNotStale() {
        #expect(DataFreshness.staleDays(pricesReferenceDate: "", now: now) == nil)
    }
}
