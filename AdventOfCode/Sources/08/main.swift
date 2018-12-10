import Foundation
import LineReader

// Get the input
let stdin = FileHandle.standardInput
let reader = LineReader(handle: stdin)

// Get the numbers
let line = reader.readLine()!
let numbers = line.split(separator: " ").map { Int($0)! }

// Build out the tree
class Node {
    var id: Int
    
    var numberOfChildren: Int
    var numberOfMetadataEntries: Int
    
    var parent: Node?
    
    var children: [Node]
    var metadata: [Int]
    
    var totalMetadata: Int {
        let nodeTotal = metadata.reduce(0, { $0 + $1 })
        let childrenTotals = children.map { $0.totalMetadata }.reduce(0, { $0 + $1 })
        
        return nodeTotal + childrenTotals
    }
    
    var value: Int {
        if children.isEmpty {
            let total = metadata.reduce(0, { $0 + $1 })
            return total
        } else {
            return metadata
                .map { (idx) -> Int in
                    if idx == 0 {
                        return 0
                    } else if idx > children.count {
                        return 0
                    } else {
                        let x = children[idx - 1].value
                        return x
                    }
                }.reduce(0, { $0 + $1 })
        }
    }
    
    init(id: Int) {
        self.id = id
        
        numberOfChildren = 0
        numberOfMetadataEntries = 0
        
        children = []
        metadata = []
    }
    
    func printNode() {
        print("\(self)")
        
        for child in children {
            child.printNode()
        }
    }
}

extension Node: CustomStringConvertible {
    var description: String {
        var builder = ""
        builder += "\(id), which has \(children.count) child nodes "
        
        if children.count > 0 {
            builder += "("
            builder += children.map { String($0.id) }.joined(separator: ", ")
            builder += ") "
        }
        
        builder += "and \(metadata.count) metadata entries ("
        builder += metadata.map { String($0) }.joined(separator: ", ")
        builder += ")"
        
        return builder
    }
}

class Parser {
    var head: Int = 0
    var numbers: [Int]
    
    var nextID: Int = 0
    
    init(numbers: [Int]) {
        self.numbers = numbers
    }
    
    func parse() -> Node {
        head = 0
        return parseNode()
    }
    
    private func parseNode() -> Node {
        let node = Node(id: nextID)
        nextID += 1
        
        node.numberOfChildren = numbers[head]
        head += 1
        
        node.numberOfMetadataEntries = numbers[head]
        head += 1
        
        for _ in 0 ..< node.numberOfChildren {
            let childNode = parseNode()
            
            childNode.parent = node
            node.children.append(childNode)
        }
        
        while node.metadata.count < node.numberOfMetadataEntries {
            node.metadata.append(numbers[head])
            head += 1
        }
        
        return node
    }
}

let parser = Parser(numbers: numbers)
let rootNode = parser.parse()

rootNode.printNode()

print("Metadata total: \(rootNode.totalMetadata)")
print("Value: \(rootNode.value)")
