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
    let id: Int
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

extension Cart: Equatable {
    static func == (lhs: Cart, rhs: Cart) -> Bool {
        return lhs.id == rhs.id
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

// Read the input
let reader = LineReader(handle: FileHandle.standardInput)

var track: [[Space]] = []
var carts: [Cart] = []
var nextID = 0

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
            carts.append(Cart(id: nextID, x: x, y: y, direction: .north, turns: 0))
            nextID += 1
        case "v":
            track[y][x] = .straightNS
            carts.append(Cart(id: nextID, x: x, y: y, direction: .south, turns: 0))
            nextID += 1
        case "<":
            track[y][x] = .straightEW
            carts.append(Cart(id: nextID, x: x, y: y, direction: .west, turns: 0))
            nextID += 1
        case ">":
            track[y][x] = .straightEW
            carts.append(Cart(id: nextID, x: x, y: y, direction: .east, turns: 0))
            nextID += 1
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
            if x > 0 && (track[y][x - 1] == .straightEW || track[y][x - 1] == .intersection) {
                track[y][x] = .curveSW
            } else {
                track[y][x] = .curveNE
            }
        } else if value == .curveRight { // "/"
            if x > 0 && (track[y][x - 1] == .straightEW || track[y][x - 1] == .intersection) {
                track[y][x] = .curveNW
            } else {
                track[y][x] = .curveSE
            }
        }
    }
}

class Course {
    let spaces: [[Space]]
    let carts: [Cart]
    var printRuns: Bool
    
    init(spaces: [[Space]], carts: [Cart], printRuns: Bool = false) {
        self.spaces = spaces
        self.carts = carts
        self.printRuns = printRuns
    }
    
    func firstCollision() -> (x: Int, y: Int) {
        var run = 0
        var currentCarts = carts
        
        while true {
            if printRuns {
                print("Run: \(run)")
                printTrack(carts: currentCarts)
                print()
            }
            
            // Sort the carts and move them, looking for the first collision
            currentCarts.sort()
            
            for idx in 0 ..< currentCarts.count {
                currentCarts[idx] = moveCart(cart: currentCarts[idx])
                
                for collisionIdx in 0 ..< currentCarts.count - 1 {
                    let lhs = currentCarts[collisionIdx]
                    let rhs = currentCarts[collisionIdx + 1]
                    
                    if lhs.x == rhs.x && lhs.y == rhs.y {
                        return (x: lhs.x, y: lhs.y)
                    }
                }
            }
            
            run += 1
        }
    }
    
    func lastCart() -> (x: Int, y: Int) {
        var run = 0
        var currentCarts = carts
        
        while true {
            if printRuns {
                print("Run: \(run)")
                printTrack(carts: currentCarts)
                print()
            }
            
            // Sort the carts, move them, and pop off the collisions
            currentCarts.sort()
            
            var removedIDs: Set<Int> = []
            
            for idx in 0 ..< currentCarts.count {
                // Is this cart already removed?
                if removedIDs.contains(currentCarts[idx].id) {
                    continue
                }
                
                // Move the cart
                currentCarts[idx] = moveCart(cart: currentCarts[idx])
                
                // Did we have collisions?
                for collisionCart in currentCarts {
                    if collisionCart == currentCarts[idx] {
                        continue
                    }
                    
                    if collisionCart.x == currentCarts[idx].x && collisionCart.y == currentCarts[idx].y {
                        removedIDs.insert(currentCarts[idx].id)
                        removedIDs.insert(collisionCart.id)
                    }
                }
            }
            
            // Remove the collided carts
            currentCarts.removeAll(where: { removedIDs.contains($0.id) })
            
            // Did we finish?
            if currentCarts.count == 1 {
                return (x: currentCarts[0].x, y: currentCarts[0].y)
            }
            
            run += 1
        }
    }
    
    private func moveCart(cart: Cart) -> Cart {
        // Store the next position
        var nextX = cart.x
        var nextY = cart.y
        var nextDirection = cart.direction
        var nextTurns = cart.turns
        
        // Advance the cart
        switch cart.direction {
        case .north:
            nextY -= 1
        case .south:
            nextY += 1
        case .east:
            nextX += 1
        case .west:
            nextX -= 1
        }
        
        // Rotate if needed
        switch track[nextY][nextX] {
        case .straightNS, .straightEW:
        break // No turn on straights
        case .curveRight, .curveLeft:
            fatalError("Cannot turn on an undefined curve")
        case .curveSE: // "/"
            switch cart.direction {
            case .north:
                nextDirection = .east
            case .west:
                nextDirection = .south
            default:
                fatalError("Invalid direction \(cart.direction) on curve SE @ \(nextX), \(nextY)")
            }
        case .curveSW: // "\"
            switch cart.direction {
            case .north:
                nextDirection = .west
            case .east:
                nextDirection = .south
            default:
                fatalError("Invalid direction \(cart.direction) on curve SW @ \(nextX), \(nextY)")
            }
        case .curveNE: // "\"
            switch cart.direction {
            case .south:
                nextDirection = .east
            case .west:
                nextDirection = .north
            default:
                fatalError("Invalid direction \(cart.direction) on curve NE @ \(nextX), \(nextY)")
            }
        case .curveNW: // "/"
            switch cart.direction {
            case .south:
                nextDirection = .west
            case .east:
                nextDirection = .north
            default:
                fatalError("Invalid direction \(cart.direction) on curve NW @ \(nextX), \(nextY)")
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
                fatalError("Invalid number of turns: \(cart.turns) -> \(cart.turns % 3)")
            }
            
            nextTurns += 1
        case .blank:
            fatalError("Cannot turn on a blank")
        }
        
        return Cart(id: cart.id, x: nextX, y: nextY, direction: nextDirection, turns: nextTurns)
    }
    
    private func printTrack(carts: [Cart]) {
        for (y, row) in spaces.enumerated() {
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
}

let course = Course(spaces: track, carts: carts)
let firstCollision = course.firstCollision()

print("First collision: \(firstCollision)")

let lastCart = course.lastCart()

print("Last cart: \(lastCart)")
