import SwiftUI

struct CircleTimerView: View {
    let progress: Double
    let color: Color
    var gradient: LinearGradient? = nil
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.13), lineWidth: 22)
            
            if let gradient = gradient {
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(gradient, style: StrokeStyle(lineWidth: 22, lineCap: .round))
                    .shadow(color: .white.opacity(0.18), radius: 12, x: 0, y: 0)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.6), value: progress)
            } else {
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(color, style: StrokeStyle(lineWidth: 22, lineCap: .round))
                    .shadow(color: color.opacity(0.18), radius: 12, x: 0, y: 0)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.6), value: progress)
            }
        }
    }
} 