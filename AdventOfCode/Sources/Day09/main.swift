import Foundation

class Marble {
    var value: Int
    
    var ccw: Marble!
    var cw: Marble!
    
    init(value: Int) {
        self.value = value
    }
}

func printCircle(current: Marble) {
    // Determine the lowest number
    var temp = current
    var lowest: Marble = current
    
    while true {
        if temp.value < lowest.value {
            lowest = temp
        }
        
        temp = temp.cw
        
        if temp === current {
            break
        }
    }
    
    temp = lowest
    var builder = ""
    
    while true {
        if temp === current {
            builder += "(\(temp.value)) "
        } else {
            builder += "\(temp.value) "
        }
        
        temp = temp.cw
        
        if temp === lowest {
            break
        }
    }
    
    print(builder)
}

func run(players: Int, lastMarble: Int) -> Int {
    // Build the scores, current marble, and index
    var scores: [Int] = [Int](repeating: 0, count: players)
    var marbleIndex = 1
    var playerIndex = 0
    
    var currentMarble = Marble(value: 0)
    currentMarble.ccw = currentMarble
    currentMarble.cw = currentMarble
    
    while marbleIndex <= lastMarble {
        // If we're divisible by 23, then start scoring
        if marbleIndex % 23 == 0 {
            scores[playerIndex] += marbleIndex
            
            let other = currentMarble.ccw.ccw.ccw.ccw.ccw.ccw.ccw!
            let otherLeft = other.ccw!
            let otherRight = other.cw!
            
            otherLeft.cw = otherRight
            otherRight.ccw = otherLeft
            
            scores[playerIndex] += other.value
            currentMarble = otherRight
        } else {
            let newMarble = Marble(value: marbleIndex)
            
            let left = currentMarble.cw!
            let right = currentMarble.cw.cw!
            
            left.cw = newMarble
            newMarble.ccw = left
            
            right.ccw = newMarble
            newMarble.cw = right
            
            currentMarble = newMarble
        }
        
        // printCircle(current: currentMarble)
        
        // Increment
        playerIndex = (playerIndex + 1) % players
        marbleIndex += 1
    }
    
    return scores.max()!
}



// 9 playera; last marble is worth 25 points: hgiht score is 32
var highScore = run(players: 9, lastMarble: 25)
print("High score (9, 25): \(highScore)")

// 10 players; last marble is worth 1618 points: high score is 8317
highScore = run(players: 10, lastMarble: 1618)
print("High score (10, 1618): \(highScore)")

// 13 players; last marble is worth 7999 points: high score is 146373
highScore = run(players: 13, lastMarble: 7999)
print("High score (13, 7999): \(highScore)")

// 17 players; last marble is worth 1104 points: high score is 2764
highScore = run(players: 17, lastMarble: 1104)
print("High score (17, 1104): \(highScore)")

// 21 players; last marble is worth 6111 points: high score is 54718
highScore = run(players: 21, lastMarble: 6111)
print("High score (21, 6111): \(highScore)")

// 30 players; last marble is worth 5807 points: high score is 37305
highScore = run(players: 30, lastMarble: 5807)
print("High score (30, 5807): \(highScore)")

// 476 players; last marble is worth 71431 points
highScore = run(players: 476, lastMarble: 71431)
print("High score (476, 71431): \(highScore)")

// 476 players; last marble is worth 7143100 points
highScore = run(players: 476, lastMarble: 7143100)
print("High score (476, 7143100): \(highScore)")
