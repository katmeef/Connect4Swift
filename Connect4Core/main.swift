//
//  main.swift
//  Connect4Core
//
//  Created by katmeef on 2025-05-17.
//

import Foundation

enum Player {
    // 1.  Cases for the enum
    case red
    case yellow
    
    // 2.  Computed property to return the players symbol
    var symbol: Character {
        switch self {
        case .red:
            return "R"
        case .yellow:
            return "Y"
        }
    }
    
    // 3.  Computed property to return display colour name
    var colourName: String {
        switch self {
        case .red:
            return "Red"
        case .yellow:
            return "Yellow"
        }
    }
    
    // 4. Method to get the next player (like a toggle)
    func next() -> Player {
        switch self {
        case .red:
            return .yellow
        case .yellow:
            return .red
        }
    }
}

enum Difficulty {
    case easy, medium, hard, insane
    
    var description: String {
        switch self {
        case .easy: return "Easy"
        case .medium: return "Medium"
        case .hard: return "Hard"
        case .insane: return "Insane"
        }
    }
}

struct GameBoard {
    // 1. 2D array for the board: 6 rows × 7 columns
    let rows: Int
    let columns: Int
    var grid: [[Character]]
    
    init(rows: Int = 6, columns: Int = 7) {
        self.rows = rows
        self.columns = columns
        self.grid = Array(repeating: Array(repeating: Character(" "), count: columns), count: rows)
    }
    // 2. Method to drop a piece into a column
    // Returns: the row where the piece lands, or nil if the column is full
    mutating func dropPiece(in column: Int, for player: Player) -> Int? {
        for row in (0..<rows).reversed() {
            if grid[row][column] == Character(" ") {
                grid[row][column] = player.symbol
                return row
            }
        }
        return nil
    }
    // 3. Method to check for a win
    // Input: the player's symbol or Player enum
    // Output: true/false if win exists
    //    func hasWon(for player: Player) -> Bool {
    //        let symbol = player.symbol
    //        for window in getAllWindows() {
    //            if window[0] == symbol && window[1] == symbol &&
    //                window[2] == symbol && window[3] == symbol {
    //                return true
    //            }
    //        }
    //        return false
    //    }
    //rewriting above more swift-y
    func hasWon(for player: Player) -> Bool {
        let symbol = player.symbol
        return getAllWindows().contains { $0.allSatisfy { $0 == symbol } }
    }
    
    func getAllWindows() -> [[Character]] {
        var windows: [[Character]] = []
        
        // Horizontal
        for row in 0..<rows {
            for col in 0..<(columns - 3) {
                windows.append([grid[row][col], grid[row][col+1], grid[row][col+2], grid[row][col+3]])
            }
        }
        
        // Vertical
        for row in 0..<(rows - 3) {
            for col in 0..<columns {
                windows.append([grid[row][col], grid[row+1][col], grid[row+2][col], grid[row+3][col]])
            }
        }
        
        // Diagonal down-right
        for row in 0..<(rows - 3) {
            for col in 0..<(columns - 3) {
                windows.append([grid[row][col], grid[row+1][col+1], grid[row+2][col+2], grid[row+3][col+3]])
            }
        }
        
        // Diagonal up-right
        for row in 3..<rows {
            for col in 0..<(columns - 3) {
                windows.append([grid[row][col], grid[row-1][col+1], grid[row-2][col+2], grid[row-3][col+3]])
            }
        }
        
        return windows
    }
    
    // 4. Method to check if the board is full
    func isFull() -> Bool {
        return !grid[0].contains(" ")
    }
    
    // 5. Method to reset the board (all cells back to empty)
    mutating func reset() {
        grid = Array(repeating: Array(repeating: " ", count: columns), count: rows)
    }
    
    func printBoard() {
        print("\nMatt's Connect4")
        print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
        for row in grid {
            print("│ " + row.map { String($0) }.joined(separator: " │ ") + " │")
        }
        print("│ 1 │ 2 │ 3 │ 4 │ 5 │ 6 │ 7 │")
        print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
    }
}
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
        // Call AI
        // TODO: Implement AI logic based on difficulty
        print("AI Level (\(level.description)) is thinking... (placeholder)")
        return Int.random(in: 0..<board.columns)
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

playGame()
