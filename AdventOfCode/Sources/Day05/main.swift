import Foundation
import Utilities

infix operator >-<

enum Unit {
    case negative(String)
    case positive(String)
    
    var type: String {
        switch self {
        case .negative(let x):
            return x
        case .positive(let x):
            return x
        }
    }
    
    static func from(_ value: Character) -> Unit {
        return from(String(value))
    }
    
    static func from(_ value: String) -> Unit {
        let lowerCased = value.lowercased()
        
        if value == lowerCased {
            return .negative(lowerCased)
        } else {
            return .positive(lowerCased)
        }
    }
    
    static func >-< (lhs: Unit, rhs: Unit) -> Bool {
        switch (lhs, rhs) {
        case (.negative(let x), .positive(let y)):
            return x == y
        case (.positive(let x), .negative(let y)):
            return x == y
        default:
            return false
        }
    }
}

extension Unit: CustomStringConvertible {
    var description: String {
        switch self {
        case .negative(let x):
            return x
        case .positive(let x):
            return x.uppercased()
        }
    }
}

struct Chain {
    let units: [Unit]
    
    init(value: String) {
        units = value.map(Unit.from)
    }
    
    func react(skipping: String = "") -> String {
        var units = self.units
        var head = 0
        
        while head < units.count - 1 {
            let one = units[head + 0]
            let two = units[head + 1]
            
            if two.type == skipping {
                units.remove(at: head + 1)
            } else if one.type == skipping {
                units.remove(at: head)
            } else if one >-< two {
                units.remove(at: head)
                units.remove(at: head)
                
                head -= 1
                
                if head < 0 {
                    head = 0
                }
            } else {
                head += 1
            }
        }
        
        return units.map { $0.description }.joined()
    }
}

// Get the sequence
let stdin = FileHandle.standardInput
let reader = LineReader(handle: stdin)

guard let sequenceString = reader.readLine() else {
    fatalError("Could not read the sequence line")
}

// Part 1, just react
let chain = Chain(value: sequenceString)
let part1Result = chain.react()

print("Part 1: \(part1Result) (\(part1Result.count))")

// Part 2, skip a letter sequence
var bestLetter = ""
var bestLetterCount = Int.max

print("\nPart 2:")
for l in "abcdefghijklmnopqrstuvwxyz" {
    let letter = String(l)
    
    let result = chain.react(skipping: String(letter))
    print("- \(letter) -> \(result.count)")
    
    if result.count < bestLetterCount {
        bestLetter = letter
        bestLetterCount = result.count
    }
}

print("Best: \(bestLetter) -> \(bestLetterCount)")
