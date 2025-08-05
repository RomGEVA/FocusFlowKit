import SwiftUI

struct StatsView: View {
    @ObservedObject var viewModel: FocusFlowViewModel
    @State private var showHistory = false
    
    private var todayStats: (count: Int, duration: Int) {
        let today = Calendar.current.startOfDay(for: Date())
        let sessions = viewModel.sessions.filter { Calendar.current.isDate($0.date, inSameDayAs: today) && $0.phase == .work }
        let count = sessions.count
        let duration = sessions.reduce(0) { $0 + $1.duration }
        return (count, duration)
    }
    
    private var weekStats: (count: Int, duration: Int) {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -6, to: Date())!
        let sessions = viewModel.sessions.filter { $0.date >= weekAgo && $0.phase == .work }
        let count = sessions.count
        let duration = sessions.reduce(0) { $0 + $1.duration }
        return (count, duration)
    }
    
    private var groupedByDay: [(String, Int)] {
        let grouped = Dictionary(grouping: viewModel.sessions.filter { $0.phase == .work }) { session in
            let date = Calendar.current.startOfDay(for: session.date)
            return date
        }
        return grouped.map { (date, sessions) in
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMM"
            return (formatter.string(from: date), sessions.count)
        }.sorted { $0.0 < $1.0 }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    HStack(spacing: 16) {
                        StatCard(title: "Today", value: "\(todayStats.count)", subtitle: "Pomodoros")
                        StatCard(title: "Week", value: "\(weekStats.count)", subtitle: "Pomodoros")
                    }
                    .padding(.horizontal)
                    HStack(spacing: 16) {
                        StatCard(title: "Today", value: "\(todayStats.duration / 60)", subtitle: "min focus")
                        StatCard(title: "Week", value: "\(weekStats.duration / 60)", subtitle: "min focus")
                    }
                    .padding(.horizontal)
                    Text("Last 7 days")
                        .font(.headline)
                        .padding(.top, 8)
                    BarChartView(data: groupedByDay)
                        .frame(height: 180)
                        .padding(.horizontal)
                    Button(action: { showHistory = true }) {
                        Label("Session History", systemImage: "clock.arrow.circlepath")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.mint.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .padding(.top, 12)
                }
                .padding()
            }
            .navigationTitle("Statistics")
            .sheet(isPresented: $showHistory) {
                SessionHistoryView(viewModel: viewModel)
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.title.bold())
                .foregroundColor(.primary)
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.mint)
        }
        .frame(width: 110, height: 70)
        .background(Color.white.opacity(0.18))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.04), radius: 2, x: 0, y: 2)
    }
}

struct BarChartView: View {
    let data: [(String, Int)]
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            ForEach(data, id: \.0) { (label, value) in
                VStack {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.mint)
                        .frame(width: 18, height: CGFloat(value) * 22)
                    Text(label)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
} 