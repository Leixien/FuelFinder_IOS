import Foundation
import Testing

struct AppConfigurationTests {
    @Test func dataURLIsWiredFromXcconfig() throws {
        let raw = try #require(Bundle.main.object(forInfoDictionaryKey: "DataURL") as? String)
        let url = try #require(URL(string: raw))
        #expect(url.scheme == "https")
        #expect(url.host() != nil)
    }
}
