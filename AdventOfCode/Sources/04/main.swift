import Foundation
import Utilities

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
dateFormatter.timeZone = TimeZone(identifier: "GMT")!

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
print("Days in order:")
for day in days {
    print("\(day)")
}

print("\n--------\n")


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

for (day, total) in totals {
    print("Guard: \(day.guardID) -> \(total)")
}

print("\nMax Sleeper: \(maxSleepId) = \(maxSleep)")

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

// Result #1
print("Max minute: \(maxMinute) (\(maxTotal))")

let finalGuardID = Int(maxSleepId)! * maxMinute
print("#1 Guard ID: \(finalGuardID)")

// Collect all of the sleep ranges per guard
var allSleepsPerGuard: [String:[Range<Int>]] = [:]

for day in days {
    var ranges: [Range<Int>]
    if let currentRange = allSleepsPerGuard[day.guardID] {
        ranges = currentRange
    } else {
        ranges = []
    }
    
    ranges.append(contentsOf: day.sleeps)
    allSleepsPerGuard[day.guardID] = ranges
}

print("\nSleeps Per Guard:")
for (guardID, sleeps) in allSleepsPerGuard {
    print("\(guardID): \(sleeps)")
}

// Build heat maps for each guard to fill with their sleeps
var sleepHeatMaps: [String:[Int]] = [:]

var maxGuardID = ""
var maxSleepTime = Int.min
var maxSleepTimeCount = Int.min

for (guardID, sleeps) in allSleepsPerGuard {
    var heatMap = [Int](repeating: 0, count: 60)
    
    for sleep in sleeps {
        for idx in sleep {
            heatMap[idx] += 1
            
            if heatMap[idx] > maxSleepTimeCount {
                maxGuardID = guardID
                maxSleepTime = idx
                maxSleepTimeCount = heatMap[idx]
            }
        }
    }
    
    sleepHeatMaps[guardID] = heatMap
}

// Debug
print("\nHeat Maps:")
for (guardID, heatMap) in sleepHeatMaps {
    let id = guardID.padding(toLength: 4, withPad: " ", startingAt: 0)
    print("\(id): \(heatMap)")
}

// Result #2
print("\n#2 Max Sleep Guard: \(maxGuardID) -> \(maxSleepTime)")

let maxSleepID = Int(maxGuardID)! * maxSleepTime
print("#2 Max Sleep ID: \(maxSleepID)")

// Draw the heatmap
let fontSize: CGFloat = 11.0
let labelWidth: CGFloat = 40.0
let squareSize: CGFloat = 16.0

let canvasWidth: CGFloat = (squareSize * 60.0) + labelWidth
let canvasHeight: CGFloat = squareSize * CGFloat(sleepHeatMaps.keys.count)

let maxColorValue: CGFloat = CGFloat(maxSleepTimeCount)

let canvas = Canvas(width: Int(canvasWidth), height: Int(canvasHeight))
canvas.draw { (ctx, canvas) in
    let fullRect = CGRect(x: 0.0, y: 0.0, width: canvasWidth, height: canvasHeight)
    ctx.addRect(fullRect)
    ctx.setFillColor(CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
    ctx.fillPath()
    
    for (idx, guardID) in sleepHeatMaps.keys.sorted().enumerated() {
        let heatMap = sleepHeatMaps[guardID]!
        
        let y = squareSize * CGFloat(idx)
        
        // Draw the ID
        let font = CTFontCreateWithName("Menlo-Regular" as CFString, fontSize, nil)
        let attributes = [kCTFontAttributeName:font] as CFDictionary
        
        let fontRect = CTFontGetBoundingBox(font)
        let midHeight = (squareSize / 2.0) - (fontRect.height / 2.0)
        
        let path = CGMutablePath()
        path.addRect(CGRect(x: 4.0, y: y + midHeight, width: labelWidth, height: fontRect.height))
        
        let string = CFAttributedStringCreate(kCFAllocatorDefault, guardID as CFString, attributes)!
        let frameSetter = CTFramesetterCreateWithAttributedString(string)
        let frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, guardID.count), path, nil)
        
        CTFrameDraw(frame, ctx)
        
        ctx.saveGState()
        
        
        for xOffset in 0 ..< 60 {
            let x = (squareSize * CGFloat(xOffset)) + labelWidth
            
            let color: CGColor
            if heatMap[xOffset] == maxSleepTimeCount {
                color = CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            } else {
                let redValue: CGFloat = 1.0
                let greenValue: CGFloat = CGFloat(heatMap[xOffset]) / maxColorValue
                let blueValue: CGFloat = CGFloat(heatMap[xOffset]) / maxColorValue
                
                color = CGColor(red: redValue, green: greenValue, blue: blueValue, alpha: 1.0)
            }
            
            let rect = CGRect(x: x, y: y, width: squareSize, height: squareSize)
            ctx.addRect(rect)
            ctx.setFillColor(color)
            
            ctx.fillPath()
            
            if heatMap[xOffset] == maxSleepTimeCount {
                let strokeColor = CGColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 1.0)
                
                ctx.addRect(rect)
                ctx.setLineWidth(3.0)
                ctx.setStrokeColor(strokeColor)
                ctx.strokePath()
            }
        }
        
        ctx.restoreGState()
    }
}

canvas.save(path: "./04-heat-map.png")
