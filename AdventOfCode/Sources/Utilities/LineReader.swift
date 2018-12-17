import Foundation

fileprivate let ReadSize = 1024

public class LineReader {
    let handle: FileHandle
    private var buffer: String
    private var eof: Bool
    
    public init(handle: FileHandle) {
        self.handle = handle
        buffer = ""
        eof = false
    }
    
    public func readLine(readMore: Bool = false) -> String? {
        // If the buffer is empty, read more
        if buffer.isEmpty || readMore {
            let data = handle.readData(ofLength: ReadSize)
            if data.count != 0 {
                let value = String(data: data, encoding: .utf8)!
                buffer += value
            } else {
                eof = true
            }
        }
        
        // If the buffer is still empty, there's nothing left
        guard !buffer.isEmpty else {
            return nil
        }
        
        // Find the first line break
        let results = buffer.split(separator: "\n", maxSplits: 1, omittingEmptySubsequences: false)
        if results.count == 1 {
            // Didn't find a new line. If we're at EOF, then just return buffer, otherwise recurse
            if eof {
                buffer = ""
                
                // Don't emit the final new line if we're at the end
                if results[0].isEmpty {
                    return nil
                } else {
                    return String(results[0])
                }
            } else {
                return readLine(readMore: true)
            }
        } else if results.count == 2 {
            buffer = String(results[1])
            
            return String(results[0])
        } else {
            fatalError("Results should be 1 or 2")
        }
    }
}

extension LineReader: Sequence {
    public func makeIterator() -> LineReaderIterator {
        return LineReaderIterator(self)
    }
}

public struct LineReaderIterator: IteratorProtocol {
    private let reader: LineReader
    
    init(_ reader: LineReader) {
        self.reader = reader
    }
    
    public mutating func next() -> String? {
        return reader.readLine()
    }
}
