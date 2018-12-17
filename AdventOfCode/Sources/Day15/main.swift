import Foundation
import Utilities

let ElfHP = 200
let GoblinHP = 200

let ElfAttack = 3
let GoblinAttack = 3

struct Point: Comparable, CustomStringConvertible, Equatable, Hashable {
    let x, y: Int
    
    var description: String {
        return "(\(x), \(y))"
    }
    
    static func < (lhs: Point, rhs: Point) -> Bool {
        if lhs.y < rhs.y {
            return true
        } else if lhs.y > rhs.y {
            return false
        } else {
            return lhs.x < rhs.x
        }
    }
    
    static func == (lhs: Point, rhs: Point) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }
    
    var down: Point {
        return Point(x: x, y: y + 1)
    }
    
    var left: Point {
        return Point(x: x - 1, y: y)
    }
    
    var right: Point {
        return Point(x: x + 1, y: y)
    }
    
    var surrounding: [Point] {
        return [ up, left, right, down ]
    }
    
    var up: Point {
        return Point(x: x, y: y - 1)
    }
}

enum Space {
    case wall
    case empty
    case elf(id: Int, hp: Int)
    case goblin(id: Int, hp: Int)
}

class Cave {
    var spaces: [[Space]]
    var rounds: Int
    
    var nextID: Int
    var isOver: Bool
    
    init() {
        spaces = []
        rounds = 0
        nextID = 1
        isOver = false
    }
    
    subscript(_ point: Point) -> Space {
        get {
            return spaces[point.y][point.x]
        }
        set(newValue) {
           spaces[point.y][point.x] = newValue
        }
    }
    
    func addSpaces(line: String) {
        let row = line.map { (x) -> Space in
            let space: Space
            
            switch x {
            case "#":
                space = .wall
            case ".":
                space = .empty
            case "E":
                space = .elf(id: nextID, hp: ElfHP)
                nextID += 1
            case "G":
                space = .goblin(id: nextID, hp: GoblinHP)
                nextID += 1
            default:
                fatalError("Unsupported space: \(x)")
            }
            
            return space
        }
        
        spaces.append(row)
    }
    
    private func nextMovement(point: Point) -> Point? {
        // Swift.print("Next movement")
        
        let space = self[point]
        
        // Determine the target points
        let potentialPoints: [Point]?
        
        switch space {
        case .empty, .wall:
            potentialPoints = nil
        case .elf:
            // Swift.print("- Determining elf @ \(point) next move:")
            potentialPoints = nextElfMovement(point: point)
        case .goblin:
            // Swift.print("- Determing goblin @ \(point) next move:")
            potentialPoints = nextGoblinMovement(point: point)
        }
        
        // No target points, no movement
        guard var targetPoints = potentialPoints else {
            // Swift.print(" - No points. Next!")
            return nil
        }
        
        // Swift.print("- Target points: \(targetPoints)")
        
        targetPoints.sort()
        
        // Swift.print("- Sorted target points: \(targetPoints)")
        
        // Find the best path from this point to a target point
        var bestPath: [Point]? = nil
        var bestDistance = Int.max
        
        let sourcePoints = point.surrounding.filter {
            if case .empty = self[$0] {
                return true
            } else {
                return false
            }
        }
        
        for targetPoint in targetPoints {
            for sourcePoint in sourcePoints {
                guard let path = shortestPath(from: sourcePoint, to: targetPoint) else {
                    continue
                }
            
                if path.count < bestDistance {
                    bestDistance = path.count
                    bestPath = path
                }
            }
        }
        
        // Return the first point from the best path if it exists
        if let path = bestPath {
            // Swift.print("- Best path: \(path)")
            return path[0]
        } else {
            // Swift.print("- No best path")
            return nil
        }
    }
    
    private func nextElfMovement(point: Point) -> [Point]? {
        let up = self[point.up]
        let left = self[point.left]
        let right = self[point.right]
        let down = self[point.down]
        
        // Are we already adjacent to an enemy?
        if case .goblin = up {
            return nil
        } else if case .goblin = left {
            return nil
        } else if case .goblin = right {
            return nil
        } else if case .goblin  = down {
            return nil
        }
        
        // Find all of the potential enemy destinations
        var enemyPoints: [Point] = []
        
        for (enemyY, row) in spaces.enumerated() {
            for (enemyX, enemySpace) in row.enumerated() {
                let enemyPoint = Point(x: enemyX, y: enemyY)
                
                if case .goblin(_, _) = enemySpace {
                    let enemyUp = enemyPoint.up
                    let enemyLeft = enemyPoint.left
                    let enemyRight = enemyPoint.right
                    let enemyDown = enemyPoint.down
                    
                    if case .empty = self[enemyUp]  {
                        enemyPoints.append(enemyUp)
                    }
                    
                    if case .empty = self[enemyLeft] {
                        enemyPoints.append(enemyLeft)
                    }
                    
                    if case .empty = self[enemyRight] {
                        enemyPoints.append(enemyRight)
                    }
                    
                    if case .empty = self[enemyDown] {
                        enemyPoints.append(enemyDown)
                    }
                }
            }
        }
        
        return enemyPoints
    }
    
