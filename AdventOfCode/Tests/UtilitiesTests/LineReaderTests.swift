import XCTest
@testable import Utilities

final class LineReaderTests: XCTestCase {
    
    var url: URL!
    
    override func setUp() {
        let tempPath = NSTemporaryDirectory()
        let tempURL = NSURL(fileURLWithPath: tempPath)
        
        let fileName = "line_reader.txt"
        url = tempURL.appendingPathComponent(fileName)
    }
    
    override func tearDown() {
        try? FileManager.default.removeItem(at: url)
    }
    
    func testLineParsing() {
        let input = "One\nTwo\nThree\nFour"
        try! input.data(using: .utf8)!.write(to: url)
        
        let readHandle = try! FileHandle(forReadingFrom: url)
        defer { readHandle.closeFile() }
        
        let lineReader = LineReader(handle: readHandle)
        
        let line1 = lineReader.readLine()!
        XCTAssertEqual(line1, "One")
        
        let line2 = lineReader.readLine()!
        XCTAssertEqual(line2, "Two")
        
        let line3 = lineReader.readLine()!
        XCTAssertEqual(line3, "Three")
        
        let line4 = lineReader.readLine()!
        XCTAssertEqual(line4, "Four")
        
        let line5 = lineReader.readLine()
        XCTAssertNil(line5)
    }
    
    func testLongLineParsing() {
        let input = "A super long line: Morbi et elit eu augue dictum bibendum in eu nisi. In at felis eget lorem mollis viverra nec at metus. Curabitur venenatis, odio id sodales iaculis, eros dui maximus mi, vitae eleifend ipsum ante quis massa. Aenean quam ante, viverra at ante in, vestibulum venenatis justo. In pharetra justo justo, at faucibus sem viverra ac. Suspendisse potenti. Vivamus consectetur semper ligula, sit amet interdum metus vehicula a. Ut quis imperdiet tellus. Morbi sagittis sapien non dolor laoreet pulvinar. In hac habitasse platea dictumst. Sed sit amet lacus molestie, dapibus tellus in, gravida turpis. Duis a quam at massa tristique tincidunt. Donec mattis aliquet magna eget euismod. Aliquam efficitur et ante id venenatis. Integer pellentesque cursus mi, vel sollicitudin ante pretium a. Nunc libero metus, tristique at ex sit amet, sagittis varius quam. Morbi et elit eu augue dictum bibendum in eu nisi. In at felis eget lorem mollis viverra nec at metus. Curabitur venenatis, odio id sodales iaculis, eros dui maximus mi, vitae eleifend ipsum ante quis massa. Aenean quam ante, viverra at ante in, vestibulum venenatis justo. In pharetra justo justo, at faucibus sem viverra ac. Suspendisse potenti. Vivamus consectetur semper ligula, sit amet interdum metus vehicula a. Ut quis imperdiet tellus. Morbi sagittis sapien non dolor laoreet pulvinar. In hac habitasse platea dictumst. Sed sit amet lacus molestie, dapibus tellus in, gravida turpis. Duis a quam at massa tristique tincidunt. Donec mattis aliquet magna eget euismod. Aliquam efficitur et ante id venenatis. Integer pellentesque cursus mi, vel sollicitudin ante pretium a. Nunc libero metus, tristique at ex sit amet, sagittis varius quam. Morbi et elit eu augue dictum bibendum in eu nisi. In at felis eget lorem mollis viverra nec at metus. Curabitur venenatis, odio id sodales iaculis, eros dui maximus mi, vitae eleifend ipsum ante quis massa. Aenean quam ante, viverra at ante in, vestibulum venenatis justo. In pharetra justo justo, at faucibus sem viverra ac. Suspendisse potenti. Vivamus consectetur semper ligula, sit amet interdum metus vehicula a. Ut quis imperdiet tellus. Morbi sagittis sapien non dolor laoreet pulvinar. In hac habitasse platea dictumst. Sed sit amet lacus molestie, dapibus tellus in, gravida turpis. Duis a quam at massa tristique tincidunt. Donec mattis aliquet magna eget euismod. Aliquam efficitur et ante id venenatis. Integer pellentesque cursus mi, vel sollicitudin ante pretium a. Nunc libero metus, tristique at ex sit amet, sagittis varius quam."
        try! input.data(using: .utf8)!.write(to: url)
        
        let readHandle = try! FileHandle(forReadingFrom: url)
        defer { readHandle.closeFile() }
        
        let lineReader = LineReader(handle: readHandle)
        
        let line = lineReader.readLine()!
        XCTAssertEqual(line, input)
    }
    
    func testSequence() {
        let input = "One\nTwo\nThree\nFour"
        try! input.data(using: .utf8)!.write(to: url)
        
        let readHandle = try! FileHandle(forReadingFrom: url)
        defer { readHandle.closeFile() }
        
        let lineReader = LineReader(handle: readHandle)
        
        for (idx, line) in lineReader.enumerated() {
            switch idx {
            case 0:
                XCTAssertEqual(line, "One")
            case 1:
                XCTAssertEqual(line, "Two")
            case 2:
                XCTAssertEqual(line, "Three")
            case 3:
                XCTAssertEqual(line, "Four")
            default:
                XCTFail("Should not have a line for index \(idx)")
            }
        }
    }
    
    static var allTests = [
        ("testLineParsing", testLineParsing),
        ("testLongLineParsing", testLongLineParsing),
        ("testSequence", testSequence)
    ]
}
