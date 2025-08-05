import SwiftUI

struct TimerView: View {
    @EnvironmentObject var viewModel: FocusFlowViewModel
    @State private var showStats = false
    
    private var progress: Double {
        let total: Int
        switch viewModel.currentPhase {
        case .work: total = viewModel.workDuration * 60
        case .shortBreak: total = viewModel.shortBreakDuration * 60
        case .longBreak: total = viewModel.longBreakDuration * 60
        case .paused: total = viewModel.workDuration * 60
        }
        return 1 - (Double(viewModel.timeRemaining) / Double(total))
    }
    
    private var timeString: String {
        let minutes = viewModel.timeRemaining / 60
        let seconds = viewModel.timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private var phaseGradient: LinearGradient {
        switch viewModel.currentPhase {
        case .work:
            return LinearGradient(colors: [.mint, .green], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .shortBreak:
            return LinearGradient(colors: [.blue, .indigo], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .longBreak:
            return LinearGradient(colors: [.purple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .paused:
            return LinearGradient(colors: [.gray, .mint], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
    
    var body: some View {
        ZStack {
            LiveBackgroundView(phase: viewModel.currentPhase)
            
            VStack(spacing: 30) {
                Spacer()
                Text(viewModel.currentPhase.rawValue)
                    .font(.title2.weight(.semibold))
                    .foregroundColor(.white.opacity(0.8))
                    .shadow(color: .black.opacity(0.15), radius: 2, x: 0, y: 2)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                    .animation(.easeOut(duration: 0.5), value: viewModel.currentPhase)
                
                ZStack {
                    // Glassmorphism card
                    RoundedRectangle(cornerRadius: 40, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .frame(width: 340, height: 340)
                        .shadow(color: .black.opacity(0.08), radius: 24, x: 0, y: 8)
                        .blur(radius: 0.5)
                        .overlay(
                            CircleTimerView(
                                progress: progress,
                                color: Color.white.opacity(0.7),
                                gradient: phaseGradient
                            )
                            .frame(width: 300, height: 300)
                        )
                    
                    VStack(spacing: 8) {
                        Text(timeString)
                            .font(.system(size: 64, weight: .bold, design: .rounded))
                            .foregroundStyle(phaseGradient)
                            .shadow(color: .white.opacity(0.25), radius: 8, x: 0, y: 2)
                            .transition(.scale.combined(with: .opacity))
                            .animation(.spring(), value: viewModel.timeRemaining)
                        
                        let mod = viewModel.completedPomodoros % viewModel.pomodorosUntilLongBreak
                        let currentRound = (mod == 0 && viewModel.completedPomodoros != 0) ? viewModel.pomodorosUntilLongBreak : mod
                        Text("\(currentRound)/\(viewModel.pomodorosUntilLongBreak)")
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.top, 2)
                        
                        // Мотивационная цитата
                        Text(viewModel.currentQuote)
                            .font(.callout.italic())
                            .foregroundColor(.white.opacity(0.85))
                            .multilineTextAlignment(.center)
                            .padding(.top, 8)
                            .padding(.horizontal, 12)
                            .transition(.opacity)
                            .id(viewModel.currentQuote)
                            .animation(.easeInOut(duration: 0.7), value: viewModel.currentQuote)
                    }
                }
                .padding(.bottom, 10)
                
                Spacer()
                HStack(spacing: 24) {
                    // Start/Pause
                    Button(action: {
                        if viewModel.isRunning {
                            viewModel.pause()
                        } else {
                            viewModel.start()
                        }
                    }) {
                        Image(systemName: viewModel.isRunning ? "pause.fill" : "play.fill")
                            .font(.title)
                            .foregroundColor(.white)
                            .frame(width: 64, height: 64)
                            .background(
                                Circle()
                                    .fill(phaseGradient)
                                    .shadow(color: .mint.opacity(0.5), radius: 16, x: 0, y: 0)
                            )
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.2), lineWidth: 2)
                            )
                            .shadow(color: .mint.opacity(0.25), radius: 8, x: 0, y: 4)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .scaleEffect(viewModel.isRunning ? 1.08 : 1.0)
                    .animation(.spring(), value: viewModel.isRunning)
                    
                    // Reset
                    Button(action: viewModel.reset) {
                        Image(systemName: "arrow.clockwise")
                            .font(.title)
                            .foregroundColor(.white)
                            .frame(width: 64, height: 64)
                            .background(
                                Circle()
                                    .fill(Color.white.opacity(0.18))
                                    .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 2)
                            )
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.2), lineWidth: 2)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Statistics
                    Button(action: { showStats = true }) {
                        Image(systemName: "chart.bar.xaxis")
                            .font(.title)
                            .foregroundColor(.white)
                            .frame(width: 64, height: 64)
                            .background(
                                Circle()
                                    .fill(Color.teal)
                                    .shadow(color: .teal.opacity(0.18), radius: 8, x: 0, y: 2)
                            )
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.2), lineWidth: 2)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.bottom, 4)
                
                // streak и ачивки внизу
                VStack(spacing: 6) {
                    HStack(spacing: 6) {
                        Image(systemName: "flame.fill").foregroundColor(.orange)
                        Text("Streak: \(viewModel.streak) days")
                            .font(.footnote.bold())
                            .foregroundColor(.orange)
                    }
                    if !viewModel.achievements.isEmpty {
                        HStack(spacing: 10) {
                            ForEach(viewModel.achievements, id: \.self) { ach in
                                Label(ach, systemImage: "star.fill")
                                    .font(.caption2)
                                    .foregroundColor(.yellow)
                                    .padding(6)
                                    .background(Color.white.opacity(0.13))
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }
                .padding(.bottom, 8)
            }
            .padding(.horizontal)
        }
        .sheet(isPresented: $showStats) {
            StatsView(viewModel: viewModel)
        }
    }
} 