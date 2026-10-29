import CoreLocation
@testable import Fuel
import Testing

struct DistanceCalculatorTests {
    private let naples = CLLocationCoordinate2D(latitude: 40.8518, longitude: 14.2681)
    private let rome = CLLocationCoordinate2D(latitude: 41.9028, longitude: 12.4964)

    @Test func naplesToRome() {
        let distance = DistanceCalculator.distance(from: naples, to: rome)
        #expect(abs(distance - 188_434) < 1)
    }

    @Test func isSymmetric() {
        #expect(DistanceCalculator.distance(from: naples, to: rome) == DistanceCalculator.distance(from: rome, to: naples))
    }

    @Test func samePointIsZero() {
        #expect(DistanceCalculator.distance(from: naples, to: naples) == 0)
    }
}
