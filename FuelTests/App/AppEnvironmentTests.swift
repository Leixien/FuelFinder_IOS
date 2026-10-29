import Foundation
@testable import Fuel
import Testing

@MainActor
struct AppEnvironmentTests {
    @Test func uiTestEnvironmentServesFixture() async throws {
        let environment = AppEnvironment.resolve(arguments: ["-uiTesting"])

        let snapshot = try await environment.repository.refresh()

        #expect(snapshot.payload.stations.count == 30)
    }

    @Test func uiTestClockIsFrozen() {
        let environment = AppEnvironment.resolve(arguments: ["-uiTesting"])

        #expect(environment.now() == Date(timeIntervalSince1970: 1_793_188_800)) // 2026-10-28T12:00:00Z
        #expect(environment.location is FixedLocation)
    }

    @Test func liveIsTheDefault() {
        #expect(AppEnvironment.resolve(arguments: []).location is LocationService)
    }

    @Test func previewDataHasMatches() {
        #expect(!PreviewData.matches.isEmpty)
    }
}
