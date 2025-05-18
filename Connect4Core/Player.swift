//
//  Player.swift
//  Connect4Core
//
//  Created by katmeef on 2025-05-18.
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
