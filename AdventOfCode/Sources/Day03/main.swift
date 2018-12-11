import Foundation
import Utilities

let SquareRegex = try! NSRegularExpression(pattern: "#(\\d+) @ (\\d+),(\\d+): (\\d+)x(\\d+)")

struct Square {
    let id: String
    let x: Int
    let y: Int
    let width: Int
    let height: Int
    
    var xRange: Range<Int> {
        return x ..< (x + width)
    }
    
    var yRange: Range<Int> {
        return y ..< (y + height)
    }
    
    init(line: String) {
        // #1 @ 1,3: 4x4
        let matches = SquareRegex.firstMatch(in: line, options: [], range: NSRange(location: 0, length: line.count))!
        
        let idRange = Range(matches.range(at: 1), in: line)!
        id = String(line[idRange])
        
        let xRange = Range(matches.range(at: 2), in: line)!
        x = Int(line[xRange])!
        
        let yRange = Range(matches.range(at: 3), in: line)!
        y = Int(line[yRange])!
        
        let widthRange = Range(matches.range(at: 4), in: line)!
        width = Int(line[widthRange])!
        
        let heightRange = Range(matches.range(at: 5), in: line)!
        height = Int(line[heightRange])!
    }
}

extension Square: CustomStringConvertible {
    var description: String {
        return "#\(id) @ \(x),\(y): \(width)x\(height)"
    }
}

class Fabric {
    private var squares: [Square]

    private var width: Int
    private var height: Int
    
    private var cachedFabric: [[Int]]? = nil

    init() {
        squares = []

        width = 0
        height = 0
    }

    func add(square: Square) {
        squares.append(square)

        let width = square.x + square.width + 1
        let height = square.y + square.height + 1

        if self.width < width {
            self.width = width
        }

        if self.height < height {
            self.height = height
        }
    }
    
    private func fillInFabric() -> [[Int]] {
        if let fabric = cachedFabric {
            return fabric
        }
        
        let row = Array<Int>(repeating: 0, count: width)
        var rows = Array<Array<Int>>(repeating: row, count: height)
        
        for square in squares {
            for x in square.xRange {
                for y in square.yRange {
                    rows[y][x] += 1
                }
            }
        }
        
        cachedFabric = rows
        return cachedFabric!
    }
    
    func determineClean() -> [Square] {
        let rows = fillInFabric()
        
        return squares.filter { (square) in
            for x in square.xRange {
                for y in square.yRange {
                    if rows[y][x] > 1 {
                        return false
                    } else if rows[y][x] == 1 {
                        continue
                    } else {
                        fatalError("How is this not > 0?")
                    }
                }
            }
            
            return true
        }
    }
    
    func determineUsed() -> Int {
        let rows = fillInFabric()
        
        var count = 0
        for row in rows {
            for x in row {
                if x > 1 {
                    count += 1
                }
            }
        }
        
        return count
    }
}

let fabric = Fabric()

let stdin = FileHandle.standardInput
let reader = LineReader(handle: stdin)

for line in reader {
    let square = Square(line: line)
    print("\(square)")
    
    fabric.add(square: square)
}

let result = fabric.determineUsed()
print("Used: \(result)")

let cleanSquares = fabric.determineClean()
print("Clean: \(cleanSquares)")