    private func nextGoblinMovement(point: Point) -> [Point]? {
        let up = self[point.up]
        let left = self[point.left]
        let right = self[point.right]
        let down = self[point.down]
        
        // Are we already adjacent to an enemy?
        if case .elf = up {
            return nil
        } else if case .elf = left {
            return nil
        } else if case .elf = right {
            return nil
        } else if case .elf  = down {
            return nil
        }
        
        // Find all of the potential enemy destinations
        var enemyPoints: [Point] = []
        
        for (enemyY, row) in spaces.enumerated() {
            for (enemyX, enemySpace) in row.enumerated() {
                let enemyPoint = Point(x: enemyX, y: enemyY)
                
                if case .elf(_, _) = enemySpace {
                    let enemyUp = enemyPoint.up
                    let enemyLeft = enemyPoint.left
                    let enemyRight = enemyPoint.right
                    let enemyDown = enemyPoint.down
                    
                    if case .empty = self[enemyUp]  {
                        enemyPoints.append(enemyUp)
                    }
                    
                    if case .empty = self[enemyLeft] {
                        enemyPoints.append(enemyLeft)
                    }
                    
                    if case .empty = self[enemyRight] {
                        enemyPoints.append(enemyRight)
                    }
                    
                    if case .empty = self[enemyDown] {
                        enemyPoints.append(enemyDown)
                    }
                }
            }
        }
        
        return enemyPoints
    }
    
    func nextRound() {
        // Run each creature in order
        let order = roundOrder()
        
        for (_, point) in order {
            let remaining = remainingHitPoints()
            if remaining.elves == 0 {
                Swift.print("It's over! Goblins win! \(rounds * remaining.goblins)")
                isOver = true
                return
            } else if remaining.goblins == 0 {
                Swift.print("It's over! Elves win! \(rounds * remaining.elves)")
                isOver = true
                return
            }
            
            var currentPoint = point
            
            if let movePoint = nextMovement(point: point) {
                let space = self[point]
                self[point] = .empty
                self[movePoint] = space
                
                currentPoint = movePoint
            }
            
            attack(point: currentPoint)
        }
        
        rounds += 1
    }
    
    private func remainingHitPoints() -> (elves: Int, goblins: Int) {
        var elves: Int = 0
        var goblins: Int = 0
        
        for row in spaces {
            for space in row {
                switch space {
                case .empty, .wall:
                    break
                case .elf(_, let hp):
                    elves += hp
                case .goblin(_, let hp):
                    goblins += hp
                }
            }
        }
        
        return (elves: elves, goblins: goblins)
    }
    
    private func attack(point: Point) {
        switch self[point] {
        case .elf:
            elfAttack(point: point)
        case .goblin:
            goblinAttack(point: point)
        default:
            break
        }
    }
    
    private func elfAttack(point: Point) {
        // Find the point with the weakest goblin
        let enemyPoints = point.surrounding
        
        var bestPoint: Point? = nil
        var bestHp = Int.max
        
        for enemyPoint in enemyPoints {
            if case .goblin(_, let enemyHp) = self[enemyPoint] {
                if enemyHp < bestHp {
                    bestPoint = enemyPoint
                    bestHp = enemyHp
                }
            }
        }
        
        if let enemyPoint = bestPoint {
            guard case .goblin(let enemyId, let enemyHp) = self[enemyPoint] else {
                fatalError("Somehow got a non-goblin during attack")
            }
            
            let newEnemyHp = enemyHp - ElfAttack
            
            if newEnemyHp > 0 {
                // Swift.print("Elf @ \(point) attacks Goblin @ \(enemyPoint), \(enemyHp) -> \(newEnemyHp)")
                self[enemyPoint] = .goblin(id: enemyId, hp: newEnemyHp)
            } else {
                // Swift.print("Elf @ \(point) attacks Goblin @ \(enemyPoint), killing it!")
                self[enemyPoint] = .empty
            }
        }
    }
    
