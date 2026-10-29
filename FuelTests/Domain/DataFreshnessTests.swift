import Foundation
@testable import Fuel
import Testing

struct DataFreshnessTests {
    private let now = Date(timeIntervalSince1970: 1_793_188_800) // 2026-10-28T12:00:00Z

    @Test func freshnessNilWithin48Hours() {
        #expect(DataFreshness.staleDays(pricesReferenceDate: "2026-10-27", now: now) == nil)
    }

    @Test func freshnessReportsDays() {
        #expect(DataFreshness.staleDays(pricesReferenceDate: "2026-10-20", now: now) == 8)
    }

    @Test func unparsableDateIsNotStale() {
        #expect(DataFreshness.staleDays(pricesReferenceDate: "", now: now) == nil)
    }
}
