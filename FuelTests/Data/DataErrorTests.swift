@testable import Fuel
import Testing

struct DataErrorTests {
    @Test(arguments: [DataError.network, .httpStatus(503), .decoding, .unsupportedSchema(2)])
    func hasUserFacingMessage(error: DataError) throws {
        let message = try #require(error.errorDescription)
        #expect(!message.isEmpty)
    }

    @Test func httpStatusMessageIncludesCode() {
        #expect(DataError.httpStatus(503).errorDescription?.contains("503") == true)
    }
}
