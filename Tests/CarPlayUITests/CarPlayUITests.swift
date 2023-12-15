import Foundation
import XCTest
import CarPlay
@testable import CarPlayUI

final class CarPlayUITests: XCTestCase {
    
    func testInsertBefore() throws {
        
        let values: [(String, Int, [String], [String])] = [
            ("New Item", 0, ["1", "2", "3"], ["New Item", "1", "2", "3"]),
            ("New Item", 1, ["1", "2", "3"], ["1", "New Item", "2", "3"]),
            ("New Item", 2, ["1", "2", "3"], ["1", "2", "New Item", "3"])
        ]
        for (newValue, index, oldValue, expectedValue) in values {
            var result = oldValue
            result.insert(newValue, before: index)
            XCTAssertEqual(result, expectedValue)
        }
    }
}
