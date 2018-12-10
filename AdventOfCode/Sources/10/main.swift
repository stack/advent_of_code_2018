import Foundation
import Utilities
import simd

struct Point {
    let id: Int
    let position: int2
    let vector: int2
    
    init(id: Int, position: int2, vector: int2) {
        self.id = id
        self.position = position
        self.vector = vector
    }
    
    init(id: Int, px: Int, py: Int, vx: Int, vy: Int) {
        self.id = id
        position = int2(Int32(px), Int32(py))
        vector = int2(Int32(vx), Int32(vy))
    }
    
    func step() -> Point {
        let nextPosition = position &+ vector
        return Point(id: id, position: nextPosition, vector: vector)
    }
}

extension Point: CustomStringConvertible {
    var description: String {
        let positionString = String(format: "%6d, %6d", position.x, position.y)
        let vectorString = String(format: "%6d, %6d", vector.x, vector.y)
        
        return "\(id): position=<\(positionString)> vector=<\(vectorString)>"
    }
}

// Get the input in to points
let regex = try! NSRegularExpression(pattern: "position=<\\s*(-?\\d+),\\s*(-?\\d+)> velocity=<\\s*(-?\\d+),\\s*(-?\\d+)>", options: [])
let reader = LineReader(handle: FileHandle.standardInput)
let points = reader.enumerated().map { (idx, line) -> Point in
    guard let match = regex.firstMatch(in: line, options: [], range: NSRange(location: 0, length: line.count)) else {
        fatalError("Could not match line: \(line)")
    }
    
    let pxRange = Range(match.range(at: 1), in: line)!
    let px = Int(line[pxRange])!
    
    let pyRange = Range(match.range(at: 2), in: line)!
    let py = Int(line[pyRange])!
    
    let vxRange = Range(match.range(at: 3), in: line)!
    let vx = Int(line[vxRange])!
    
    let vyRange = Range(match.range(at: 4), in: line)!
    let vy = Int(line[vyRange])!
    
    return Point(id: idx, px: px, py: py, vx: vx, vy: vy)
}

// Debug input
for point in points {
    print("- \(point)")
}
