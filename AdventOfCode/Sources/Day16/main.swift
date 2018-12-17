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
    
    mutating func execute(instruction: Instruction) {
        switch instruction {
        case .addr(let a, let b, let c):
            registers[c] = registers[a] + registers[b]
        case .addi(let a, let b, let c):
            registers[c] = registers[a] + b
        case .mulr(let a, let b, let c):
            registers[c] = registers[a] * registers[b]
        case .muli(let a, let b, let c):
            registers[c] = registers[a] * b
        case .banr(let a, let b, let c):
            registers[c] = registers[a] & registers[b]
        case .bani(let a, let b, let c):
            registers[c] = registers[a] & b
        case .borr(let a, let b, let c):
            registers[c] = registers[a] | registers[b]
        case .bori(let a, let b, let c):
            registers[c] = registers[a] | b
        case .setr(let a, _, let c):
            registers[c] = registers[a]
        case .seti(let a, _, let c):
            registers[c] = a
        case .gtir(let a, let b, let c):
            registers[c] = (a > registers[b]) ? 1 : 0
        case .gtri(let a, let b, let c):
            registers[c] = (registers[a] > b) ? 1 : 0
        case .gtrr(let a, let b, let c):
            registers[c] = (registers[a] > registers[b]) ? 1 : 0
        case .eqir(let a, let b, let c):
            registers[c] = (a == registers[b]) ? 1 : 0
        case .eqri(let a, let b, let c):
            registers[c] = (registers[a] == b) ? 1 : 0
        case .eqrr(let a, let b, let c):
            registers[c] = (registers[a] == registers[b]) ? 1 : 0
        }
    }
}

enum Instruction {
    case addr(a: Int, b: Int, c: Int)
    case addi(a: Int, b: Int, c: Int)
    case mulr(a: Int, b: Int, c: Int)
    case muli(a: Int, b: Int, c: Int)
    case banr(a: Int, b: Int, c: Int)
    case bani(a: Int, b: Int, c: Int)
    case borr(a: Int, b: Int, c: Int)
    case bori(a: Int, b: Int, c: Int)
    case setr(a: Int, b: Int, c: Int)
    case seti(a: Int, b: Int, c: Int)
    case gtir(a: Int, b: Int, c: Int)
    case gtri(a: Int, b: Int, c: Int)
    case gtrr(a: Int, b: Int, c: Int)
    case eqir(a: Int, b: Int, c: Int)
    case eqri(a: Int, b: Int, c: Int)
    case eqrr(a: Int, b: Int, c: Int)
    
    static func from(_ array: [Int]) -> Instruction {
        switch array[0] {
        case 0:
            return .muli(a: array[1], b: array[2], c: array[3])
        case 1:
            return .borr(a: array[1], b: array[2], c: array[3])
        case 2:
            return .gtri(a: array[1], b: array[2], c: array[3])
        case 3:
            return .eqri(a: array[1], b: array[2], c: array[3])
        case 4:
            return .gtrr(a: array[1], b: array[2], c: array[3])
        case 5:
            return .eqir(a: array[1], b: array[2], c: array[3])
        case 6:
            return .addi(a: array[1], b: array[2], c: array[3])
        case 7:
            return .setr(a: array[1], b: array[2], c: array[3])
        case 8:
            return .mulr(a: array[1], b: array[2], c: array[3])
        case 9:
            return .addr(a: array[1], b: array[2], c: array[3])
        case 10:
            return .bori(a: array[1], b: array[2], c: array[3])
        case 11:
            return .bani(a: array[1], b: array[2], c: array[3])
        case 12:
            return .seti(a: array[1], b: array[2], c: array[3])
        case 13:
            return .eqrr(a: array[1], b: array[2], c: array[3])
        case 14:
            return .banr(a: array[1], b: array[2], c: array[3])
        case 15:
            return .gtir(a: array[1], b: array[2], c: array[3])
        default:
            fatalError("Unhandled command: \(array[0])")
        }
    }
    
    
}

enum Mode {
    case part1
    case part2
    case part3
}

