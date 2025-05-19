//
//  GameSetupView.swift
//  Connect4GUI
//
//  Created by katmeef on 2025-05-19.
//

import SwiftUI

struct GameSetupView: View {
    @State private var isVsAI = true
    @State private var humanPlayer: Player = .red
    @State private var difficulty: Difficulty = .medium
    @State private var startGame = false
    @State private var pendingSettings: GameSettings? = nil

    var body: some View {
        NavigationStack {
            Form {
                // MARK: - Game Mode
                Section(header: Text("Game Mode")) {
                    Picker("Mode", selection: $isVsAI) {
                        Text("1 Player vs AI").tag(true)
                        Text("2 Players").tag(false)
                    }
                    .pickerStyle(.segmented)
                }

                // MARK: - Color Choice
                if isVsAI {
                    Section(header: Text("Choose Your Color")) {
                        Picker("You play as", selection: $humanPlayer) {
                            Text("Red").tag(Player.red)
                            Text("Yellow").tag(Player.yellow)
                        }
                        .pickerStyle(.segmented)
                    }

                    // MARK: - Difficulty
                    Section(header: Text("AI Difficulty")) {
                        Picker("Difficulty", selection: $difficulty) {
                            ForEach(Difficulty.allCases, id: \.self) { level in
                                Text(level.description).tag(level)
                            }
                        }
                        .pickerStyle(.inline)
                    }
                }

                // MARK: - Start Game Button
                Section {
                    Button("Start Game") {
                        pendingSettings = GameSettings(
                            isVsAI: isVsAI,
                            humanPlayer: humanPlayer,
                            aiDifficulty: difficulty
                        )
                    }
                }
            }
            .navigationTitle("Connect 4 Setup")
            .navigationDestination(item: $pendingSettings) { settings in
                ContentView(settings: settings)
        }
        }
    }
}

#Preview {
    GameSetupView()
}
