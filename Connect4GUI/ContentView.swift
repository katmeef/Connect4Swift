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
            let availableWidth = geometry.size.width
            let totalSpacing = CGFloat(columns - 1) * cellSpacing
            let gridWidth = max(availableWidth * 0.9, 300) // fallback to 300 if needed
            let cellSize = (gridWidth - totalSpacing) / CGFloat(columns)
            let boardHeight = CGFloat(rows) * cellSize + CGFloat(rows - 1) * cellSpacing

            VStack(spacing: 20) {
                Text("Connect 4")
                    .font(.largeTitle)
                    .padding(.top)

                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.black, lineWidth: 2)
                        .background(Color.white.cornerRadius(12))

                    gridView(cellSize: cellSize)
                        .padding(10)

                    if let (row, col) = animatingCell {
                        let xOffset = CGFloat(col) * (cellSize + cellSpacing) + 10
                        let yFinal = CGFloat(row) * (cellSize + cellSpacing) + 10

                        Circle()
                            .fill(color(for: currentPlayer.symbol))
                            .frame(width: cellSize, height: cellSize)
                            .offset(x: xOffset, y: fallingOffset)
                            .onAppear {
                                // Start above and animate down to target
                                fallingOffset = -UIScreen.main.bounds.height
                                withAnimation(.easeOut(duration: 0.35)) {
                                    fallingOffset = yFinal
                                }
                            }
                    }
                }
                .frame(width: gridWidth, height: boardHeight)
                .frame(maxWidth: .infinity) // Centers ZStack in VStack

                if let winner {
                    Text("\(winner.colourName) Wins!")
                        .font(.title2)
                        .foregroundColor(color(for: winner.symbol))
                        .padding(.top, 10)
                }
                if isDraw {
                    Text("🤝 It's a draw!")
                        .font(.title2)
                        .foregroundColor(.gray)
                        .padding(.top, 10)
                }
                if winner != nil || isDraw {
                    Button("Play Again") {
                        board = GameBoard()
                        currentPlayer = .red
                        animatingCell = nil
                        winner = nil
                        isDraw = false
                    }
                    .padding(.top, 5)
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity) // Fills GeometryReader
            .padding()
        }
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
        guard animatingCell == nil else { return } // 👈 this prevents rapid taps
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
        // Simulate AI thinking delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let move = C4AI.getBestMove(board: board, ai: aiPlayer, difficulty: difficulty)
            handleTap(column: move)
        }
    }
}



#Preview {
    ContentView(settings: GameSettings(
        isVsAI: true,
        humanPlayer: .red,
        aiDifficulty: .medium
    ))
}
