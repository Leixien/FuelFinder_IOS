import CoreLocation

enum LocationAuthorization: Sendable, Equatable {
    case notDetermined
    case denied
    /// Reduced accuracy counts as authorized: a 5–25 km search still works with it.
    case authorized

    init(_ status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined: self = .notDetermined
        case .authorizedWhenInUse, .authorizedAlways: self = .authorized
        default: self = .denied
        }
    }
}

enum LocationUpdate: Sendable {
    case authorization(LocationAuthorization)
    case location(CLLocationCoordinate2D)
}

/// Two real implementations: the device (`LocationService`) and a fixed point for UI tests and previews.
@MainActor
protocol LocationProviding: AnyObject {
    var authorization: LocationAuthorization { get }
    func requestAuthorization()
    /// Yields the current authorization, then every change and every new location, until cancelled.
    func updates() -> AsyncStream<LocationUpdate>
}

@MainActor
final class LocationService: NSObject, LocationProviding {
    private let manager = CLLocationManager()
    private var continuations: [UUID: AsyncStream<LocationUpdate>.Continuation] = [:]

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        // The spec's recompute threshold: no new list for every GPS fix.
        manager.distanceFilter = 200
    }

    var authorization: LocationAuthorization {
        LocationAuthorization(manager.authorizationStatus)
    }

    func requestAuthorization() {
        manager.requestWhenInUseAuthorization()
    }

    func updates() -> AsyncStream<LocationUpdate> {
        AsyncStream { continuation in
            let id = UUID()
            continuations[id] = continuation
            continuation.onTermination = { [weak self] _ in
                Task { @MainActor in self?.remove(id) }
            }
            continuation.yield(.authorization(authorization))
            if let coordinate = manager.location?.coordinate {
                continuation.yield(.location(coordinate))
            }
            if authorization == .authorized {
                manager.startUpdatingLocation()
            }
        }
    }

    private func remove(_ id: UUID) {
        continuations[id] = nil
        if continuations.isEmpty {
            manager.stopUpdatingLocation()
        }
    }

    private func broadcast(_ update: LocationUpdate) {
        for continuation in continuations.values {
            continuation.yield(update)
        }
    }
}

extension LocationService: CLLocationManagerDelegate {
    /// The manager is created on the main actor, so CoreLocation calls back on the main thread.
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let authorization = LocationAuthorization(manager.authorizationStatus)
        MainActor.assumeIsolated {
            broadcast(.authorization(authorization))
            if authorization == .authorized, !continuations.isEmpty {
                self.manager.startUpdatingLocation()
            }
        }
    }

    nonisolated func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let coordinate = locations.last?.coordinate else { return }
        MainActor.assumeIsolated {
            broadcast(.location(coordinate))
        }
    }

    nonisolated func locationManager(_: CLLocationManager, didFailWithError _: any Error) {
        // Transient (e.g. no fix indoors): CoreLocation keeps trying, the UI stays on "locating".
    }
}

@MainActor
final class FixedLocation: LocationProviding {
    let coordinate: CLLocationCoordinate2D

    init(_ coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }

    var authorization: LocationAuthorization {
        .authorized
    }

    func requestAuthorization() {}

    func updates() -> AsyncStream<LocationUpdate> {
        AsyncStream { continuation in
            continuation.yield(.authorization(.authorized))
            continuation.yield(.location(coordinate))
        }
    }
}
