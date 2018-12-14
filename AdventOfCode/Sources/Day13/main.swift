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
    var drawRuns: Bool
    
    init(spaces: [[Space]], carts: [Cart], printRuns: Bool = false, drawRuns: Bool = false) {
        self.spaces = spaces
        self.carts = carts
        self.printRuns = printRuns
        self.drawRuns = drawRuns
    }
    
    private func drawBackground(ctx: CGContext, canvas: Canvas, squareSize: CGFloat) {
        canvas.invert()
        
        let backgroundColor = CGColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        let trackColor = CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        let intersectionColor = CGColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        
        for (y, row) in spaces.enumerated() {
            for (x, value) in row.enumerated() {
                let rect = CGRect(x: CGFloat(x) * squareSize, y: CGFloat(y) * squareSize, width: squareSize, height: squareSize)
                
                ctx.saveGState()
                
                ctx.setFillColor(backgroundColor)
                ctx.fill(rect)
                
                switch value {
                case .blank:
                    ctx.setFillColor(backgroundColor)
                    ctx.fill(rect)
                case .curveLeft, .curveRight:
                    fatalError("Cannot draw incomplete curve")
                case .curveNE:
                    let point = CGPoint(x: rect.maxX, y: rect.minY)
                    
                    ctx.beginPath()
                    ctx.addArc(center: point, radius: squareSize, startAngle: .pi / 2.0, endAngle: .pi, clockwise: false)
                    ctx.addLine(to: point)
                    ctx.closePath()
                    
                    ctx.setFillColor(trackColor)
                    ctx.fillPath()
                case .curveNW:
                    let point = CGPoint(x: rect.minX, y: rect.minY)
                    
                    ctx.beginPath()
                    ctx.addArc(center: point, radius: squareSize, startAngle: 0, endAngle: .pi / 2.0, clockwise: false)
                    ctx.addLine(to: point)
                    ctx.closePath()
                    
                    ctx.setFillColor(trackColor)
                    ctx.fillPath()
                case .curveSE:
                    let point = CGPoint(x: rect.maxX, y: rect.maxY)
                    
                    ctx.beginPath()
                    ctx.addArc(center: point, radius: squareSize, startAngle: .pi, endAngle: .pi * 1.5, clockwise: false)
                    ctx.addLine(to: point)
                    ctx.closePath()
                    
                    ctx.setFillColor(trackColor)
                    ctx.fillPath()
                case .curveSW:
                    let point = CGPoint(x: rect.minX, y: rect.maxY)
                    
                    ctx.beginPath()
                    ctx.addArc(center: point, radius: squareSize, startAngle: .pi * 1.5, endAngle: .pi * 2.0, clockwise: false)
                    ctx.addLine(to: point)
                    ctx.closePath()
                    
                    ctx.setFillColor(trackColor)
                    ctx.fillPath()
                case .intersection:
                    ctx.setFillColor(trackColor)
                    ctx.fill(rect)
                    
                    ctx.move(to: CGPoint(x: rect.midX, y: rect.minY))
                    ctx.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
                    ctx.move(to: CGPoint(x: rect.minX, y: rect.midY))
                    ctx.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
                    
                    ctx.setStrokeColor(intersectionColor)
                    ctx.setLineWidth(1.0)
                    ctx.strokePath()
                case .straightEW, .straightNS:
                    ctx.setFillColor(trackColor)
                    ctx.fill(rect)
                }
                
                ctx.restoreGState()
            }
        }
    }
    
    private func drawCarts(ctx: CGContext, canvas: Canvas, squareSize: CGFloat, carts: [Cart]) {
        canvas.invert()
        
        let cartColor = CGColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
        for cart in carts {
            let rect = CGRect(x: CGFloat(cart.x) * squareSize, y: CGFloat(cart.y) * squareSize, width: squareSize, height: squareSize)
            
            ctx.beginPath()
            
            switch cart.direction {
            case .north:
                ctx.move(to: CGPoint(x: rect.midX, y: rect.minY))
                ctx.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
                ctx.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            case .south:
                ctx.move(to: CGPoint(x: rect.midX, y: rect.maxY))
                ctx.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
                ctx.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
            case .east:
                ctx.move(to: CGPoint(x: rect.maxX, y: rect.midY))
                ctx.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
                ctx.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
            case .west:
                ctx.move(to: CGPoint(x: rect.minX, y: rect.midY))
                ctx.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
                ctx.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            }
            
            ctx.closePath()
            ctx.setFillColor(cartColor)
            ctx.fillPath()
        }
    }
    
    func firstCollision() -> (x: Int, y: Int) {
        var animator: Animator? = nil
        
        let squareSize: CGFloat = 8.0
        
        if drawRuns {
            let width = Int(squareSize) * spaces[0].count
            let height = Int(squareSize) * spaces.count
            
            animator = Animator(name: "13-first-collision", width: width, height: height, rate: "30")
            animator?.drawBackground({ (ctx, canvas) in drawBackground(ctx: ctx, canvas: canvas, squareSize: squareSize) })
        }
        
        var run = 0
        var currentCarts = carts
        
        while true {
            if printRuns {
                print("Run: \(run)")
                printTrack(carts: currentCarts)
                print()
            }
            
            animator?.draw { (ctx, canvas) in drawCarts(ctx: ctx, canvas: canvas, squareSize: squareSize, carts: currentCarts) }
            animator?.snap()
            
            // Sort the carts and move them, looking for the first collision
            currentCarts.sort()
            
            for idx in 0 ..< currentCarts.count {
                currentCarts[idx] = moveCart(cart: currentCarts[idx])
                
                for collisionIdx in 0 ..< currentCarts.count - 1 {
                    let lhs = currentCarts[collisionIdx]
                    let rhs = currentCarts[collisionIdx + 1]
                    
                    if lhs.x == rhs.x && lhs.y == rhs.y {
                        animator?.finalize()
                        animator?.cleanup()
                        
                        return (x: lhs.x, y: lhs.y)
                    }
                }
            }
            
            run += 1
        }
    }
    
    func lastCart() -> (x: Int, y: Int) {
        var animator: Animator? = nil
        
        let squareSize: CGFloat = 8.0
        
        if drawRuns {
            let width = Int(squareSize) * spaces[0].count
            let height = Int(squareSize) * spaces.count
            
            animator = Animator(name: "13-last-cart", width: width, height: height, rate: "30")
            animator?.drawBackground({ (ctx, canvas) in drawBackground(ctx: ctx, canvas: canvas, squareSize: squareSize) })
        }
        
        var run = 0
        var currentCarts = carts
        
        while true {
            if printRuns {
                print("Run: \(run)")
                printTrack(carts: currentCarts)
                print()
            }
            
            animator?.draw { (ctx, canvas) in drawCarts(ctx: ctx, canvas: canvas, squareSize: squareSize, carts: currentCarts) }
            animator?.snap()
            
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
                animator?.finalize()
                animator?.cleanup()
                
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
course.drawRuns = true

let firstCollision = course.firstCollision()
print("First collision: \(firstCollision)")

let lastCart = course.lastCart()
print("Last cart: \(lastCart)")
