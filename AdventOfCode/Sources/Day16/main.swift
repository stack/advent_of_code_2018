import Foundation
import Utilities

struct Compute {
    var registers: [Int]
    
    init() {
        registers = [0, 0, 0, 0]
    }
    
    init(registers: [Int]) {
        self.registers = registers
    }
    
    mutating func addr(a: Int, b: Int, c: Int) {
        registers[c] = registers[a] + registers[b]
    }
    
    mutating func addi(a: Int, b: Int, c: Int) {
        registers[c] = registers[a] + b
    }
    
    mutating func mulr(a: Int, b: Int, c: Int) {
        registers[c] = registers[a] * registers[b]
    }
    
    mutating func muli(a: Int, b: Int, c: Int) {
        registers[c] = registers[a] * b
    }
    
    mutating func banr(a: Int, b: Int, c: Int) {
        registers[c] = registers[a] & registers[b]
    }
    
    mutating func bani(a: Int, b: Int, c: Int) {
        registers[c] = registers[a] & b
    }
    
    mutating func borr(a: Int, b: Int, c: Int) {
        registers[c] = registers[a] | registers[b]
    }
    
    mutating func bori(a: Int, b: Int, c: Int) {
        registers[c] = registers[a] | b
    }
    
    mutating func setr(a: Int, b: Int, c: Int) {
        registers[c] = registers[a]
    }
    
    mutating func seti(a: Int, b: Int, c: Int) {
        registers[c] = a
    }
    
    mutating func gtir(a: Int, b: Int, c: Int) {
        registers[c] = (a > registers[b]) ? 1 : 0
    }
    
    mutating func gtri(a: Int, b: Int, c: Int) {
        registers[c] = (registers[a] > b) ? 1 : 0
    }
    
    mutating func gtrr(a: Int, b: Int, c: Int) {
        registers[c] = (registers[a] > registers[b]) ? 1 : 0
    }
    
    mutating func eqir(a: Int, b: Int, c: Int) {
        registers[c] = (a == registers[b]) ? 1 : 0
    }
    
    mutating func eqri(a: Int, b: Int, c: Int) {
        registers[c] = (registers[a] == b) ? 1 : 0
    }
    
    mutating func eqrr(a: Int, b: Int, c: Int) {
        registers[c] = (registers[a] == registers[b]) ? 1 : 0
    }
}

enum Mode {
    case part1
    case part2
}

let modeString = CommandLine.arguments[1]
let mode: Mode

switch modeString {
case "part1":
    mode = .part1
case "part2":
    mode = .part2
default:
    fatalError("No mode provided")
}

let reader = LineReader(handle: FileHandle.standardInput)