    private func goblinAttack(point: Point) {
        // Find the point with the weakest elf
        let enemyPoints = point.surrounding
        
        var bestPoint: Point? = nil
        var bestHp = Int.max
        
        for enemyPoint in enemyPoints {
            if case .elf(_, let enemyHp) = self[enemyPoint] {
                if enemyHp < bestHp {
                    bestPoint = enemyPoint
                    bestHp = enemyHp
                }
            }
        }
        
        if let enemyPoint = bestPoint {
            guard case .elf(let enemyId, let enemyHp) = self[enemyPoint] else {
                fatalError("Somehow got a non-elf during attack")
            }
            
            let newEnemyHp = enemyHp - GoblinAttack
            
            if newEnemyHp > 0 {
                // Swift.print("Goblin @ \(point) attacks Elf @ \(enemyPoint), \(enemyHp) -> \(newEnemyHp)")
                self[enemyPoint] = .elf(id: enemyId, hp: newEnemyHp)
            } else {
                // Swift.print("Goblin @ \(point) attacks Elf @ \(enemyPoint), killing it!")
                self[enemyPoint] = .empty
            }
        }
    }
    
    func print() {
        Swift.print("\nRound \(rounds):")
        
        for row in spaces {
            var hps: [String] = []
            var line = ""
            
            for space in row {
                switch space {
                case .elf(_, let hp):
                    line += "E"
                    hps.append("E(\(hp))")
                case .empty:
                    line += "."
                case .goblin(_, let hp):
                    line += "G"
                    hps.append("G(\(hp))")
                case .wall:
                    line += "#"
                }
            }
            
            let hpsLine = hps.joined(separator: ", ")
            
            Swift.print("\(line)   \(hpsLine)")
        }
    }
    
    private func roundOrder() -> [(id: Int, point: Point)] {
        var order: [(id: Int, point: Point)] = []
        
        for (y, row) in spaces.enumerated() {
            for (x, space) in row.enumerated() {
                switch space {
                case .elf(let id, _):
                    let value = (id: id, point: Point(x: x, y: y))
                    order.append(value)
                case .goblin(let id, _):
                    let value = (id: id, point: Point(x: x, y: y))
                    order.append(value)
                default:
                    break
                }
            }
        }
        
        return order
    }
    
    private func shortestPath(from: Point, to: Point) -> [Point]? {
        // Swift.print("Shortest path from \(from) to \(to)")
        
        var frontier = PriorityQueue<Point>()
        frontier.push(from, priority: 0)
        
        var cameFrom: [Point:Point] = [:]
        var costSoFar: [Point:Int] = [from: 0]
        
        while !frontier.isEmpty {
            // Swift.print("- Frontier: \(frontier)")
            // Swift.print("- Came From: \(cameFrom)")
            
            let currentPoint = frontier.pop()!
            // Swift.print("- Current: \(currentPoint)")
            
            // Do we finish?
            if currentPoint == to {
                var list: [Point] = []
                var listCurrent = to
                
                while listCurrent != from {
                    list.append(listCurrent)
                    listCurrent = cameFrom[listCurrent]!
                }
                
                list.append(from)
                list.reverse()
                
                return list
            }
            
            var neighbors: [Point] = [
                currentPoint.up,
                currentPoint.left,
                currentPoint.right,
                currentPoint.down
            ]
                
            neighbors = neighbors.filter {
                if case .empty = self[$0] {
                    return true
                } else {
                    return false
                }
            }
            
            for nextPoint in neighbors {
                let soFar = costSoFar[nextPoint] ?? 0
                let newCost = soFar  + 1
                
                if costSoFar[nextPoint] == nil || newCost < costSoFar[nextPoint]! {
                    costSoFar[nextPoint] = newCost
                    let priority = newCost + abs(to.x - nextPoint.x) + abs(to.y - nextPoint.y)
                    frontier.push(nextPoint, priority: priority)
                    cameFrom[nextPoint] = currentPoint
                }
            }
        }
        
        // Ran out of nodes without an answer, so there is no path
        return nil
    }
}

// Build the cave
let reader = LineReader(handle: FileHandle.standardInput)

let cave = Cave()
for line in reader {
    cave.addSpaces(line: line)
}

cave.print()

while !cave.isOver {
    cave.nextRound()
    cave.print()
}
