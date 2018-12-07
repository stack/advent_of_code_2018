import Foundation
import LineReader

// Get the input
let stdin = FileHandle.standardInput
let reader = LineReader(handle: stdin)

// Create storage for all of the steps, and the dependency graph
let regex = try! NSRegularExpression(pattern: "Step (.+) must be finished before step (.+) can begin", options: [])

var allSteps: Set<String> = []
var dependencies: [String:Set<String>] = [:]

// Build the steps and dependencies
for line in reader {
    // Extract the two step names
    guard let match = regex.firstMatch(in: line, options: [], range: NSRange(location: 0, length: line.count)) else {
        fatalError("Failed to match line")
    }
    
    let oneRange = Range(match.range(at: 1), in: line)!
    let one = String(line[oneRange])
    
    let twoRange = Range(match.range(at: 2), in: line)!
    let two = String(line[twoRange])
    
    // Track all of the step names
    allSteps.insert(one)
    allSteps.insert(two)
    
    // Insert the dependency in to the dependency graph
    var dependentSteps: Set<String>
    
    if let steps = dependencies[two] {
        dependentSteps = steps
        
    } else {
        dependentSteps = []
    }
    
    dependentSteps.insert(one)
    dependencies[two] = dependentSteps
}

// Debug
let allStepsArray = Array(allSteps).sorted()
print("All Steps: \(allStepsArray)")

for step in allStepsArray {
    if let dependentSteps = dependencies[step] {
        let dependentStepsString = dependentSteps.sorted().joined(separator: ", ")
        print("\(step) -> \(dependentStepsString)")
    } else {
        print("\(step) *")
    }
}

print()

// MARK: - Part 1

// Build a list of the roots and put the at the start of the "to visit" list
var toVisit: [String] = allSteps.sorted().filter { !dependencies.keys.contains($0) }.sorted()

// Continue looping through the "to visit" list, refilling as needed
var visited: Set<String> = []
var finalOrder = ""

while !toVisit.isEmpty {
    // Move the current to the visited list
    let current = toVisit.removeFirst()
    finalOrder += current
    visited.insert(current)
    
    print("R: \(finalOrder), V: \(visited), Q: \(toVisit)")
    
    // Find all steps that haven't been visited and all of their dependencies are met
    for (step, dependentSteps) in dependencies {
        // Have we already seen this one?
        guard !visited.contains(step) else {
            continue
        }
        
        // Are all of this one's dependencies met?
        if !toVisit.contains(step) && dependentSteps.isSubset(of: visited) {
            toVisit.append(step)
            toVisit.sort()
        }
    }
}

guard finalOrder.count == allSteps.count else {
    fatalError("Did not process all steps")
}

print("Order: \(finalOrder)")
print()

// MARK: - Part 2

struct Task {
    let step: String
    let completedAt: Int
}

extension Task: CustomStringConvertible {
    var description: String {
        return "\(step): \(completedAt)"
    }
}

// Build the worker lists and steps per the input
let isExample = allSteps.count == 6
let additionalTime = isExample ? 0 : 60
let numberOfWorkers = isExample ? 2 : 5

var workers: [Task?] = [Task?](repeating: nil, count: numberOfWorkers)

// Build a list of the roots and put the at the start of the "to visit" list
toVisit = allSteps.sorted().filter { !dependencies.keys.contains($0) }.sorted()

// Continue looping through the "to visit" list, refilling as needed
visited = []
finalOrder = ""
var currentTime = 0

let workersHeader = (1 ... numberOfWorkers).map(String.init).joined(separator: "  ")
print("Second | \(workersHeader) | Done")

while finalOrder.count != allSteps.count {
    // Did any work complete at this time?
    var completed: [String] = []
    
    for idx in 0 ..< numberOfWorkers {
        if let task = workers[idx], task.completedAt == currentTime {
            completed.append(task.step)
            workers[idx] = nil
        }
    }
    
    // Process completed work to determine next steps to visit
    if !completed.isEmpty {
        for step in completed.sorted() {
            finalOrder += step
            visited.insert(step)
        }
        
        let inProcess = workers.compactMap { $0 == nil ? nil : $0!.step }
        
        for (step, dependentSteps) in dependencies {
            // Have we already seen this one?
            guard !visited.contains(step) else {
                continue
            }
            
            // Are we working on this one?
            guard !inProcess.contains(step) else {
                continue
            }
            
            // Are all of this one's dependencies met?
            if !toVisit.contains(step) && dependentSteps.isSubset(of: visited) {
                toVisit.append(step)
                toVisit.sort()
            }
        }
    }
    
    // Schedule work if it's available
    for idx in 0 ..< numberOfWorkers {
        if workers[idx] == nil {
            if !toVisit.isEmpty {
                let step = toVisit.removeFirst()
                let asciiValue = step.unicodeScalars.first!.value
                let completedAt = currentTime + additionalTime + Int(asciiValue - 64)
                
                workers[idx] = Task(step: step, completedAt: completedAt)
            }
        }
    }
    
    // Output
    let timeString = String(currentTime).padding(toLength: 6, withPad: " ", startingAt: 0)
    let workersString = workers.map { $0 == nil ? "." : $0!.step }.joined(separator: "  ")
    print("\(timeString) | \(workersString) | \(finalOrder)")
    
    // Increment
    currentTime += 1
}
