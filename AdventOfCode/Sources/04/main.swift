import Foundation
import LineReader

struct Day {
    let guardID: String
    let date: Date
    
    let start: Int
    var sleeps: [Range<Int>]
    
    var minutesAsleep: Int {
        return sleeps.reduce(0) { $0 + ($1.endIndex - $1.startIndex)}
    }
}

extension Day: CustomStringConvertible {
    var description: String {
        let allSleeps = sleeps.reduce("") { "\($0)\($1) " }
        let id = guardID.padding(toLength: 4, withPad: " ", startingAt: 0)
        return "Guard #\(id) - \(date): \(allSleeps) = \(minutesAsleep)"
    }
}

extension Day: Equatable {
    static func == (lhs: Day, rhs: Day) -> Bool {
        return lhs.guardID == rhs.guardID
    }
}

extension Day: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(guardID)
    }
}

// Get and sort the input
let stdin = FileHandle.standardInput
let reader = LineReader(handle: stdin)
let logs = reader.sorted()

// Run the lines, building guards and their ranges
let guardRegex = try! NSRegularExpression(pattern: "\\[(\\d{4}-\\d{2}-\\d{2}) (\\d{2}):(\\d{2})\\] Guard #(\\d+)")
let asleepRegex = try! NSRegularExpression(pattern: ":(\\d{2})\\] falls asleep")
let awakeRegex = try! NSRegularExpression(pattern: ":(\\d{2})\\] wakes up")

var day: Day? = nil
var asleep: Int? = nil
var awake: Int? = nil

var days: [Day] = []

let dateFormatter = DateFormatter()
dateFormatter.dateFormat = "yyyy-MM-dd"

var oneDay = DateComponents()
oneDay.day = 1

let calendar = Calendar.current

for log in logs {
    let logRange = NSRange(location: 0, length: log.count)
    
    if let guardMatch = guardRegex.firstMatch(in: log, options: [], range: logRange) {
        // Store the previous guard
        if let previousDay = day {
            days.append(previousDay)
        }
        
        // Start a new guard
        let dateRange = Range(guardMatch.range(at: 1), in: log)!
        let dateString = String(log[dateRange])
        var date = dateFormatter.date(from: dateString)!
        
        let hourRange = Range(guardMatch.range(at: 2), in: log)!
        let hour = Int(log[hourRange])!
        
        if hour != 0 {
            date = calendar.date(byAdding: oneDay, to: date)!
        }
        
        let minuteRange = Range(guardMatch.range(at: 3), in: log)!
        let minute = Int(log[minuteRange])!
        
        let start = (hour == 0) ? minute : minute - 60
        
        let idRange = Range(guardMatch.range(at: 4), in: log)!
        let id = String(log[idRange])
        
        day = Day(guardID: id, date: date, start: start, sleeps: [])
    } else if let asleepMatch = asleepRegex.firstMatch(in: log, options: [], range: logRange) {
        let minuteRange = Range(asleepMatch.range(at: 1), in: log)!
        let minute = Int(log[minuteRange])!
        
        asleep = minute
    } else if let awakeMatch = awakeRegex.firstMatch(in: log, options: [], range: logRange) {
        let minuteRange = Range(awakeMatch.range(at: 1), in: log)!
        let minute = Int(log[minuteRange])!
        
        awake = minute
        
        guard let begin = asleep, let end = awake else {
            fatalError("Ended up without an asleep or awake")
        }
        
        let range = begin ..< end
        day!.sleeps.append(range)
    } else {
        fatalError("Failed to parse line \"(log)\"")
    }
}

// Store the last guard
if let previousDay = day {
    days.append(previousDay)
}

// Debug
for day in days {
    print("\(day)")
}

// Find the guard with the most sleep
var totals: [Day:Int] = [:]
var maxSleep: Int = Int.min
var maxSleepId: String = ""

for day in days {
    let currentTotal: Int
    if let total = totals[day] {
        currentTotal = total + day.minutesAsleep
    } else {
        currentTotal = day.minutesAsleep
    }
    
    totals[day] = currentTotal
    
    if currentTotal > maxSleep {
        maxSleep = currentTotal
        maxSleepId = day.guardID
    }
}

print("Max Sleeper: \(maxSleepId) = \(maxSleep)")

// Determine the minute the guard was asleep the most
var dayEntries = days.filter { $0.guardID == maxSleepId }
var sleepMinuteTotals: [Int:Int] = [:]

var maxTotal = Int.min
var maxMinute = Int.min

for day in dayEntries {
    for sleep in day.sleeps {
        for minute in Array(sleep) {
            let currentTotal: Int
            if let minuteTotal = sleepMinuteTotals[minute] {
                currentTotal = minuteTotal + 1
            } else {
                currentTotal = 1
            }
            
            sleepMinuteTotals[minute] = currentTotal
            
            if currentTotal > maxTotal {
                maxTotal = currentTotal
                maxMinute = minute
            }
        }
    }
}

print("Max minute: \(maxMinute) (\(maxTotal))")
