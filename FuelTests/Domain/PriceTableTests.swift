@testable import Fuel
import Testing

struct PriceTableTests {
    @Test func oneRowPerFuelAndLabel() {
        let station = Station.stub(prices: [
            .stub(.gasolioSpecial, 1.85, label: "Hi-Q Diesel"),
            .stub(.gasolioSpecial, 1.95, label: "HiQ Perform+")
        ])

        let rows = PriceTable.rows(for: station)

        #expect(rows.map(\.label) == ["Hi-Q Diesel", "HiQ Perform+"])
    }

    @Test func mergesSelfAndServed() {
        let station = Station.stub(prices: [.stub(.benzina, 1.729), .stub(.benzina, 1.879, isSelf: false)])

        let rows = PriceTable.rows(for: station)

        #expect(rows.count == 1)
        #expect(rows.first?.selfPrice == 1.729)
        #expect(rows.first?.servedPrice == 1.879)
    }

    @Test func missingModeIsNil() {
        let station = Station.stub(prices: [.stub(.gpl, 0.719, isSelf: false)])

        #expect(PriceTable.rows(for: station).first?.selfPrice == nil)
    }

    @Test func ordersByFuelTypeAllCases() {
        let station = Station.stub(prices: [.stub(.metano, 1.3), .stub(.gpl, 0.7), .stub(.benzina, 1.8)])

        #expect(PriceTable.rows(for: station).map(\.fuel) == [.benzina, .gpl, .metano])
    }

    @Test func emptyLabelIsTreatedAsNoLabel() {
        let station = Station.stub(prices: [.stub(.benzina, 1.8, label: ""), .stub(.benzina, 1.9, isSelf: false)])

        let rows = PriceTable.rows(for: station)

        #expect(rows.count == 1)
        #expect(rows.first?.label == nil)
    }
}
