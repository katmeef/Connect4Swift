//
//  main.swift
//  Connect4Core
//
//  Created by katmeef on 2025-05-17.
//

import Foundation

func playGame() {
    var board = GameBoard()
    var aiPlayer: Player?
    var humanPlayer: Player?
    var difficulty: Difficulty?
    var currentPlayer: Player = .red
    print("Welcome to Connect 4!")
    
    let vsAI = promptForGameMode()
    if vsAI{
        difficulty = promptForDifficulty()
        humanPlayer = promptForPlayerColor()
        aiPlayer = humanPlayer?.next()
    }
    board.printBoard()
    while true {
        let continueGame = takeTurn(
            currentPlayer: &currentPlayer,
            board: &board,
            vsAI: vsAI,
            aiPlayer: aiPlayer,
            difficulty: difficulty
        )
        
        if !continueGame {
            break
        }
    }
}

playGame()
