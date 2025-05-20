import SwiftUI
import AVFoundation
import UIKit

struct ContentView: View {
    let rows = 6
    let columns = 7
    let cellSpacing: CGFloat = 4
    
    let settings: GameSettings
    
    @State private var board = GameBoard()
    @State private var currentPlayer: Player
    @State private var animatingCell: (row: Int, col: Int)? = nil
    @State private var dropInProgress = false
    @State private var winner: Player? = nil
    @State private var isDraw: Bool = false
    @State private var fallingOffset: CGFloat = -1000
    @State private var gameOver = false
    @State private var aiIsThinking = false
    
    @Environment(\.presentationMode) var presentationMode
    
    let vsAI: Bool
    let aiPlayer: Player
    let difficulty: Difficulty
    
    
    init(settings: GameSettings) {
        self.settings = settings
        _currentPlayer = State(initialValue: settings.isVsAI ? settings.humanPlayer : .red)
        
        // Safe to access now
        self.vsAI = settings.isVsAI
        self.aiPlayer = settings.humanPlayer.next()
        self.difficulty = settings.aiDifficulty
    }
    
    var body: some View {
        GeometryReader { geometry in
            let totalSpacing = CGFloat(columns - 1) * cellSpacing
            let availableWidth = geometry.size.width * 0.9
            let availableHeight = geometry.size.height * 0.75

            let maxCellWidth = (availableWidth - totalSpacing) / CGFloat(columns)
            let maxCellHeight = (availableHeight - CGFloat(rows - 1) * cellSpacing) / CGFloat(rows)

            let cellSize = min(maxCellWidth, maxCellHeight)

            let gridWidth = CGFloat(columns) * cellSize + totalSpacing
            let boardHeight = CGFloat(rows) * cellSize + CGFloat(rows - 1) * cellSpacing
            let isLandscape = geometry.size.width > geometry.size.height
            
            VStack(spacing: 20) {
                if isLandscape {
                    HStack {
                        Spacer()
                        VStack(spacing: 4) {
                            Text("Connect 4")
                                .font(.largeTitle)
                        }
                        .frame(width: gridWidth, alignment: .center)
                        Spacer()
                    }

                    HStack(alignment: .center, spacing: 12) {
                        VStack {
                            gameBoardView(gridWidth: gridWidth, boardHeight: boardHeight, cellSize: cellSize)
                        }
                        .frame(width: gridWidth)

                        statusPanel()
                            .frame(minWidth: 200, idealWidth: 220, maxWidth: 260)
                    }

                    Spacer()
                } else {
                    VStack {
                        Spacer(minLength: 40)

                        Text("Connect 4")
                            .font(.largeTitle)

                        gameBoardView(gridWidth: gridWidth, boardHeight: boardHeight, cellSize: cellSize)

                        ZStack {
                            Color.clear.frame(height: 60) // 👈 Reserve space even when no status text
                            statusPanel()
                        }

                        Spacer()
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
            .navigationBarBackButtonHidden(true)
            
        }
    }
    
    private func gameBoardView(gridWidth: CGFloat, boardHeight: CGFloat, cellSize: CGFloat) -> some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(uiColor: .systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.secondary, lineWidth: 2)
                )

            gridView(cellSize: cellSize)
                .padding(10)
                .disabled(inputLocked)
                .opacity(inputLocked ? 0.5 : 1.0)

            if let (row, col) = animatingCell {
                let xOffset = CGFloat(col) * (cellSize + cellSpacing) + 10
                let yFinal = CGFloat(row) * (cellSize + cellSpacing) + 10

                Circle()
                    .fill(color(for: currentPlayer.symbol))
                    .frame(width: cellSize, height: cellSize)
                    .offset(x: xOffset, y: fallingOffset)
                    .onAppear {
                        fallingOffset = -UIScreen.main.bounds.height
                        withAnimation(.easeOut(duration: 0.35)) {
                            fallingOffset = yFinal
                        }
                    }
            }
        }
        .frame(width: gridWidth, height: boardHeight, alignment: .center)
        .frame(maxWidth: .infinity, alignment: .center) // ✅ Center horizontally
    }
    
