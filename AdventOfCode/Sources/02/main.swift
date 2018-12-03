import Foundation
import LineReader

struct Box {
    let id: String
    
    let letters: [String]
    let groups: [String:Int]
    
    let twoGroups: Bool
    let threeGroups: Bool
    
    init(id: String) {
        // Store the ID
        self.id = id
        
        // Get the letters and groupings
        letters = id.map(String.init)
        
        var groups: [String:Int] = [:]
        
        for letter in letters {
            if let value = groups[letter] {
                groups[letter] = value + 1
            } else {
                groups[letter] = 1
            }
        }
        
        self.groups = groups
        
        // Determine which sets it might belong to
        var twoGroups = false
        var threeGroups = false
        
        for (_, value) in groups {
            if value == 3 {
                threeGroups = true
            } else if value == 2 {
                twoGroups = true
            }
            
            if twoGroups && threeGroups {
                break
            }
        }
        
        self.threeGroups = threeGroups
        self.twoGroups = twoGroups
    }
    
    func commonLetters(_ other: Box) -> [String] {
        var common: [String] = []
        
        for pair in zip(letters, other.letters) {
            if pair.0 == pair.1 {
                common.append(pair.0)
            }
        }
        
        return common
    }
}

extension Box: CustomStringConvertible {
    var description: String {
        return "\(id): 2? \(twoGroups), 3? \(threeGroups)"
    }
}

extension Box: Equatable {
    static func == (lhs: Box, rhs: Box) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Box: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// Get the input
let stdin = FileHandle.standardInput
let reader = LineReader(handle: stdin)
let boxes = reader.map { Box(id: $0 ) }

var twos: Set<Box> = []
var threes: Set<Box> = []

for box in boxes {
    if box.twoGroups {
        twos.insert(box)
    }
    
    if box.threeGroups {
        threes.insert(box)
    }
}

let checksum = twos.count * threes.count
print("Checksum: \(checksum)")

let targetSize =  boxes[0].letters.count - 1
var done = false

for box in boxes {
    for other in boxes {
        guard box != other else {
            continue
        }
        
        let common = box.commonLetters(other)
        print("\(box.id) <-> \(other.id) = \(common)")
        
        if common.count == targetSize {
            let match = common.joined(separator: "")
            print("Match: \(match)")
            
            done = true
            break
        }
    }
    
    if done {
        break
    }
}
