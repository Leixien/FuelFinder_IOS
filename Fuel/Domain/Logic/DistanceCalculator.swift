import CoreLocation

enum DistanceCalculator {
    private static let earthRadius = 6_371_000.0

    /// Great-circle distance in metres (Haversine).
    static func distance(from origin: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) -> Double {
        let lat1 = origin.latitude * .pi / 180
        let lat2 = destination.latitude * .pi / 180
        let deltaLat = lat2 - lat1
        let deltaLon = (destination.longitude - origin.longitude) * .pi / 180
        let haversine = pow(sin(deltaLat / 2), 2) + cos(lat1) * cos(lat2) * pow(sin(deltaLon / 2), 2)
        return 2 * earthRadius * asin(min(1, haversine.squareRoot()))
    }
}
