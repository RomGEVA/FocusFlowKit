import SwiftUI

struct LiveBackgroundView: View {
    var phase: Phase
    @State private var phaseShift: CGFloat = 0
    @State private var timer: Timer? = nil
    
    private var backgroundGradient: LinearGradient {
        switch phase {
        case .work:
            return LinearGradient(
                gradient: Gradient(colors: [Color.mint.opacity(0.85), Color.green.opacity(0.7), Color.white.opacity(0.18)]),
                startPoint: .topLeading, endPoint: .bottomTrailing)
        case .shortBreak:
            return LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.85), Color.indigo.opacity(0.7), Color.white.opacity(0.18)]),
                startPoint: .topLeading, endPoint: .bottomTrailing)
        case .longBreak:
            return LinearGradient(
                gradient: Gradient(colors: [Color.purple.opacity(0.85), Color.pink.opacity(0.7), Color.white.opacity(0.18)]),
                startPoint: .topLeading, endPoint: .bottomTrailing)
        case .paused:
            return LinearGradient(
                gradient: Gradient(colors: [Color.gray.opacity(0.7), Color.mint.opacity(0.4), Color.white.opacity(0.1)]),
                startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
    
    private var waveColor: Color {
        switch phase {
        case .work: return Color.green.opacity(0.45)
        case .shortBreak: return Color.indigo.opacity(0.45)
        case .longBreak: return Color.pink.opacity(0.45)
        case .paused: return Color.gray.opacity(0.35)
        }
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                backgroundGradient
                    .ignoresSafeArea()
                    .animation(.easeInOut(duration: 1), value: phase)
                
                WaveShape(strength: 48, frequency: 1.1, phase: phaseShift)
                    .fill(waveColor)
                    .frame(height: geo.size.height * 0.55)
                    .offset(y: geo.size.height * 0.45)
                    .blur(radius: 4)
                    .opacity(0.85)
            }
            .onAppear {
                timer?.invalidate()
                timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { _ in
                    phaseShift += 0.015
                    if phaseShift > .pi * 2 { phaseShift -= .pi * 2 }
                }
            }
            .onDisappear {
                timer?.invalidate()
            }
        }
    }
}

struct WaveShape: Shape {
    var strength: CGFloat = 20
    var frequency: CGFloat = 2
    var phase: CGFloat = 0
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        path.move(to: CGPoint(x: 0, y: height / 2))
        for x in stride(from: 0, through: width, by: 2) {
            let relativeX = x / width
            let sine = sin(relativeX * .pi * frequency + phase)
            let y = height / 2 + sine * strength
            path.addLine(to: CGPoint(x: x, y: y))
        }
        path.addLine(to: CGPoint(x: width, y: height))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.closeSubpath()
        return path
    }
} 