if mode == .part1 {
    let beforeRegex = try! NSRegularExpression(pattern: "Before:\\s+\\[(\\d+), (\\d+), (\\d+), (\\d+)\\]", options: [])
    let commandRegex = try! NSRegularExpression(pattern: "(\\d+) (\\d+) (\\d+) (\\d+)", options: [])
    let afterRegex = try! NSRegularExpression(pattern: "After:\\s+\\[(\\d+), (\\d+), (\\d+), (\\d+)\\]", options: [])
    
    var threeOrMoreMatches = 0
    var lines = 0
    
    while true {
        // Parse the three lines
        let beforeLine = reader.readLine()!
        print("\(lines): \(beforeLine)")
        lines += 1
        let beforeMatch = beforeRegex.firstMatch(in: beforeLine, options: [], range: NSRange(location: 0, length: beforeLine.count))!
        
        let beforeOneRange = Range(beforeMatch.range(at: 1), in: beforeLine)!
        let beforeTwoRange = Range(beforeMatch.range(at: 2), in: beforeLine)!
        let beforeThreeRange = Range(beforeMatch.range(at: 3), in: beforeLine)!
        let beforeFourRange = Range(beforeMatch.range(at: 4), in: beforeLine)!
        
        let beforeRegisters = [
            Int(beforeLine[beforeOneRange])!,
            Int(beforeLine[beforeTwoRange])!,
            Int(beforeLine[beforeThreeRange])!,
            Int(beforeLine[beforeFourRange])!,
        ]
        
        let commandLine = reader.readLine()!
        print("\(lines): \(commandLine)")
        lines += 1
        let commandMatch = commandRegex.firstMatch(in: commandLine, options: [], range: NSRange(location: 0, length: commandLine.count))!
        
        let commandOneRange = Range(commandMatch.range(at: 1), in: commandLine)!
        let commandTwoRange = Range(commandMatch.range(at: 2), in: commandLine)!
        let commandThreeRange = Range(commandMatch.range(at: 3), in: commandLine)!
        let commandFourRange = Range(commandMatch.range(at: 4), in: commandLine)!
        
        let command = [
            Int(commandLine[commandOneRange])!,
            Int(commandLine[commandTwoRange])!,
            Int(commandLine[commandThreeRange])!,
            Int(commandLine[commandFourRange])!,
        ]
        
        let afterLine = reader.readLine()!
        print("\(lines): \(afterLine)")
        lines += 1
        let afterMatch = afterRegex.firstMatch(in: afterLine, options: [], range: NSRange(location: 0, length: afterLine.count))!
        
        let afterOneRange = Range(afterMatch.range(at: 1), in: afterLine)!
        let afterTwoRange = Range(afterMatch.range(at: 2), in: afterLine)!
        let afterThreeRange = Range(afterMatch.range(at: 3), in: afterLine)!
        let afterFourRange = Range(afterMatch.range(at: 4), in: afterLine)!
        
        let afterRegisters = [
            Int(afterLine[afterOneRange])!,
            Int(afterLine[afterTwoRange])!,
            Int(afterLine[afterThreeRange])!,
            Int(afterLine[afterFourRange])!,
        ]
        
        /*** TESTS ***/
        
        var matches = 0
        
        // addr
        var compute = Compute(registers: beforeRegisters)
        compute.addr(a: command[1], b: command[2], c: command[3])
        
        if compute.registers == afterRegisters {
            matches += 1
        }
        
        // addi
        compute = Compute(registers: beforeRegisters)
        compute.addi(a: command[1], b: command[2], c: command[3])
        
        if compute.registers == afterRegisters {
            matches += 1
        }
        
        // mulr
        compute = Compute(registers: beforeRegisters)
        compute.mulr(a: command[1], b: command[2], c: command[3])
        
        if compute.registers == afterRegisters {
            matches += 1
        }
        
        // muli
        compute = Compute(registers: beforeRegisters)
        compute.muli(a: command[1], b: command[2], c: command[3])
        
        if compute.registers == afterRegisters {
            matches += 1
        }
        
        // banr
        compute = Compute(registers: beforeRegisters)
        compute.banr(a: command[1], b: command[2], c: command[3])
        
        if compute.registers == afterRegisters {
            matches += 1
        }
        
        // bani
        compute = Compute(registers: beforeRegisters)
        compute.bani(a: command[1], b: command[2], c: command[3])
        
        if compute.registers == afterRegisters {
            matches += 1
        }
        
        // borr
        compute = Compute(registers: beforeRegisters)
        compute.borr(a: command[1], b: command[2], c: command[3])
        
        if compute.registers == afterRegisters {
            matches += 1
        }
        
        // bori
        compute = Compute(registers: beforeRegisters)
        compute.bori(a: command[1], b: command[2], c: command[3])
        
        if compute.registers == afterRegisters {
            matches += 1
        }
        
        // setr
        compute = Compute(registers: beforeRegisters)
        compute.setr(a: command[1], b: command[2], c: command[3])
        
        if compute.registers == afterRegisters {
            matches += 1
        }
        
        // seti
        compute = Compute(registers: beforeRegisters)
        compute.seti(a: command[1], b: command[2], c: command[3])
        
        if compute.registers == afterRegisters {
            matches += 1
        }
        
        // gtir
        compute = Compute(registers: beforeRegisters)
        compute.gtir(a: command[1], b: command[2], c: command[3])
        
        if compute.registers == afterRegisters {
            matches += 1
        }
        
        // gtri
        compute = Compute(registers: beforeRegisters)
        compute.gtri(a: command[1], b: command[2], c: command[3])
        
        if compute.registers == afterRegisters {
            matches += 1
        }
        
        // gtrr
        compute = Compute(registers: beforeRegisters)
        compute.gtrr(a: command[1], b: command[2], c: command[3])
        
        if compute.registers == afterRegisters {
            matches += 1
        }
        
        // eqir
        compute = Compute(registers: beforeRegisters)
        compute.eqir(a: command[1], b: command[2], c: command[3])
        
        if compute.registers == afterRegisters {
            matches += 1
        }
        
        // eqri
        compute = Compute(registers: beforeRegisters)
        compute.eqri(a: command[1], b: command[2], c: command[3])
        
        if compute.registers == afterRegisters {
            matches += 1
        }
        
        // eqrr
        compute = Compute(registers: beforeRegisters)
        compute.eqrr(a: command[1], b: command[2], c: command[3])
        
        if compute.registers == afterRegisters {
            matches += 1
        }
        
        print("Matches: \(matches)")
        
        if matches >= 3 {
            threeOrMoreMatches += 1
        }
        
        // Read the blank line, or exit
        guard reader.readLine() != nil else{
            break
        }
        
        lines += 1
    }
    
    print("Three or more matches: \(threeOrMoreMatches)")
}
