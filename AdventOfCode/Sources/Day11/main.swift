let serialNumber = 8561

struct CacheKey: Hashable {
    let x: Int
    let y: Int
    let size: Int
}

struct Board {
    let serial: Int
    let cells: [[Int]]
    let summedCells: [[Int]]
    
    init(serial: Int) {
        self.serial = serial
        
        // Calculate all of the power ratings
        cells = (0 ..< 300).map { (y) -> [Int] in
            return (0 ..< 300).map { (x) -> Int in
                let rackID = (x + 1) + 10
                
                var powerLevel = rackID * (y + 1)
                powerLevel += serial
                powerLevel *= rackID
                
                let digit = (powerLevel / 100) % 10
                powerLevel = digit - 5
                
                return powerLevel
            }
        }
        
        // Calculate the summed square values
        var summedCells = [[Int]](repeating: [Int](repeating: Int.min, count: 300), count: 300)
        
        // Calculate 0, 0
        summedCells[0][0] = cells[0][0]
        
        // Calculate the top row
        for x in 1 ..< 300 {
            summedCells[0][x] = cells[0][x] + summedCells[0][x - 1]
        }
        
        // Calculate the left column
        for y in 1 ..< 300 {
            summedCells[y][0] = cells[y][0] + summedCells[y - 1][0]
        }
        
        // Calculate everything else
        for x in 1 ..< 300 {
            for y in 1 ..< 300 {
                summedCells[y][x] = cells[y][x] + summedCells[y - 1][x] + summedCells[y][x - 1] - summedCells[y - 1][x - 1]
            }
        }
        
        self.summedCells = summedCells
    }
    
    subscript(x: Int, y: Int) -> Int {
        return cells[y - 1][x - 1]
    }
    
    private func totalPower(x: Int, y: Int, size: Int) -> Int {
        let d = summedCells[y + size - 1][x + size - 1]
        
        if x == 0 && y == 0 {
            return d
        } else if x == 0 {
            let b = summedCells[y - 1][x + size - 1]
            return d - b
        } else if y == 0 {
            let c = summedCells[y + size - 1][x - 1]
            return d - c
        } else {
            let a = summedCells[y - 1][x - 1]
            let b = summedCells[y - 1][x + size - 1]
            let c = summedCells[y + size - 1][x - 1]
        
            return d + a - b - c
        }
    }
    
    func largestTotalPower(size: Int) -> (x: Int, y: Int, p: Int) {
        var largestX = -1
        var largestY = -1
        var largestPower = Int.min
        
        for x in 0 ... (300 - size) {
            for y in 0 ... (300 - size) {
                let power = totalPower(x: x, y: y, size: size)
                
                if power > largestPower {
                    largestX = x
                    largestY = y
                    largestPower = power
                }
            }
        }
        
        return (x: largestX + 1, y: largestY + 1, p: largestPower)
    }
    
    func largestTotalPowerSized() -> (x: Int, y: Int, s: Int, p: Int) {
        var largestX = -1
        var largestY = -1
        var largestSize = -1
        var largestPower = Int.min
        
        for size in 1 ... 300 {
            let largest = largestTotalPower(size: size)
            
            if largest.p > largestPower {
                largestX = largest.x
                largestY = largest.y
                largestSize = size
                largestPower = largest.p
            }
        }
        
        return (x: largestX, y: largestY, s: largestSize, p: largestPower)
    }
    
/*
    
    mutating func totalPower(x: Int, y: Int, size: Int) -> Int {
        // Do we have a cache hit?
        let currentKey = CacheKey(x: x, y: y, size: size)
        if let power = totalPowerCache[currentKey] {
            print("- Cache hit for (\(x), \(y)) @ \(size)")
            return power
        }
        
        // We can't go lower that 1
        if size == 1 {
            let key = CacheKey(x: x, y: y, size: 1)
            let value = self[x,y]
            
            print("- Cache start for (\(x), \(y)) @ \(size)")
            totalPowerCache[key] = value
            
            return value
        }
        
        // Recurse down and then fill in the edges
        print("- Recursive cache for (\(x), \(y)) @ \(size))")
        
        var power = totalPower(x: x, y: y, size: size - 1)
        
        for xEdge in x ..< (x + size) {
           power += self[xEdge, y + size - 1]
        }
        
        for yEdge in y ..< (y + size - 1) {
            power += self[x + size - 1, yEdge]
        }
        
        totalPowerCache[currentKey] = power
        
        return power
    }
    
    mutating func largestTotalPower(size: Int) -> (x: Int, y: Int, p: Int) {
        var largestX = -1
        var largestY = -1
        var largestPower = Int.min
        
        for x in 1 ... (301 - size) {
            for y in 1 ... (301 - size) {
                let power = totalPower(x: x, y: y, size: size)
                
                if power > largestPower {
                    largestX = x
                    largestY = y
                    largestPower = power
                }
            }
        }
        
        return (x: largestX, y: largestY, p: largestPower)
    }
    
    mutating func largestTotalPowerSized() -> (x: Int, y: Int, s: Int, p: Int) {
        var largestX = -1
        var largestY = -1
        var largestSize = -1
        var largestPower = Int.min
        
        for size in 1 ... 300 {
            print("LTPS: \(size)")
            
            let largest = largestTotalPower(size: size)
            
            if largest.p > largestPower {
                print("LTPS: \(size) is larger \(largest.p) vs. \(largestPower)")
                
                largestX = largest.x
                largestY = largest.y
                largestSize = size
                largestPower = largest.p
            }
        }
        
        return (x: largestX, y: largestY, s: largestSize, p: largestPower)
    }
 */
}

// Power Level Testing
print("Power Level Testing…")

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

print("Total Power Testing…")

board = Board(serial: 18)
var largest = board.largestTotalPower(size: 3)
assert(largest.x == 33)
assert(largest.y == 45)
assert(largest.p == 29)

board = Board(serial: 42)
largest = board.largestTotalPower(size: 3)
assert(largest.x == 21)
assert(largest.y == 61)
assert(largest.p == 30)

// Largest Total Power Testing
print("Largest total power testing…")

print("- Board 18")
board = Board(serial: 18)
var largestTotalTuple = board.largestTotalPowerSized()
assert(largestTotalTuple.x == 90)
assert(largestTotalTuple.y == 269)
assert(largestTotalTuple.s == 16)
assert(largestTotalTuple.p == 113)

print("- Board 42")
board = Board(serial: 42)
largestTotalTuple = board.largestTotalPowerSized()
assert(largestTotalTuple.x == 232)
assert(largestTotalTuple.y == 251)
assert(largestTotalTuple.s == 12)
assert(largestTotalTuple.p == 119)

// Part 1:
board = Board(serial: serialNumber)
largest = board.largestTotalPower(size: 3)
print("Part 1: (\(largest.x), \(largest.y)) = \(largest.p)")

// Part2:
board = Board(serial: serialNumber)
largestTotalTuple = board.largestTotalPowerSized()
print("Part 2: (\(largestTotalTuple.x), \(largestTotalTuple.y)) @ \(largestTotalTuple.s) = \(largest.p)")
