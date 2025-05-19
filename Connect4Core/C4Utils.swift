//
//  C4Utils.swift
//  Connect4Core
//
//  Created by katmeef on 2025-05-18.
//

import Foundation

func promptForGameMode() -> Bool{
    let modeMap: [String: Bool] = [
        "1": true,
        "1-player": true,
        "2": false,
        "2-player": false
    ]
    
    while true {
        print("Play in 1-player or 2-player mode? (Enter 1 or 2): ", terminator: "")
        
        if let input = readLine(),
           let aiMode = modeMap[input.lowercased()] {
            return aiMode
        } else {
            print("Invalid input. Please enter 1 or 2.")
        }
    }
}

func promptForDifficulty() -> Difficulty{
    let difficultyMap: [Character: Difficulty] = [
        "e": .easy,
        "m": .medium,
        "h": .hard,
        "i": .insane
    ]
    
    while true {
        print("Choose a difficulty: Easy (E), Medium (M), Hard (H), or Insane (I): ", terminator: "")
        
        if let input = readLine(), let choice = input.first?.lowercased().first,
           let selected = difficultyMap[choice] {
            print("You chose \(selected.description) difficulty.")
            return selected
        } else {
            print("Invalid choice. Please enter E, M, H, or I.")
        }
    }
}

func promptForPlayerColor() -> Player{
    let playerMap: [Character: Player] = [
        "r": .red,
        "y": .yellow
    ]
    
    while true {
        print("Do you want to play as Red (R) or Yellow (Y)?: ", terminator: "")
        
        if let input = readLine(), let choice = input.first?.lowercased().first,
           let selectedPlayer = playerMap[choice] {
            return selectedPlayer
        } else {
            print("Invalid choice. Please enter R or Y.")
        }
    }
}

func getMove(for player: Player,
             using board: GameBoard,
             vsAI: Bool,
             aiPlayer: Player? = nil,
             difficulty: Difficulty? = nil) -> Int {
    
    
    if vsAI, let level = difficulty, player == aiPlayer {
        print("🧠 AI (\(level.description)) is thinking...")
        return C4AI.getBestMove(board: board, ai: player, difficulty: level)
    } else {
        // Human input
        while true {
            print("\(player.colourName)'s turn. Enter column (1 - 7): ", terminator: "")
            if let input = readLine(), let choice = Int(input), (1...7).contains(choice) {
                let col = choice - 1
                if board.grid[0][col] == " " {
                    return col
                } else {
                    print("Column is full.")
                }
            } else {
                print("Invalid input.")
            }
        }
    }
}

