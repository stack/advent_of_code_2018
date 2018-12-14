import Foundation

class ScoreBoard {
    private var scores: [Int]
    private var elf1: Int
    private var elf2: Int
    private var steps: Int
    
    var printSteps: Bool = false
    
    init() {
        scores = [3, 7]
        elf1 = 0
        elf2 = 1
        steps = 0
    }
    
    func finalScore(after: Int) -> Int {
        if scores.count < (after + 10) {
            return 0
        } else {
            let final = scores[after ..< (after + 10)]
            return final.reduce(0) { ($0 * 10) + $1 }
        }
        
    }
    
    func printScoreBoard() {
        var builder = ""
        
        for (idx, score) in scores.enumerated() {
            if idx == elf1 {
                builder += "(\(score))"
            } else if idx == elf2 {
                builder += "[\(score)]"
            } else {
                builder += " \(score) "
            }
        }
        
        print(builder)
    }
    
    func reset() {
        scores = [3, 7]
        elf1 = 0
        elf2 = 1
        steps = 0
    }
    
    func step() {
        let result = scores[elf1] + scores[elf2]
        let tens = result / 10
        let ones = result % 10
        
        if tens != 0 {
            scores.append(tens)
        }
        
        scores.append(ones)
        
        elf1 = (elf1 + scores[elf1] + 1) % scores.count
        elf2 = (elf2 + scores[elf2] + 1) % scores.count
        
        if printSteps {
            printScoreBoard()
        }
        
        steps += 1
    }
    
    func step(until: Int) {
        while scores.count < (until + 10) {
            step()
        }
    }
    
    func recipes(pattern: [Int]) -> Int {
        while true {
            if scores.count >= pattern.count + 3 {
                for idx in (scores.count - pattern.count - 3) ..< (scores.count - pattern.count) {
                    let scoresSlice = Array(scores[idx ..< (idx + pattern.count)])
                    
                    if scoresSlice == pattern {
                        return idx
                    }
                }
            }
            
            step()
        }
    }
}

let scoreBoard = ScoreBoard()
scoreBoard.printScoreBoard()

scoreBoard.reset()
scoreBoard.step(until: 9)
var finalScore = scoreBoard.finalScore(after: 9)
print("Final Score After 9: \(finalScore)")
assert(finalScore == 5158916779)

print()

scoreBoard.reset()
scoreBoard.step(until: 5)
finalScore = scoreBoard.finalScore(after: 5)
print("Final Score After 5: \(finalScore)")
assert(finalScore == 0124515891)

print()

scoreBoard.reset()
scoreBoard.step(until: 18)
finalScore = scoreBoard.finalScore(after: 18)
print("Final Score After 18: \(finalScore)")
assert(finalScore == 9251071085)

print()

scoreBoard.reset()
scoreBoard.step(until: 2018)
finalScore = scoreBoard.finalScore(after: 2018)
print("Final Score After 2018: \(finalScore)")
assert(finalScore == 5941429882)

print()

scoreBoard.reset()
scoreBoard.step(until: 607331)
finalScore = scoreBoard.finalScore(after: 607331)
print("Final Score After 607331: \(finalScore)")

print()

scoreBoard.reset()
var recipes = scoreBoard.recipes(pattern: [5,1,5,8,9])
print("Recipes for 51589: \(recipes)")
assert(recipes == 9)

print()

scoreBoard.reset()
recipes = scoreBoard.recipes(pattern: [0,1,2,4,5])
print("Recipes for 01245: \(recipes)")
assert(recipes == 5)

print()

scoreBoard.reset()
recipes = scoreBoard.recipes(pattern: [9,2,5,1,0])
print("Recipes for 92510: \(recipes)")
assert(recipes == 18)

print()

scoreBoard.reset()
recipes = scoreBoard.recipes(pattern: [5,9,4,1,4])
print("Recipes for 59414: \(recipes)")
assert(recipes == 2018)

print()

scoreBoard.reset()
recipes = scoreBoard.recipes(pattern: [6,0,7,3,3,1])
print("Recipes for 607331: \(recipes)")