let modeString = CommandLine.arguments[1]
let mode: Mode

switch modeString {
case "part1":
    mode = .part1
case "part2":
    mode = .part2
case "part3":
    mode = .part3
default:
    fatalError("No mode provided")
}

let reader = LineReader(handle: FileHandle.standardInput)

let beforeRegex = try! NSRegularExpression(pattern: "Before:\\s+\\[(\\d+), (\\d+), (\\d+), (\\d+)\\]", options: [])
let commandRegex = try! NSRegularExpression(pattern: "(\\d+) (\\d+) (\\d+) (\\d+)", options: [])
let afterRegex = try! NSRegularExpression(pattern: "After:\\s+\\[(\\d+), (\\d+), (\\d+), (\\d+)\\]", options: [])

if mode == .part1 {
    var threeOrMoreMatches = 0
    var lines = 1
    
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
        var instruction = Instruction.addr(a: command[1], b: command[2], c: command[3])
        compute.execute(instruction: instruction)
        
        if compute.registers == afterRegisters {
            matches += 1
        }
        
        // addi
        compute = Compute(registers: beforeRegisters)
        instruction = Instruction.addi(a: command[1], b: command[2], c: command[3])
        compute.execute(instruction: instruction)
        
        if compute.registers == afterRegisters {
            matches += 1
        }
        
        // mulr
        compute = Compute(registers: beforeRegisters)
        instruction = Instruction.mulr(a: command[1], b: command[2], c: command[3])
        compute.execute(instruction: instruction)
        
        if compute.registers == afterRegisters {
            matches += 1
        }
        
        // muli
        compute = Compute(registers: beforeRegisters)
        instruction = Instruction.muli(a: command[1], b: command[2], c: command[3])
        compute.execute(instruction: instruction)
        
        if compute.registers == afterRegisters {
            matches += 1
        }
        
        // banr
        compute = Compute(registers: beforeRegisters)
        instruction = Instruction.banr(a: command[1], b: command[2], c: command[3])
        compute.execute(instruction: instruction)
        
        if compute.registers == afterRegisters {
            matches += 1
        }
        
        // bani
        compute = Compute(registers: beforeRegisters)
        instruction = Instruction.bani(a: command[1], b: command[2], c: command[3])
        compute.execute(instruction: instruction)
        
        if compute.registers == afterRegisters {
            matches += 1
        }
        
        // borr
        compute = Compute(registers: beforeRegisters)
        instruction = Instruction.borr(a: command[1], b: command[2], c: command[3])
        compute.execute(instruction: instruction)
        
        if compute.registers == afterRegisters {
            matches += 1
        }
        
        // bori
        compute = Compute(registers: beforeRegisters)
        instruction = Instruction.bori(a: command[1], b: command[2], c: command[3])
        compute.execute(instruction: instruction)
        
        if compute.registers == afterRegisters {
            matches += 1
        }
        
        // setr
        compute = Compute(registers: beforeRegisters)
        instruction = Instruction.setr(a: command[1], b: command[2], c: command[3])
        compute.execute(instruction: instruction)
        
        if compute.registers == afterRegisters {
            matches += 1
        }
        
        // seti
        compute = Compute(registers: beforeRegisters)
        instruction = Instruction.seti(a: command[1], b: command[2], c: command[3])
        compute.execute(instruction: instruction)
        
        if compute.registers == afterRegisters {
            matches += 1
        }
        
        // gtir
        compute = Compute(registers: beforeRegisters)
        instruction = Instruction.gtir(a: command[1], b: command[2], c: command[3])
        compute.execute(instruction: instruction)
        
        if compute.registers == afterRegisters {
            matches += 1
        }
        
        // gtri
        compute = Compute(registers: beforeRegisters)
        instruction = Instruction.gtri(a: command[1], b: command[2], c: command[3])
        compute.execute(instruction: instruction)
        
        if compute.registers == afterRegisters {
            matches += 1
        }
        
        // gtrr
        compute = Compute(registers: beforeRegisters)
        instruction = Instruction.gtrr(a: command[1], b: command[2], c: command[3])
        compute.execute(instruction: instruction)
        
        if compute.registers == afterRegisters {
            matches += 1
        }
        
        // eqir
        compute = Compute(registers: beforeRegisters)
        instruction = Instruction.eqir(a: command[1], b: command[2], c: command[3])
        compute.execute(instruction: instruction)
        
        if compute.registers == afterRegisters {
            matches += 1
        }
        
        // eqri
        compute = Compute(registers: beforeRegisters)
        instruction = Instruction.eqri(a: command[1], b: command[2], c: command[3])
        compute.execute(instruction: instruction)
        
        if compute.registers == afterRegisters {
            matches += 1
        }
        
        // eqrr
        compute = Compute(registers: beforeRegisters)
        instruction = Instruction.eqrr(a: command[1], b: command[2], c: command[3])
        compute.execute(instruction: instruction)
        
        if compute.registers == afterRegisters {
            matches += 1
        }
        
        print("Matches: \(matches)")
        
        if matches >= 3 {
            threeOrMoreMatches += 1
        }
        
        // Read the blank line, or exit
        guard let blankLine = reader.readLine() else{
            break
        }
        
        print("\(lines): BLANK: \(blankLine)")
        
        lines += 1
    }
    
    print("Three or more matches: \(threeOrMoreMatches)")
} else if mode == .part2 {
    var opCodes: [Int:Set<String>] = [:]
    var lines = 1
    
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
        
        var matches: Set<String> = []
        
        // addr
        var compute = Compute(registers: beforeRegisters)
        var instruction = Instruction.addr(a: command[1], b: command[2], c: command[3])
        compute.execute(instruction: instruction)
        
        if compute.registers == afterRegisters {
            matches.insert("addr")
        }
        
        // addi
        compute = Compute(registers: beforeRegisters)
        instruction = Instruction.addi(a: command[1], b: command[2], c: command[3])
        compute.execute(instruction: instruction)
        
        if compute.registers == afterRegisters {
            matches.insert("addi")
        }
        
        // mulr
        compute = Compute(registers: beforeRegisters)
        instruction = Instruction.mulr(a: command[1], b: command[2], c: command[3])
        compute.execute(instruction: instruction)
        
        if compute.registers == afterRegisters {
            matches.insert("mulr")
        }
        
        // muli
        compute = Compute(registers: beforeRegisters)
        instruction = Instruction.muli(a: command[1], b: command[2], c: command[3])
        compute.execute(instruction: instruction)
        
        if compute.registers == afterRegisters {
            matches.insert("muli")
        }
        
        // banr
        compute = Compute(registers: beforeRegisters)
        instruction = Instruction.banr(a: command[1], b: command[2], c: command[3])
        compute.execute(instruction: instruction)
        
        if compute.registers == afterRegisters {
            matches.insert("banr")
        }
        
        // bani
        compute = Compute(registers: beforeRegisters)
        instruction = Instruction.bani(a: command[1], b: command[2], c: command[3])
        compute.execute(instruction: instruction)
        
        if compute.registers == afterRegisters {
            matches.insert("bani")
        }
        
        // borr
        compute = Compute(registers: beforeRegisters)
        instruction = Instruction.borr(a: command[1], b: command[2], c: command[3])
        compute.execute(instruction: instruction)
        
        if compute.registers == afterRegisters {
            matches.insert("borr")
        }
        
        // bori
        compute = Compute(registers: beforeRegisters)
        instruction = Instruction.bori(a: command[1], b: command[2], c: command[3])
        compute.execute(instruction: instruction)
        
        if compute.registers == afterRegisters {
            matches.insert("bori")
        }
        
        // setr
        compute = Compute(registers: beforeRegisters)
        instruction = Instruction.setr(a: command[1], b: command[2], c: command[3])
        compute.execute(instruction: instruction)
        
        if compute.registers == afterRegisters {
            matches.insert("setr")
        }
        
        // seti
        compute = Compute(registers: beforeRegisters)
        instruction = Instruction.seti(a: command[1], b: command[2], c: command[3])
        compute.execute(instruction: instruction)
        
        if compute.registers == afterRegisters {
            matches.insert("seti")
        }
        
        // gtir
        compute = Compute(registers: beforeRegisters)
        instruction = Instruction.gtir(a: command[1], b: command[2], c: command[3])
        compute.execute(instruction: instruction)
        
        if compute.registers == afterRegisters {
            matches.insert("gtir")
        }
        
        // gtri
        compute = Compute(registers: beforeRegisters)
        instruction = Instruction.gtri(a: command[1], b: command[2], c: command[3])
        compute.execute(instruction: instruction)
        
        if compute.registers == afterRegisters {
            matches.insert("gtri")
        }
        
        // gtrr
        compute = Compute(registers: beforeRegisters)
        instruction = Instruction.gtrr(a: command[1], b: command[2], c: command[3])
        compute.execute(instruction: instruction)
        
        if compute.registers == afterRegisters {
            matches.insert("gtrr")
        }
        
        // eqir
        compute = Compute(registers: beforeRegisters)
        instruction = Instruction.eqir(a: command[1], b: command[2], c: command[3])
        compute.execute(instruction: instruction)
        
        if compute.registers == afterRegisters {
            matches.insert("eqir")
        }
        
        // eqri
        compute = Compute(registers: beforeRegisters)
        instruction = Instruction.eqri(a: command[1], b: command[2], c: command[3])
        compute.execute(instruction: instruction)
        
        if compute.registers == afterRegisters {
            matches.insert("eqri")
        }
        
        // eqrr
        compute = Compute(registers: beforeRegisters)
        instruction = Instruction.eqrr(a: command[1], b: command[2], c: command[3])
        compute.execute(instruction: instruction)
        
        if compute.registers == afterRegisters {
            matches.insert("eqrr")
        }
        
        print("Current Matches: \(matches)")
        
        let finalMatches: Set<String>
        
        if let currentMatches = opCodes[command[0]] {
            finalMatches = currentMatches.intersection(matches)
        } else {
            finalMatches = matches
        }
        
        opCodes[command[0]] = finalMatches
        
        // Read the blank line, or exit
        guard let blankLine = reader.readLine() else{
            break
        }
        
        print("\(lines): BLANK: \(blankLine)")
        
        lines += 1
    }
    
    print("Initial OP codes: \(opCodes)")
    
    var changed = false
    
    repeat {
        changed = false
        
        let allOpCodes = opCodes.keys.sorted()
        
        for opCode in allOpCodes {
            let potentials = opCodes[opCode]!
            
            if potentials.count == 1 {
                let exclusive = potentials.first!
                
                for otherOpCode in allOpCodes {
                    if opCode == otherOpCode {
                        continue
                    }
                    
                    let otherPotentials = opCodes[otherOpCode]!
                    
                    var modifiedOtherPotentials = otherPotentials
                    modifiedOtherPotentials.remove(exclusive)
                    
                    if otherPotentials.count != modifiedOtherPotentials.count {
                        opCodes[otherOpCode] = modifiedOtherPotentials
                        changed = true
                    }
                }
            }
        }
    } while changed
    
    print("Final OP codes: \(opCodes)")
} else if mode == .part3 {
    var compute = Compute()
    
    for line in reader {
        let commandMatch = commandRegex.firstMatch(in: line, options: [], range: NSRange(location: 0, length: line.count))!
        
        let commandOneRange = Range(commandMatch.range(at: 1), in: line)!
        let commandTwoRange = Range(commandMatch.range(at: 2), in: line)!
        let commandThreeRange = Range(commandMatch.range(at: 3), in: line)!
        let commandFourRange = Range(commandMatch.range(at: 4), in: line)!
        
        let command = [
            Int(line[commandOneRange])!,
            Int(line[commandTwoRange])!,
            Int(line[commandThreeRange])!,
            Int(line[commandFourRange])!,
        ]
        
        let instruction = Instruction.from(command)
        compute.execute(instruction: instruction)
    }
    
    print("Final registers: \(compute.registers)")
}
