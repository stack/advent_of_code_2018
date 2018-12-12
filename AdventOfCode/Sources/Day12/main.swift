import Foundation
import Utilities

class Hall {
    private let initialLayout: String
    
    private var generation: Int
    private var headID: Int
    private var pots: [Bool]
    
    private var notes: [String:Bool]
    
    var plantValue: Int {
        let values = pots.enumerated().compactMap { (arg0) -> Int? in
            let (offset, element) = arg0
            
            if !element {
                return nil
            } else {
                return offset + headID
            }
        }
        
        return values.reduce(0) { $0 + $1 }
    }
    
    init(initialLayout: Substring) {
        self.initialLayout = String(initialLayout)
        pots = []
        
        generation = 0
        headID = 0
        notes = [:]
        
        generatePots()
    }
    
    init(initialLayout: String) {
        self.initialLayout = String(initialLayout)
        pots = []
        
        generation = 0
        headID = 0
        notes = [:]
        
        generatePots()
    }
    
    private func generatePots() {
        pots = initialLayout.map { $0 == "#" }
    }
    
    func addNote(pattern: String, hasPlant: Bool) {
        notes[pattern] = hasPlant
    }
    
    func next() {
        // Pad if needed
        if pots[0] {
            pots.insert(false, at: 0)
            headID -= 1
        }
        
        if !pots[0] && pots[1] {
            pots.insert(false, at: 0)
            headID -= 1
        }
        
        var lastIndex = pots.count - 1
        
        if pots[lastIndex] {
            pots.append(false)
        }
        
        lastIndex = pots.count - 1
        
        if !pots[lastIndex] && pots[lastIndex - 1] {
            pots.append(false)
        }
        
        // Compress if needed
        while !pots[0] && !pots[1] && !pots[2] {
            pots.removeFirst()
            headID += 1
        }
        
        // Build the next generation
        let nextPots = pots.enumerated().map { (idx, hasPlant) -> Bool in
            let leftLeftIndex = idx - 2
            let leftIndex = idx - 1
            let rightIndex = idx + 1
            let rightRightIndex = idx + 2
            
            let leftLeftHasPlant = (leftLeftIndex >= 0) ? pots[leftLeftIndex] : false
            let leftHasPlant = (leftIndex >= 0) ? pots[leftIndex] : false
            let rightHasPlant = (rightIndex < pots.count) ? pots[rightIndex] : false
            let rightRightHasPlant = (rightRightIndex < pots.count) ? pots[rightRightIndex] : false
            
            let pattern = [leftLeftHasPlant, leftHasPlant, hasPlant, rightHasPlant, rightRightHasPlant].map { $0 ? "#" : "." }.joined()
            
            // print("Pattern: \(pattern) vs. \(notes.keys)")
            if let nextHasPlant = notes[pattern] {
                return nextHasPlant
            } else {
                return false
            }
        }
        
        pots = nextPots
        generation += 1
    }
    
    func reset() {
        headID = 0
        generation = 0
        
        generatePots()
    }
    
}

extension Hall: CustomStringConvertible {
    var description: String {
        let generationString = String(format: "%3i", generation)
        let potsString = pots.map { $0 ? "#" : "." }.joined()
        
        return "\(generationString): \(potsString) - \(headID)"
    }
}

// Read the initial layout
let reader = LineReader(handle: FileHandle.standardInput)

guard let initialLine = reader.readLine() else {
    fatalError("Failed to read initial line")
}

let initialRegex = try! NSRegularExpression(pattern: "initial state: (.+)", options: [])

guard let initialMatch = initialRegex.firstMatch(in: initialLine, options: [], range: NSRange(location: 0, length: initialLine.count)) else {
    fatalError("Could not match initial line: \(initialLine)")
}

let initialRange = Range(initialMatch.range(at: 1), in: initialLine)!
let initialState = initialLine[initialRange]

// Build the initial hall
let hall = Hall(initialLayout: initialState)

// Read the notes and add them to the hall

let noteRegex = try! NSRegularExpression(pattern: "(.+) => (.)", options: [])

for line in reader {
    guard !line.isEmpty else {
        continue
    }
    
    guard let match = noteRegex.firstMatch(in: line, options: [], range: NSRange(location: 0, length: line.count)) else {
        fatalError("Failed to match note line: \(line)")
    }
    
    let patternRange = Range(match.range(at: 1), in: line)!
    let pattern = String(line[patternRange])
    
    let resultRange = Range(match.range(at: 2), in: line)!
    let result = line[resultRange]
    
    let hasPlant = result == "#"
    
    hall.addNote(pattern: pattern, hasPlant: hasPlant)
}

print("\nPart 1:\n")

print(hall.description)

for _ in 0 ..< 20 {
    hall.next()
    print(hall.description)
}

print("Part 1 Value: \(hall.plantValue)")

print("\nPart 2:\n")

hall.reset()

var lastValue = hall.plantValue
var lastDiff = 0
var lastDiffHits = 0
var generation = 0
while generation < 10000 {
    hall.next()
    
    let nextValue = hall.plantValue
    let diff = nextValue - lastValue
    
    if diff == lastDiff {
        lastDiffHits += 1
        
        if lastDiffHits == 10 {
            break
        }
    } else {
        lastDiff = diff
    }
    
    print("Value: \(nextValue) <- \(lastValue) = \(nextValue - lastValue)")
    
    lastValue = nextValue
    
    generation += 1
}

print("Diffs stabilized at \(lastDiff) on generation \(generation) with a sum of \(lastValue)")
let remainingGenerations = 50000000000 - generation
let finalSum = lastValue + (remainingGenerations * lastDiff)

print("Part 2 Value: \(finalSum)")
