import SwiftUI

struct SessionHistoryView: View {
    @ObservedObject var viewModel: FocusFlowViewModel
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.sessions.sorted(by: { $0.date > $1.date })) { session in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(session.phase.rawValue)
                                .font(.headline)
                                .foregroundColor(color(for: session.phase))
                            Text(dateString(session.date))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Text("\(session.duration / 60) min")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Session History")
        }
    }
    
    private func dateString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func color(for phase: Phase) -> Color {
        switch phase {
        case .work: return .mint
        case .shortBreak: return .blue
        case .longBreak: return .purple
        case .paused: return .gray
        }
    }
} 