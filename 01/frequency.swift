import Foundation

class Analyzer {
    let shifts: [Int]
    let infinite: Bool
    
    init(shifts: [Int], infinite: Bool = false) {
        self.shifts = shifts
        self.infinite = infinite
    }
}

extension Analyzer: Sequence {
    func makeIterator() -> AnalyzerIterator {
        return AnalyzerIterator(self)
    }
}

struct AnalyzerIterator: IteratorProtocol {
    private let analyzer: Analyzer
    private var head: Int
    
    init(_ analyzer: Analyzer) {
        self.analyzer = analyzer
        head = 0
    }
    
    mutating func next() -> Int? {
        if analyzer.infinite {
            let value = analyzer.shifts[head]
            
            head += 1
            
            if head >= analyzer.shifts.count {
                head = 0
            }
            
            return value
        } else {
            if head >= analyzer.shifts.count {
                return nil
            }
            
            let value = analyzer.shifts[head]
            head += 1
            
            return value
        }
    }
}

// Get the input
let stdin = FileHandle.standardInput
let inputData = stdin.readDataToEndOfFile()
let input = String(data: inputData, encoding: .utf8)!

// Clean and organize the input
let shiftStrings = input.split(separator: "\n")
let shifts = shiftStrings.map { Int($0)! }

// Run the frequencies
var currentFrequency = 0
var analyzer = Analyzer(shifts: shifts)

for shift in analyzer {
    let previousFrequency = currentFrequency
    currentFrequency += shift
    
    print(String(format: "Current frequency %3d, change of %3d; resulting frequency %3d", previousFrequency, shift, currentFrequency))
}

// Separator
print("\n-------------------------------------------------------------\n")

// Find the repeating frequency
var visitedFrequencies: Set<Int> = []
analyzer = Analyzer(shifts: shifts, infinite: true)
currentFrequency = 0

for shift in analyzer.lazy {
    let previousFrequency = currentFrequency
    currentFrequency += shift
    
    if visitedFrequencies.contains(currentFrequency) {
        print(String(format: "Current frequency %3d, change of %3d; resulting frequency %3d, which has already been seen.", previousFrequency, shift, currentFrequency))
        break
    } else {
        print(String(format: "Current frequency %3d, change of %3d; resulting frequency %3d", previousFrequency, shift, currentFrequency))
        
        visitedFrequencies.insert(currentFrequency)
    }
}

