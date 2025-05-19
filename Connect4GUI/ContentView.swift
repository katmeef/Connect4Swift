import SwiftUI

struct ContentView: View {
    let rows = 6
    let columns = 7
    let cellSpacing: CGFloat = 4

    @State private var grid: [[Character]] = ContentView.makeEmptyGrid()
    @State private var currentPlayer: Character = "R"
    @State private var animatingCell: (row: Int, col: Int)? = nil
    @State private var dropInProgress = false
    @State private var bounceOffset: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            let availableWidth = geometry.size.width - 40
            let cellSize = (availableWidth - CGFloat(columns - 1) * cellSpacing) / CGFloat(columns)
            let boardHeight = cellSize * CGFloat(rows) + CGFloat(rows - 1) * cellSpacing

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
                        let yBase = CGFloat(row) * (cellSize + cellSpacing) + 10

                        Circle()
                            .fill(color(for: currentPlayer))
                            .frame(width: cellSize, height: cellSize)
                            .offset(x: xOffset, y: yBase + bounceOffset)
                            .onAppear {
                                // Start with off-screen drop
                                bounceOffset = -UIScreen.main.bounds.height

                                // Animate falling
                                withAnimation(.easeOut(duration: 0.35)) {
                                    bounceOffset = 0
                                }

                                // Animate bounce
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                                    withAnimation(.interpolatingSpring(stiffness: 100, damping: 8)) {
                                        bounceOffset = -12
                                    }

                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                        withAnimation(.interpolatingSpring(stiffness: 80, damping: 10)) {
                                            bounceOffset = 0
                                        }
                                    }
                                }
                            }
                    }
                }
                .frame(width: availableWidth, height: boardHeight)

                Spacer()
            }
            .padding()
        }
    }

    private func gridView(cellSize: CGFloat) -> some View {
        VStack(spacing: cellSpacing) {
            ForEach(0..<rows, id: \.self) { row in
                HStack(spacing: cellSpacing) {
                    ForEach(0..<columns, id: \.self) { col in
                        Circle()
                            .fill(color(for: grid[row][col]))
                            .frame(width: cellSize, height: cellSize)
                            .onTapGesture {
                                handleTap(column: col)
                            }
                    }
                }
            }
        }
    }

    private func handleTap(column: Int) {
        guard animatingCell == nil else { return } // Prevent multiple simultaneous drops

        for row in (0..<rows).reversed() {
            if grid[row][column] == " " {
                animatingCell = (row, column)
                dropInProgress = false

                // Start the animation after a brief moment
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    dropInProgress = true

                    // After animation completes, update board and switch player
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        grid[row][column] = currentPlayer
                        animatingCell = nil
                        dropInProgress = false
                        currentPlayer = (currentPlayer == "R") ? "Y" : "R"
                    }
                }
                break
            }
        }
    }

    private func color(for symbol: Character) -> Color {
        switch symbol {
        case "R": return .red
        case "Y": return .yellow
        default: return .gray.opacity(0.3)
        }
    }

    private static func makeEmptyGrid() -> [[Character]] {
        Array(repeating: Array(repeating: " ", count: 7), count: 6)
    }
}

#Preview {
    ContentView()
}
