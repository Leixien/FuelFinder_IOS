import CoreLocation
@testable import Fuel
import Testing

struct LocationAuthorizationTests {
    @Test(arguments: [
        (CLAuthorizationStatus.notDetermined, LocationAuthorization.notDetermined),
        (.denied, .denied),
        (.restricted, .denied),
        (.authorizedWhenInUse, .authorized),
        (.authorizedAlways, .authorized)
    ])
    func mapsSystemStatus(status: CLAuthorizationStatus, expected: LocationAuthorization) {
        #expect(LocationAuthorization(status) == expected)
    }
}
