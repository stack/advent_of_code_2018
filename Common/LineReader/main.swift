import Foundation

let stdin = FileHandle.standardInput
let reader = LineReader(handle: stdin)

for line in reader {
    print("LINE: *** \(line) ***")
}
