import Foundation
import LineReader

struct Point {
    let id: Int
    let x: Int
    let y: Int
    
    static func - (lhs: Point, rhs: Point) -> Int {
        return abs(lhs.x - rhs.x) + abs(lhs.y - rhs.y)
    }
}

extension Point: CustomStringConvertible {
    var description: String {
        return "\(id): (\(x), \(y))"
    }
}

// Get the input
let stdin = FileHandle.standardInput
let reader = LineReader(handle: stdin)

let regex = try! NSRegularExpression(pattern: "(\\d+).+(\\d+)", options: [])
let points = reader.enumerated().map { (idx, line) -> Point in
    guard let match = regex.firstMatch(in: line, options: [], range: NSRange(location: 0, length: line.count)) else {
        fatalError("Invalid input")
    }
    
    let xRange = Range(match.range(at: 1), in: line)!
    let x = Int(line[xRange])!
    
    let yRange = Range(match.range(at: 2), in: line)!
    let y = Int(line[yRange])!
    
    return Point(id: idx, x: x, y: y)
}

print("Points: \(points)")

// Determine the bounds of the points
var minX = Int.max
var minY = Int.max
var maxX = Int.min
var maxY = Int.min

for point in points {
    if point.x < minX {
        minX = point.x
    }
    
    if point.y < minY {
        minY = point.y
    }
    
    if point.x > maxX {
        maxX = point.x
    }
    
    if point.y > maxY {
        maxY = point.y
    }
}

// Increment to allow one row of space
minX -= 1
minY -= 1
maxX += 1
maxY += 1

let width = (maxX - minX) + 1
let height = (maxY - minY) + 1

print("Bounds: \(minX), \(minY) - \(maxX), \(maxY) - \(width)x\(height) ")

// Build a box of coordinates
var box: [[Int]] = [[Int]]()

for boxY in 0 ..< height {
    var row = [Int](repeating: -1, count: width)
    
    for boxX in 0 ..< width {
        // Determine the point the box coordinates actually represent
        let boxPoint = Point(id: Int.min, x: boxX - minX, y: boxY - minY)
        
        // Find the closest points to this coordinate
        var closestDistance = Int.max
        var closestPoints: [Point] = []
        
        for point in points {
            let distance = point - boxPoint
            
            if distance < closestDistance {
                closestPoints = [point]
                closestDistance = distance
            } else if distance == closestDistance {
                closestPoints.append(point)
            }
        }
        
        // If there's one closest, store it, otherwise leave the point empty
        if closestPoints.count == 1 {
            row[boxX] = closestPoints[0].id
        }
    }
    
    box.append(row)
}

func printBox(_ box: [[Int]]) {
    for row in box {
        let values = row.map { (value) -> String in
            if value == -1 {
                return ".."
            } else {
                return String(value).padding(toLength: 2, withPad: " ", startingAt: 0)
            }
        }
        
        print("\(values.joined())")
    }
}

printBox(box)
