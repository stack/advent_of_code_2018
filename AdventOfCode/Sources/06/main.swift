import Canvas
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

class ColorGenerator {
    let maxColors: CGFloat
    let stepFactor: CGFloat
    var currentHue: CGFloat
    
    init(maxColors: Int) {
        self.maxColors = CGFloat(maxColors)
        stepFactor = 360.0 / CGFloat(maxColors)
        currentHue = 0.0
    }
    
    func makeNextColor() -> CGColor {
        // Get the next HSV values
        let s: CGFloat = 1.0
        let v: CGFloat = 1.0
        let h = currentHue
        
        // Increment the hue
        currentHue = (currentHue + stepFactor).truncatingRemainder(dividingBy: 360.0)
        
        // Conver to RGB
        let c = v * s
        let x = c * (1.0 - abs((h / 60.0).truncatingRemainder(dividingBy: 2.0) - 1.0))
        let m = v - c
        
        var r, g, b: CGFloat
        if h >= 0.0 && h < 60.0 {
            r = c
            g = x
            b = 0.0
        } else if h >= 0.0 && h < 120.0 {
            r = x
            g = c
            b = 0.0
        } else if h >= 120.0 && h < 180.0 {
            r = 0.0
            g = c
            b = x
        } else if h >= 180.0 && h < 240.0 {
            r = 0.0
            g = x
            b = c
        } else if h >= 240.0 && h < 300.0 {
            r = x
            g = 0.0
            b = c
        } else {
            r = c
            g = 0.0
            b = x
        }
        
        r += m
        g += m
        b += m
        
        // Build the color
        return CGColor(red: r, green: g, blue: b, alpha: 1.0)
    }
}

// Get the input
let stdin = FileHandle.standardInput
let reader = LineReader(handle: stdin)

let regex = try! NSRegularExpression(pattern: "(\\d+), (\\d+)", options: [])
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

let width = maxX + 1
let height = maxY + 1

print("Bounds: \(minX) \(minY), \(maxX), \(maxY) - \(width)x\(height) ")

// Build a box of coordinates
var box: [[Int]] = [[Int]]()

for boxY in 0 ..< height {
    var row = [Int](repeating: -1, count: width)
    
    for boxX in 0 ..< width {
        // Determine the point the box coordinates actually represent
        let boxPoint = Point(id: Int.min, x: boxX, y: boxY)
        
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
                return " . "
            } else {
                var id = String(value)
                while id.count < 2 {
                    id = " " + id
                }
                
                return id + " "
            }
        }
        
        print("\(values.joined())")
    }
}

print()
printBox(box)
print()

// Determine which IDs are infinite
var inifinites: Set<Int> = []

inifinites.formUnion(box.first!)
inifinites.formUnion(box.last!)

for row in box {
    inifinites.insert(row.first!)
    inifinites.insert(row.last!)
}

print("Infinites: \(inifinites)")

// Calculate the greatest area
var areas: [Int:Int] = [:]

for row in box {
    for value in row {
        guard !inifinites.contains(value) else {
            continue
        }
        
        let newArea: Int
        
        if let area = areas[value] {
            newArea = area + 1
        } else {
            newArea = 1
        }
        
        areas[value] = newArea
    }
}

print("Areas: \(areas)")

let (maxKey, maxValue) = areas.max { (lhs, rhs) -> Bool in
    return lhs.value < rhs.value
}!

print("Max area: \(maxKey) = \(maxValue)")

// Part 2: Just iterate the points, finding the safe distance
let safeDistance = (points.count == 6) ? 32 : 10000
var safePoints: [Point] = []

print("Safe distance: \(safeDistance)")

for x in (minX) ... (maxX) {
    for y in (minY) ... (maxY) {
        let currentPoint = Point(id: -1, x: x, y: y)
        let totalDistance = points.reduce(0) { $0 + ($1 - currentPoint) }
        
        if totalDistance < safeDistance {
            safePoints.append(currentPoint)
        }
    }
}

print("Safe points: \(safePoints.count)")

// Drawing: Part 1
let squareSize: CGFloat = 16.0
let canvasWidth = Int(squareSize * CGFloat(width))
let canvasHeight = Int(squareSize * CGFloat(height))

let colorGenerator = ColorGenerator(maxColors: points.count)
let colors = box.map { (_) -> CGColor in colorGenerator.makeNextColor() }
let blankColor = CGColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)

let canvas = Canvas(width: canvasWidth, height: canvasHeight)
canvas.draw { (ctx) in
    for (y, row) in box.enumerated() {
        for (x, value) in row.enumerated() {
            let rect = CGRect(x: CGFloat(x) * squareSize, y: CGFloat(y) * squareSize, width: squareSize, height: squareSize)
            
            let color = (value == -1) ? blankColor : colors[value]
            
            ctx.addRect(rect)
            ctx.setFillColor(color)
            ctx.fillPath()
        }
    }
    
    for point in points {
        let rect = CGRect(x: CGFloat(point.x) * squareSize, y: CGFloat(point.y) * squareSize, width: squareSize, height: squareSize)
        let color = CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        ctx.addRect(rect)
        ctx.setFillColor(color)
        ctx.fillPath()
    }
}

canvas.save(path: "./06-part-1.png")
