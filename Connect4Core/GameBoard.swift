//
//  GameBoard.swift
//  Connect4Core
//
//  Created by katmeef on 2025-05-18.
//

import Foundation

public struct GameBoard {
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
