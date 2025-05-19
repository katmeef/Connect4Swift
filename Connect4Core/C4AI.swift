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
        
        debugPrint("[AI \(difficulty.description)] Chose column: \(bestColumn + 1)")
        return bestColumn
    }
    
    private static func minimaxLoop(
        board: GameBoard,
        depth: Int,
        alpha: Int,
        beta: Int,
        isMaximizing: Bool,
        currentPlayer: Player,
        ai: Player,
        human: Player,
        comparison: (Int, Int) -> Int,
        betterThan: (Int, Int) -> Bool
    ) -> (Int, Int) {
        var bestEval = isMaximizing ? Int.min : Int.max
        var bestColumn = -1
        var alpha = alpha
        var beta = beta

        for col in 0..<board.columns {
            if board.grid[0][col] == " " {
                if let copy = simulateDrop(board: board, in: col, as: currentPlayer) {
                    let (eval, _) = minimax(
                        board: copy,
                        depth: depth - 1,
                        alpha: alpha,
                        beta: beta,
                        maximizing: !isMaximizing,
                        ai: ai,
                        human: human
                    )

                    if betterThan(eval, bestEval) {
                        bestEval = eval
                        bestColumn = col
                    }

                    if isMaximizing {
                        alpha = comparison(alpha, eval)
                    } else {
                        beta = comparison(beta, eval)
                    }

                    if beta <= alpha {
                        debugPrint("🔪 Pruned branch at column \(col + 1)")
                        break
                    }
                }
            }
        }

        return (bestEval, bestColumn)
    }
    
    private static func minimax(
        board: GameBoard,
        depth: Int,
        alpha: Int,
        beta: Int,
        maximizing: Bool,
        ai: Player,
        human: Player
    ) -> (Int, Int) {
        // Base cases
        if board.hasWon(for: ai) {
            return (100_000, -1)
        } else if board.hasWon(for: human) {
            return (-100_000, -1)
        } else if depth == 0 || board.isFull() {
            let score = evaluateBoard(board, aiPlayer: ai, opponent: human)
            debugPrint("📄 Leaf heuristic: \(score)")
            return (score, -1)
        }

        // Recursive case
        if maximizing {
            return minimaxLoop(
                board: board,
                depth: depth,
                alpha: alpha,
                beta: beta,
                isMaximizing: true,
                currentPlayer: ai,
                ai: ai,
                human: human,
                comparison: max,
                betterThan: { $0 > $1 }
            )
        } else {
            return minimaxLoop(
                board: board,
                depth: depth,
                alpha: alpha,
                beta: beta,
                isMaximizing: false,
                currentPlayer: human,
                ai: ai,
                human: human,
                comparison: min,
                betterThan: { $0 < $1 }
            )
        }
    }
    
    private static func evaluateBoard(
        _ board: GameBoard, aiPlayer: Player,
        opponent: Player) -> Int {
            var score: Int = 0
            for window in board.getAllWindows() {
                score += evaluateWindow(window, aiSymbol: aiPlayer.symbol, opponentSymbol: opponent.symbol)
            }
            return score
        }
    
    private static func evaluateWindow(
        _ window: [Character], aiSymbol: Character,
        opponentSymbol: Character) -> Int {
            var aiCount: Int = 0
            var opponentCount: Int = 0
            var emptyCount: Int = 0
            for char in window {
                if char == aiSymbol {
                    aiCount += 1
                } else if char == opponentSymbol {
                    opponentCount += 1
                } else {
                    emptyCount += 1
                }
            }
            if aiCount == 3 && emptyCount == 1 {
                return 10000
            }
            else if opponentCount == 3 && emptyCount == 1 {
                return -10000
            }
            else if aiCount == 2 && emptyCount == 2 {
                return 100
            }
            else if opponentCount == 2 && emptyCount == 2 {
                return -100
            }
            // Mixed window -- least important
            else if aiCount > 0 && opponentCount > 0 {
                return -5
            }
            else {
                return 0
            }
        }
    
    private static func getValidColumns(
        from board: GameBoard) -> [Int] {
            var validColumns: [Int] = []
            for i in 0..<board.columns {
                if board.grid[0][i] == " " {
                    validColumns.append(i)
                }
            }
            return validColumns
        }
    
    private static func isTerminal(
        board: GameBoard, ai: Player,
        human: Player) -> Bool {
            return board.hasWon(for: ai) || board.hasWon(for: human) || board.isFull()
        }
    
    private static func simulateDrop(
        board: GameBoard, in column: Int,
        as player: Player) -> GameBoard? {
            var copiedBoard = board
            return copiedBoard.dropPiece(in: column, for: player) != nil ? copiedBoard : nil
        }
}
