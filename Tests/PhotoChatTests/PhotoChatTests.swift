import XCTest
import OSLog
import Foundation
@testable import PhotoChat

let logger: Logger = Logger(subsystem: "PhotoChat", category: "Tests")

@available(macOS 13, *)
final class PhotoChatTests: XCTestCase {
    func testPhotoChat() throws {
        logger.log("running testPhotoChat")
        XCTAssertEqual(1 + 2, 3, "basic test")
        
        // load the TestData.json file from the Resources folder and decode it into a struct
        let resourceURL: URL = try XCTUnwrap(Bundle.module.url(forResource: "TestData", withExtension: "json"))
        let testData = try JSONDecoder().decode(TestData.self, from: Data(contentsOf: resourceURL))
        XCTAssertEqual("PhotoChat", testData.testModuleName)
    }
}

struct TestData : Codable, Hashable {
    var testModuleName: String
}
