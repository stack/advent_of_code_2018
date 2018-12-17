import XCTest
@testable import Utilities

final class PriorityQueueTests: XCTestCase {
    
    override func setUp() {
    }
    
    override func tearDown() {
    }
    
    func testEmptiness() {
        var queue = PriorityQueue<Int>()
        XCTAssertTrue(queue.isEmpty)
        
        queue.push(1, priority: 1)
        XCTAssertFalse(queue.isEmpty)
        
        let _ = queue.pop()
        XCTAssertTrue(queue.isEmpty)
    }
    
    func testSequentialInput() {
        var queue = PriorityQueue<Int>()
        
        queue.push(1, priority: 1)
        queue.push(2, priority: 2)
        queue.push(3, priority: 3)
        
        var value = queue.pop()
        XCTAssertNotNil(value)
        XCTAssertEqual(value, 1)
        
        value = queue.pop()
        XCTAssertNotNil(value)
        XCTAssertEqual(value, 2)
        
        value = queue.pop()
        XCTAssertNotNil(value)
        XCTAssertEqual(value, 3)
        
        value = queue.pop()
        XCTAssertNil(value)
    }
    
    func testReverseInput() {
        var queue = PriorityQueue<Int>()
        
        queue.push(1, priority: 3)
        queue.push(2, priority: 2)
        queue.push(3, priority: 1)
        
        var value = queue.pop()
        XCTAssertNotNil(value)
        XCTAssertEqual(value, 3)
        
        value = queue.pop()
        XCTAssertNotNil(value)
        XCTAssertEqual(value, 2)
        
        value = queue.pop()
        XCTAssertNotNil(value)
        XCTAssertEqual(value, 1)
        
        value = queue.pop()
        XCTAssertNil(value)
    }
    
    func testMixedInput() {
        var queue = PriorityQueue<Int>()
        
        queue.push(1, priority: 1)
        queue.push(2, priority: 3)
        queue.push(3, priority: 2)
        queue.push(4, priority: 2)
        
        var value = queue.pop()
        XCTAssertNotNil(value)
        XCTAssertEqual(value, 1)
        
        value = queue.pop()
        XCTAssertNotNil(value)
        XCTAssertEqual(value, 3)
        
        value = queue.pop()
        XCTAssertNotNil(value)
        XCTAssertEqual(value, 4)
        
        value = queue.pop()
        XCTAssertNotNil(value)
        XCTAssertEqual(value, 2)
        
        value = queue.pop()
        XCTAssertNil(value)
    }
    
    func testSamePrioritiesInOrder() {
        var queue = PriorityQueue<Int>()
        
        queue.push(1, priority: 2)
        queue.push(2, priority: 2)
        queue.push(3, priority: 2)
        queue.push(4, priority: 2)
        
        var value = queue.pop()
        XCTAssertNotNil(value)
        XCTAssertEqual(value, 1)
        
        value = queue.pop()
        XCTAssertNotNil(value)
        XCTAssertEqual(value, 2)
        
        value = queue.pop()
        XCTAssertNotNil(value)
        XCTAssertEqual(value, 3)
        
        value = queue.pop()
        XCTAssertNotNil(value)
        XCTAssertEqual(value, 4)
        
        value = queue.pop()
        XCTAssertNil(value)
    }
}
