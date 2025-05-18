//
//  C4AI.swift
//  Connect4Core
//
//  Created by katmeef on 2025-05-18.
//

import Foundation

struct C4AI {
    
    static let depthMap: [Difficulty: Int] = [
        // .easy is handled separately
        .medium: 3,
        .hard: 5,
        .insane: 7
    ]
    
    static func getBestMove(board: GameBoard, ai: Player, difficulty: Difficulty) -> Int {
        // Easy: pick a random valid column
        if difficulty == .easy {
            let validColumns = getValidColumns(from: board)
            guard !validColumns.isEmpty else {
                fatalError("No valid moves available for AI.")
            }
            let chosen = validColumns.randomElement()!
            debugPrint("[AI Easy] Chose column: \(chosen + 1)")
            return chosen
        }

        guard let depth = depthMap[difficulty] else {
            preconditionFailure("Unhandled difficulty level: \(difficulty)")
        }
        
        let (_, bestColumn) = minimax(
            board: board,
            depth: depth,
            alpha: Int.min,
            beta: Int.max,
            maximizing: true,
            ai: ai,
            human: ai.next()
        )
        
        print("[AI \(difficulty.description)] Chose column: \(bestColumn + 1)")
        return bestColumn
    }

    
    private static func minimax(board: GameBoard, depth: Int, alpha: Int, beta: Int, maximizing: Bool, ai: Player, human: Player) -> (Int, Int) {
        // TODO: Minimax algorithm with alpha-beta pruning
        return (0, 0)  // (score, column)
    }
    
    private static func evaluateBoard(_ board: GameBoard, aiPlayer: Player, opponent: Player) -> Int {
        // TODO: Heuristic evaluation function
        return 0
    }
    
    private static func evaluateWindow(_ window: [Character], aiSymbol: Character, opponentSymbol: Character) -> Int {
        // TODO: Heuristic evaluation function
        return 0
    }
    
    private static func getValidColumns(from board: GameBoard) -> [Int] {
        // TODO: Return list of valid columns
        return []
    }
    
    private static func isTerminal(board: GameBoard, ai: Player, human: Player) -> Bool {
        return board.hasWon(for: ai) || board.hasWon(for: human) || board.isFull()
    }
    
    private static func simulateDrop(board: GameBoard, in column: Int, as player: Player) -> GameBoard? {
        var copiedBoard = board
        return copiedBoard.dropPiece(in: column, for: player) != nil ? copiedBoard : nil
    }
}
