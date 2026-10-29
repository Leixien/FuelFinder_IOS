import Foundation

enum Formatters {
    static func price(_ value: Double, locale: Locale = .current) -> String {
        value.formatted(.number.precision(.fractionLength(3)).locale(locale))
    }

    /// Metano and GNL are sold by the kilogram.
    static func unit(for fuel: FuelType) -> String {
        isPerKilogram(fuel) ? "€/kg" : "€/l"
    }

    static func distance(_ metres: Double, locale: Locale = .current) -> String {
        if metres < 1000 {
            return Measurement(value: metres.rounded(), unit: UnitLength.meters)
                .formatted(.measurement(width: .abbreviated, usage: .asProvided).locale(locale))
        }
        return Measurement(value: metres / 1000, unit: UnitLength.kilometers).formatted(
            .measurement(width: .abbreviated, usage: .asProvided, numberFormatStyle: .number.precision(.fractionLength(1)))
                .locale(locale)
        )
    }

    /// Search radius, always whole kilometres ("entro 10 km").
    static func radius(_ metres: Double, locale: Locale = .current) -> String {
        Measurement(value: metres / 1000, unit: UnitLength.kilometers)
            .formatted(.measurement(width: .abbreviated, usage: .asProvided).locale(locale))
    }

    static func age(of date: Date, now: Date, locale: Locale = .current) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        formatter.locale = locale
        return formatter.localizedString(for: date, relativeTo: now)
    }

    /// "29 ottobre 2026" for a `yyyy-MM-dd` reference date, read as an Italian day whatever the device time zone.
    static func referenceDay(_ pricesReferenceDate: String, locale: Locale = .current) -> String? {
        guard let day = DataFreshness.referenceDay(pricesReferenceDate),
              let rome = TimeZone(identifier: "Europe/Rome")
        else { return nil }
        var style = Date.FormatStyle(date: .long, time: .omitted, locale: locale)
        style.timeZone = rome
        return day.formatted(style)
    }

    /// About 10 real stations have an empty `name`, and many independents have no `brand`.
    static func displayName(of station: Station) -> String {
        [station.brand, station.name]
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .first { !$0.isEmpty } ?? String(localized: "Distributore")
    }

    static func accessibilityLabel(for match: StationMatch) -> String {
        let name = displayName(of: match.station)
        let amount = price(match.price.price)
        let distance = distance(match.distance)
        let mode = match.price.isSelf ? String(localized: "self") : String(localized: "servito")
        return isPerKilogram(match.price.fuel)
            ? String(localized: "\(name), \(amount) euro al chilogrammo, a \(distance), \(mode)")
            : String(localized: "\(name), \(amount) euro al litro, a \(distance), \(mode)")
    }

    /// A price as VoiceOver should say it, with its unit in words.
    static func spokenPrice(_ value: Double, fuel: FuelType) -> String {
        let amount = price(value)
        return isPerKilogram(fuel)
            ? String(localized: "\(amount) euro al chilogrammo")
            : String(localized: "\(amount) euro al litro")
    }

    private static func isPerKilogram(_ fuel: FuelType) -> Bool {
        fuel == .metano || fuel == .gnl
    }
}

extension FuelType {
    var localizedName: LocalizedStringResource {
        switch self {
        case .benzina: "Benzina"
        case .gasolio: "Gasolio"
        case .gpl: "GPL"
        case .metano: "Metano"
        case .gnl: "GNL"
        case .hvo: "HVO"
        case .benzinaSpecial: "Benzina special"
        case .gasolioSpecial: "Gasolio special"
        }
    }
}
