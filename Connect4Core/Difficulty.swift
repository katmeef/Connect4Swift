//
//  Difficulty.swift
//  Connect4Core
//
//  Created by katmeef on 2025-05-18.
//

import Foundation

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
