import Foundation
import Utilities

class Analyzer {
    let shifts: [Int]
    
    init(shifts: [Int]) {
        self.shifts = shifts
    }
    
    func iterator(infinite: Bool = false) -> AnalyzerSequence {
        return AnalyzerSequence(analyzer: self, infinite: infinite)
    }
}

struct AnalyzerSequence {
    let analyzer: Analyzer
    let infinite: Bool
    
    init(analyzer: Analyzer, infinite: Bool) {
        self.analyzer = analyzer
        self.infinite = infinite
    }
}

extension AnalyzerSequence: Sequence {
    func makeIterator() -> AnalyzerSequenceIterator {
        return AnalyzerSequenceIterator(self)
    }
}

struct AnalyzerSequenceIterator: IteratorProtocol {
    private let analyzerSequence: AnalyzerSequence
    private var head: Int
    
    init(_ analyzerSequence: AnalyzerSequence) {
        self.analyzerSequence = analyzerSequence
        head = 0
    }
    
    mutating func next() -> Int? {
        if analyzerSequence.infinite {
            let value = analyzerSequence.analyzer.shifts[head]
            
            head += 1
            
            if head >= analyzerSequence.analyzer.shifts.count {
                head = 0
            }
            
            return value
        } else {
            if head >= analyzerSequence.analyzer.shifts.count {
                return nil
            }
            
            let value = analyzerSequence.analyzer.shifts[head]
            head += 1
            
            return value
        }
    }
}

// Get the input
let stdin = FileHandle.standardInput
let reader = LineReader(handle: stdin)
let shifts = reader.map { Int($0)! }

// Run the frequencies
var currentFrequency = 0
var analyzer = Analyzer(shifts: shifts)

for shift in analyzer.iterator() {
    let previousFrequency = currentFrequency
    currentFrequency += shift
    
    print(String(format: "Current frequency %3d, change of %3d; resulting frequency %3d", previousFrequency, shift, currentFrequency))
}

// Separator
print("\n-------------------------------------------------------------\n")

// Find the repeating frequency
var visitedFrequencies: Set<Int> = []
currentFrequency = 0

for shift in analyzer.iterator(infinite: true).lazy {
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
