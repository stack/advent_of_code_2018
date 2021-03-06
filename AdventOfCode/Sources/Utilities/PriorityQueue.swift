import Foundation

public struct PriorityQueue<T: Equatable> {
    public typealias Item = T
    
    var nodes: [(Item,Int)]
    
    public var isEmpty: Bool {
        return nodes.isEmpty
    }
    
    public init() {
        nodes = []
    }
    
    public mutating func pop() -> Item? {
        if nodes.isEmpty {
            return nil
        }
        
        let item = nodes.removeFirst()
        return item.0
    }
    
    public mutating func push(_ item: Item, priority: Int) {
        var insertIdx = -1
        
        for (idx, node) in nodes.enumerated() {
            if priority < node.1 {
                insertIdx = idx
                break
            }
        }
        
        if insertIdx == -1 {
            insertIdx = nodes.count
        }
        
        nodes.insert((item, priority), at: insertIdx)
    }
}

extension PriorityQueue: CustomStringConvertible {
    public var description: String {
        let parts = nodes.map { "(\($0.0), \($0.1))" }
        let joined = parts.joined(separator: ", ")
        
        return "[\(joined)]"
    }
}
