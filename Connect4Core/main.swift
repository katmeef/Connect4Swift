//
//  main.swift
//  Connect4Core
//
//  Created by katmeef on 2025-05-17.
//

import Foundation

func takeTurn(currentPlayer: inout Player,
              board: inout GameBoard,
              vsAI: Bool,
              aiPlayer: Player?,
              difficulty: Difficulty?) -> Bool {
    // 1. prompt for move (AI or Human depending on currentPlayer)
    let move = getMove(
        for: currentPlayer,
        using: board,
        vsAI: vsAI,
        aiPlayer: aiPlayer,
        difficulty: difficulty
    )
    // 2. try to drop the piece
    guard board.dropPiece(in: move, for: currentPlayer) != nil else {
        fatalError("Tried to drop a piece in a full column. This shouldn't happen.")
    }
    board.printBoard()
    // 3. check win/draw
    if board.hasWon(for: currentPlayer) {
        print("🎉 \(currentPlayer.colourName) wins!")
        return false
    } else if board.isFull() {
        print("🤝 It's a draw!")
        return false
    } else {
        // 4. switch players
        currentPlayer = currentPlayer.next()
        return true
    }
}

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
