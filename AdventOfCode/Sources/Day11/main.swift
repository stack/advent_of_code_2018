let serialNumber = 8561

struct Board {
    var cells: [[Int]]
    let serial: Int
    
    init(serial: Int) {
        self.serial = serial
        
        cells = []
        for _ in 0 ..< 300 {
            cells.append([Int](repeating: 0, count: 300))
        }
        
        for x in 1 ... 300 {
            for y in 1 ... 300 {
                let rackID = x + 10
                
                var powerLevel = rackID * y
                powerLevel += serial
                powerLevel *= rackID
                
                let digit = (powerLevel / 100) % 10
                powerLevel = digit - 5
                
                cells[y-1][x-1] = powerLevel
            }
        }
    }
    
    subscript(x: Int, y: Int) -> Int {
        return cells[y-1][x-1]
    }
    
    func totalPower(x: Int, y: Int, size: Int) -> Int {
        var totalPower = 0
        
        for xOffset in 0 ..< size {
            for yOffset in 0 ..< size {
                totalPower += cells[y + yOffset - 1][x + xOffset - 1]
            }
        }
        
        return totalPower
    }
    
    func largestTotalPowerSized() -> (x: Int, y: Int, s: Int, p: Int) {
        var largestSize = -1
        var largestX = -1
        var largestY = -1
        var largestPower = Int.min
        
        for size in 1 ... 300 {
            let largest = largestTotalPower(of: size)
            
            if largest.p > largestPower {
                largestSize = size
                largestX = largest.x
                largestY = largest.y
                largestPower = largest.p
            }
        }
        
        return (x: largestX, y: largestY, s: largestSize, p: largestPower)
    }
    
    func largestTotalPower(of size: Int) -> (x: Int, y: Int, p: Int) {
        var largestX = -1
        var largestY = -1
        var largestTotalPower = Int.min
        
        for x in 1 ... 298 {
            for y in 1 ... 298 {
                let power = totalPower(x: x, y: y, size: size)
                
                if power > largestTotalPower {
                    largestX = x
                    largestY = y
                    largestTotalPower = power
                }
            }
        }
        
        return (x: largestX, y: largestY, p: largestTotalPower)
    }
}

/*
func largestSize(serial: Int) -> (x: Int, y: Int, s: Int, p: Int) {
    var largestSize = -1
    var largestX = -1
    var largestY = -1
    var largestTotalPower = Int.min
    
    for size in 4 ... 300 {
        let largest = largestTotal(serial: serial, size: size)
        
        if largest.p > largestTotalPower {
            largestSize = size
            largestX = largest.x
            largestY = largest.y
            largestTotalPower = largest.p
        }
    }
    
    return (largestX, largestY, largestSize, largestTotalPower)
}

func largestTotal(serial: Int, size: Int) -> (x: Int, y: Int, p: Int) {
    var largestX = -1
    var largestY = -1
    var largestTotalPower = Int.min
    
    for x in 1 ... (size - 2) {
        for y in 1 ... (size - 2) {
            let power = totalPower(x: x, y: y, serial: serial)
            
            if power > largestTotalPower {
                largestX = x
                largestY = y
                largestTotalPower = power
            }
        }
    }
    
    return (largestX, largestY, largestTotalPower)
}
 */

// Power Level Testing
var board = Board(serial: 8)
var level = board[3, 5]
assert(level == 4)

board = Board(serial: 57)
level = board[122, 79]
assert(level == -5)

board = Board(serial: 39)
level = board[217, 196]
assert(level == 0)

board = Board(serial: 71)
level = board[101, 153]
assert(level == 4)

// Total Power Testing
board = Board(serial: 18)
var largest = board.largestTotalPower(of: 3)
assert(largest.x == 33)
assert(largest.y == 45)
assert(largest.p == 29)

board = Board(serial: 42)
largest = board.largestTotalPower(of: 3)
assert(largest.x == 21)
assert(largest.y == 61)
assert(largest.p == 30)

// Largest Total Power Testing
board = Board(serial: 18)
var largestTotalTuple = board.largestTotalPowerSized()
assert(largestTotalTuple.x == 90)
assert(largestTotalTuple.y == 269)
assert(largestTotalTuple.s == 9)
assert(largestTotalTuple.p == 113)

board = Board(serial: 42)
largestTotalTuple = board.largestTotalPowerSized()
assert(largestTotalTuple.x == 232)
assert(largestTotalTuple.y == 251)
assert(largestTotalTuple.s == 12)
assert(largestTotalTuple.p == 119)

// Part 1:
board = Board(serial: serialNumber)
largest = board.largestTotalPower(of: 3)
print("Part 1: (\(largest.x), \(largest.y)) = \(largest.p)")

// Part2:
board = Board(serial: serialNumber)
largestTotalTuple = board.largestTotalPowerSized()
print("Part 2: (\(largestTotalTuple.x), \(largestTotalTuple.y)) @ \(largestTotalTuple.s) = \(largest.p)")