    @ViewBuilder
    private func statusPanel() -> some View {
        VStack(spacing: 12) {
            if aiIsThinking {
                Text("🤖 AI is thinking…")
                    .foregroundColor(.gray)
                    .font(.subheadline)
            }

            if let winner {
                Text("\(winner.colourName) Wins!")
                    .font(.title2)
                    .foregroundColor(color(for: winner.symbol))
            }

            if isDraw {
                Text("🤝 It's a draw!")
                    .font(.title2)
                    .foregroundColor(.gray)
            }

            if winner != nil || isDraw {
                Button("Play Again") {
                    board = GameBoard()
                    currentPlayer = settings.isVsAI ? settings.humanPlayer : .red
                    animatingCell = nil
                    winner = nil
                    isDraw = false
                }
                Button("Back to Setup") {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
        .padding()
    }
    
    private func isAnimatingCell(row: Int, col: Int) -> Bool {
        animatingCell?.row == row && animatingCell?.col == col
    }
    
    // MARK: - Grid UI
    private func gridView(cellSize: CGFloat) -> some View {
        VStack(spacing: cellSpacing) {
            ForEach(0..<rows, id: \.self) { row in
                HStack(spacing: cellSpacing) {
                    ForEach(0..<columns, id: \.self) { col in
                        Circle()
                            .fill(isAnimatingCell(row: row, col: col) ? Color.gray.opacity(0.3) : color(for: board.grid[row][col]))
                            .frame(width: cellSize, height: cellSize)
                            .onTapGesture {
                                handleTap(column: col)
                            }
                    }
                }
            }
        }
    }
    
    // MARK: - Drop Handler
    private func handleTap(column: Int) {
        guard winner == nil else { return }
        guard !inputLocked else { return }  // 👈 NEW: prevent input during animation or AI turn
        guard !board.isFull() || winner != nil else { return }
        
        if let row = board.dropPiece(in: column, for: currentPlayer) {
            animatingCell = (row, column)
            
            // Predict outcome BEFORE animation
            let isWin = board.hasWon(for: currentPlayer)
            let isBoardFull = board.isFull()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                animatingCell = nil
                
                if isWin {
                    winner = currentPlayer
                    playSystemWinFeedback()
                } else if isBoardFull {
                    isDraw = true
                    playSystemWinFeedback()
                } else {
                    AudioServicesPlaySystemSound(1104) // Tock sound
                    currentPlayer = currentPlayer.next()
                    // 👇 Trigger AI if needed
                    if vsAI && currentPlayer == aiPlayer {
                        performAIMove()
                    }
                }
            }
        }
    }
    
    // MARK: - Bounce Animation
    private func bounce(after delay: Double = 0.35) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            withAnimation(.interpolatingSpring(stiffness: 70, damping: 9)) {
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.interpolatingSpring(stiffness: 50, damping: 8)) {
                }
            }
        }
    }
    
    // MARK: - Piece Color
    private func color(for symbol: Character) -> Color {
        switch symbol {
        case "R": return .red
        case "Y": return .yellow
        default: return .gray.opacity(0.3)
        }
    }
    
    func playSystemWinFeedback() {
        // Default "new mail" sound (just an example, can be replaced with others)
        AudioServicesPlaySystemSound(1004) // Choose another ID if you want a different effect
        
        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    private func performAIMove() {
        aiIsThinking = true
        let startTime = Date()
        
        DispatchQueue.global().async {
            let move = C4AI.getBestMove(board: board, ai: aiPlayer, difficulty: difficulty)
            let elapsed = Date().timeIntervalSince(startTime)
            
            // Minimum display delay
            let minDelay: Double = 0.5
            let remainingDelay = max(minDelay - elapsed, 0)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + remainingDelay) {
                aiIsThinking = false
                handleTap(column: move)
            }
        }
    }
    
    private var inputLocked: Bool {
        animatingCell != nil || aiIsThinking
    }
}



#Preview(traits: .landscapeLeft) {
    ContentView(settings: GameSettings(
        isVsAI: true,
        humanPlayer: .red,
        aiDifficulty: .medium
    ))
}
