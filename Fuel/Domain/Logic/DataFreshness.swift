import Foundation

enum DataFreshness {
    private static let maxAge: TimeInterval = 48 * 3600

    /// Whole days since `pricesReferenceDate` (`yyyy-MM-dd`, Italian day), or nil when the data is at most 48 h old.
    /// Uses the reference date, not `generated_at`: the pipeline can republish old prices with a new timestamp.
    static func staleDays(pricesReferenceDate: String, now: Date) -> Int? {
        guard let day = referenceDay(pricesReferenceDate), now.timeIntervalSince(day) > maxAge else { return nil }
        return calendar.dateComponents([.day], from: day, to: now).day
    }

    /// Midnight in Italy of a `yyyy-MM-dd` reference date.
    static func referenceDay(_ pricesReferenceDate: String) -> Date? {
        let parts = pricesReferenceDate.split(separator: "-").compactMap { Int($0) }
        guard parts.count == 3 else { return nil }
        return calendar.date(from: DateComponents(year: parts[0], month: parts[1], day: parts[2]))
    }

    private static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        // swiftlint:disable:next force_unwrapping
        calendar.timeZone = TimeZone(identifier: "Europe/Rome")!
        return calendar
    }()
}
