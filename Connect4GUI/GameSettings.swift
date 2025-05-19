//
//  GameSettings.swift
//  Connect4GUI
//
//  Created by katmeef on 2025-05-19.
//

import Foundation

struct GameSettings: Hashable, Identifiable {
    var isVsAI: Bool = true
    var humanPlayer: Player = .red
    var aiDifficulty: Difficulty = .medium

    var id: String {
        "\(isVsAI)-\(humanPlayer.colourName)-\(aiDifficulty.rawValue)"
    }
}
