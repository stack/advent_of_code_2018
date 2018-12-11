import Foundation
import Utilities
import simd

let SaneWidth = 256
let SaneHeight = 50

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

struct Bounds {
    var min: int2
    var max: int2
    var dimensions: int2
    
    init(points: [Point]) {
        var minX = Int32.max
        var minY = Int32.max
        var maxX = Int32.min
        var maxY = Int32.min
        
        for point in points {
            if point.position.x < minX {
                minX = point.position.x
            }
            
            if point.position.y < minY {
                minY = point.position.y
            }
            
            if point.position.x > maxX {
                maxX = point.position.x
            }
            
            if point.position.y > maxY {
                maxY = point.position.y
            }
        }
        
        min = int2(minX, minY)
        max = int2(maxX, maxY)
        dimensions = (max &- min) &+ int2(1, 1)
    }
}

extension Bounds: CustomStringConvertible {
    var description: String {
        return "(\(min.x), \(min.y)) <-> (\(max.x), \(max.y)) = (\(dimensions.x), \(dimensions.y))"
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

print()

// Start converging the vectors in to a same bounds
let initialBounds = Bounds(points: points)
print("Initial bounds: \(initialBounds)")

var currentPoints = points
var currentBounds = initialBounds
var currentStep = 0

while currentBounds.dimensions.x > SaneWidth && currentBounds.dimensions.y > SaneHeight {
    print("Converge \(currentStep): \(currentBounds)")
    
    currentPoints = currentPoints.map { $0.step() }
    currentBounds = Bounds(points: currentPoints)
    currentStep += 1
}

var convergedBounds = currentBounds
print("Picked \(currentStep) as sane: \(convergedBounds)")

// Start the inspection at this point
let squareSize: CGFloat = 3.0
let canvasWidth = Int(convergedBounds.dimensions.x) * Int(squareSize)
let canvasHeight = Int(convergedBounds.dimensions.y) * Int(squareSize)

let animator = Animator(name: "10-message", width: canvasWidth, height: canvasHeight, rate: "10")

var previousBounds = currentBounds

while currentBounds.dimensions.x <= previousBounds.dimensions.x && currentBounds.dimensions.y <= previousBounds.dimensions.y {
    print("Draw \(currentStep): \(currentBounds)")
    
    animator.draw { (ctx, canvas) in
        canvas.blank()
        canvas.invert()
        
        let colorGenerator = ColorGenerator(maxColors: currentPoints.count, saturationValue: 1.0)
        
        for point in currentPoints {
            let x = CGFloat(point.position.x - convergedBounds.min.x) * squareSize
            let y = CGFloat(point.position.y - convergedBounds.min.y) * squareSize
            
            let rect = CGRect(x: x, y: y, width: squareSize, height: squareSize)
            let color = colorGenerator.makeNextColor()
            
            ctx.setFillColor(color)
            ctx.fill(rect)
        }
    }
    
    animator.snap()
    
    // Advance!
    previousBounds = currentBounds
    
    currentPoints = currentPoints.map { $0.step() }
    currentBounds = Bounds(points: currentPoints)
    currentStep += 1
}

currentStep -= 1

// Extra snaps, just to make the video look better
for _ in 0 ..< 5 {
    animator.snap()
}

animator.finalize()
animator.cleanup()

print("Final step: \(currentStep)")
