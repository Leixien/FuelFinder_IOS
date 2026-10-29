import CoreLocation
import Foundation

/// Services the app runs on, swapped wholesale for UI tests.
@MainActor
struct AppEnvironment {
    let repository: StationsRepository
    let location: any LocationProviding
    let now: @Sendable () -> Date

    static func live() -> AppEnvironment {
        guard let raw = Bundle.main.object(forInfoDictionaryKey: "DataURL") as? String, let url = URL(string: raw) else {
            fatalError("DataURL missing from Info.plist: check Config/*.xcconfig")
        }
        return AppEnvironment(
            repository: StationsRepository(dataSource: StationsDataSource(url: url), cache: FileCache()),
            location: LocationService(),
            now: { .now }
        )
    }

    static func resolve(arguments: [String] = ProcessInfo.processInfo.arguments) -> AppEnvironment {
        #if DEBUG
            if arguments.contains("-uiTesting") {
                return uiTest()
            }
        #endif
        return live()
    }

    #if DEBUG
        /// Fixture data, a fixed spot in Naples and a frozen clock: the fixture's prices would otherwise
        /// all turn older than 7 days a week after it was recorded, leaving the cheapest card empty.
        static func uiTest() -> AppEnvironment {
            let data = PreviewData.fixtureData
            let source = StationsDataSource(url: URL(filePath: "/fixture.json")) { request in
                // swiftlint:disable:next force_unwrapping
                (data, HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!)
            }
            let cache = FileCache(directory: .temporaryDirectory.appending(path: UUID().uuidString))
            return AppEnvironment(
                repository: StationsRepository(dataSource: source, cache: cache),
                location: FixedLocation(PreviewData.origin),
                now: { PreviewData.now }
            )
        }
    #endif
}
