import Foundation
@testable import Fuel
import Testing

struct FormattersTests {
    private let italian = Locale(identifier: "it_IT")

    @Test func priceHasThreeDecimalsAndLocaleSeparator() {
        #expect(Formatters.price(1.729, locale: italian) == "1,729")
        #expect(Formatters.price(1.7, locale: italian) == "1,700")
        #expect(Formatters.price(1.729, locale: Locale(identifier: "en_US")) == "1.729")
    }

    @Test func unitIsPerKgForMetanoAndGnl() {
        #expect(Formatters.unit(for: .metano) == "€/kg")
        #expect(Formatters.unit(for: .gnl) == "€/kg")
        #expect(Formatters.unit(for: .benzina) == "€/l")
        #expect(Formatters.unit(for: .gpl) == "€/l")
    }

    @Test func distanceSwitchesFromMetresToKilometres() {
        #expect(Formatters.distance(850, locale: italian) == "850 m")
        #expect(Formatters.distance(1240, locale: italian) == "1,2 km")
    }

    @Test func displayNameFallsBack() {
        #expect(Formatters.displayName(of: station(brand: "Q8", name: "AGICAM")) == "Q8")
        #expect(Formatters.displayName(of: station(brand: "", name: "AGICAM")) == "AGICAM")
        #expect(Formatters.displayName(of: station(brand: " ", name: "")) == String(localized: "Distributore"))
    }

    /// The test runner's language is not fixed, so this checks the unit changes the label, not its wording.
    @Test func accessibilityLabelUsesKgForMetano() {
        let litre = match(.benzina)
        let kilo = match(.metano)

        #expect(Formatters.accessibilityLabel(for: litre) != Formatters.accessibilityLabel(for: kilo))
        #expect(Formatters.accessibilityLabel(for: kilo).contains(Formatters.price(1.5)))
    }

    private func station(brand: String, name: String) -> Station {
        Station(
            id: 1, name: name, brand: brand, operatorName: "", type: .stradale,
            address: "", city: "", province: "", lat: 0, lon: 0, prices: []
        )
    }

    private func match(_ fuel: FuelType) -> StationMatch {
        let price = FuelPrice.stub(fuel, 1.5)
        return StationMatch(station: .stub(prices: [price]), price: price, distance: 1200)
    }
}
