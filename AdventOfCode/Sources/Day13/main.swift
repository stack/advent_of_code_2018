import Foundation
import Utilities

enum Space {
    case straightNS
    case straightEW
    case curveRight
    case curveLeft
    case curveSE
    case curveSW
    case curveNE
    case curveNW
    case intersection
    case blank
}

extension Space: CustomStringConvertible {
    var description: String {
        switch self {
        case .straightNS:
            return "|"
        case .straightEW:
            return "-"
        case .curveLeft:
            fatalError("Shouldn't have curve left")
        case .curveRight:
            fatalError("Shouldn't have curve right")
        case .curveSE:
            return "/"
        case .curveSW:
            return "\\"
        case .curveNE:
            return "\\"
        case .curveNW:
            return "/"
        case .intersection:
            return "+"
        case .blank:
            return " "
        }
    }
}

enum Direction {
    case north
    case south
    case east
    case west
    
    var left: Direction {
        switch self {
        case .north:
            return .west
        case .south:
            return .east
        case .east:
            return .north
        case .west:
            return .south
        }
    }
    
    var right: Direction {
        switch self {
        case .north:
            return .east
        case .south:
            return .west
        case .east:
            return .south
        case .west:
            return .north
        }
    }
}

struct Cart {
    let x: Int
    let y: Int
    let direction: Direction
    let turns: Int
}

extension Cart: Comparable {
    static func < (lhs: Cart, rhs: Cart) -> Bool {
        if lhs.y < rhs.y {
            return true
        } else if lhs.y > rhs.y {
            return false
        } else {
            return lhs.x < rhs.x
        }
    }
}

extension Cart: CustomStringConvertible {
    var description: String {
        switch direction {
        case .north:
            return "^"
        case .south:
            return "v"
        case .east:
            return ">"
        case .west:
            return "<"
        }
    }
}

func printTrack(_ track: [[Space]], carts: [Cart]) {
    for (y, row) in track.enumerated() {
        let line = row.enumerated().map { (arg0) -> String in
            let (x, value) = arg0
            
            if let cart = carts.first(where: { $0.x == x && $0.y == y }) {
                return cart.description
            } else {
                return value.description
            }
        }.joined()
        
        print(line)
    }
}

// Read the input
let reader = LineReader(handle: FileHandle.standardInput)

var track: [[Space]] = []
var carts: [Cart] = []

for (y, line) in reader.enumerated() {
    track.append([Space](repeating: .blank, count: line.count))
    
    for (x, value) in line.enumerated() {
        switch value {
        case "/":
            track[y][x] = .curveRight
        case "\\":
            track[y][x] = .curveLeft
        case "-":
            track[y][x] = .straightEW
        case "|":
            track[y][x] = .straightNS
        case "+":
            track[y][x] = .intersection
        case "^":
            track[y][x] = .straightNS
            carts.append(Cart(x: x, y: y, direction: .north, turns: 0))
        case "v":
            track[y][x] = .straightNS
            carts.append(Cart(x: x, y: y, direction: .south, turns: 0))
        case "<":
            track[y][x] = .straightEW
            carts.append(Cart(x: x, y: y, direction: .west, turns: 0))
        case ">":
            track[y][x] = .straightEW
            carts.append(Cart(x: x, y: y, direction: .east, turns: 0))
        case " ":
            track[y][x] = .blank
        default:
            fatalError("Unhandled track piece: \(value)")
        }
    }
}

// Fix the curves
for (y, row) in track.enumerated() {
    for (x, value) in row.enumerated() {
        if value == .curveLeft { // "\"
            if x > 0 && track[y][x - 1] == .straightEW {
                track[y][x] = .curveSW
            } else {
                track[y][x] = .curveNE
            }
        } else if value == .curveRight { // "/"
            if x > 0 && track[y][x - 1] == .straightEW {
                track[y][x] = .curveNW
            } else {
                track[y][x] = .curveSE
            }
        }
    }
}

// Debug
printTrack(track, carts: carts)

// Run until there's a collision
var run = 0
var currentCarts = carts

while true {
    print("\nRun \(run)\n")
    printTrack(track, carts: currentCarts)
    
    // Sort the carts and look for a collision
    currentCarts.sort()
    
    for idx in 0 ..< (currentCarts.count - 1) {
        let lhs = currentCarts[idx]
        let rhs = currentCarts[idx + 1]
        
        if lhs.x == rhs.x && lhs.y == rhs.y {
            print("Collision at \(lhs.x), \(lhs.y) on run \(run)")
            break
        }
    }
    
    // Move the carts
    currentCarts = currentCarts.map { (cart) -> Cart in
        let trackValue = track[cart.y][cart.x]
        
        var nextX = cart.x
        var nextY = cart.y
        var nextDirection = cart.direction
        var nextTurns = cart.turns
        
        switch trackValue {
        case .curveRight, .curveLeft, .blank:
            fatalError("Unsupported track value")
        case .straightNS:
            switch cart.direction {
            case .north:
                nextY -= 1
            case .south:
                nextY += 1
            default:
                fatalError("Unsupported straight NS direction")
            }
        case .straightEW:
            switch cart.direction {
            case .east:
                nextX += 1
            case .west:
                nextX -= 1
            default:
                fatalError("Unsupported straight EW direction")
            }
        case .curveSE:
            switch cart.direction {
            case .north:
                nextX += 1
                nextDirection = .east
            case .west:
                nextY += 1
                nextDirection = .south
            default:
                fatalError("Unsupported curve SE direction")
            }
        case .curveSW:
            switch cart.direction {
            case .east:
                nextY += 1
                nextDirection = .south
            case .north:
                nextX -= 1
                nextDirection = .west
            default:
                fatalError("Unsupported curve SW direction")
            }
        case .curveNE:
            switch cart.direction {
            case .west:
                nextY -= 1
                nextDirection = .north
            case .south:
                nextX += 1
                nextDirection = .east
            default:
                fatalError("Unsupported curve NE direction")
            }
        case .curveNW:
            switch cart.direction {
            case .east:
                nextY -= 1
                nextDirection = .north
            case .south:
                nextX -= 1
                nextDirection = .west
            default:
                fatalError("Unsupported curve NW direction")
            }
        case .intersection:
            switch cart.turns % 3 {
            case 0:
                nextDirection = cart.direction.left
            case 1:
                nextDirection = cart.direction
            case 2:
                nextDirection = cart.direction.right
            default:
                fatalError("Unsupported number of turns")
            }
            
            switch nextDirection {
            case .north:
                nextY -= 1
            case .south:
                nextY += 1
            case .east:
                nextX += 1
            case .west:
                nextY += 1
            }
            
            nextTurns += 1
        }
        
        return Cart(x: nextX, y: nextY, direction: nextDirection, turns: nextTurns)
    }
    
    run += 1
}
