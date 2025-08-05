import Foundation
import Combine
import SwiftUI

@MainActor
class FocusFlowViewModel: ObservableObject {
    @AppStorage("workDuration") var workDuration: Int = 25
    @AppStorage("shortBreakDuration") var shortBreakDuration: Int = 5
    @AppStorage("longBreakDuration") var longBreakDuration: Int = 15
    @AppStorage("pomodorosUntilLongBreak") var pomodorosUntilLongBreak: Int = 4

    @Published var currentPhase: Phase = .work
    @Published var timeRemaining: Int = 25 * 60
    @Published var isRunning: Bool = false
    @Published var completedPomodoros: Int = 0
    @Published var sessions: [SessionStat] = []
    
    private var timer: AnyCancellable?
    private var cancellables = Set<AnyCancellable>()
    
    // Мотивационные цитаты
    let quotes: [String] = [
        "Stay focused, stay present.",
        "Small steps every day.",
        "Deep work, big results.",
        "Breaks fuel your brain.",
        "Consistency beats intensity.",
        "You're building a habit!",
        "One Pomodoro at a time."
    ]
    @Published var currentQuote: String = "Stay focused, stay present."
    
    // Streak и ачивки
    @Published var streak: Int = 0
    @Published var achievements: [String] = []
    
    init() {
        loadSessions()
        syncTimeWithSettings()
        
        // Monitor AppStorage changes using Combine
        NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)
            .sink { [weak self] _ in
                self?.checkForSettingsChanges()
            }
            .store(in: &cancellables)
    }
    
    func syncTimeWithSettings() {
        switch currentPhase {
        case .work:
            timeRemaining = workDuration * 60
        case .shortBreak:
            timeRemaining = shortBreakDuration * 60
        case .longBreak:
            timeRemaining = longBreakDuration * 60
        case .paused:
            timeRemaining = workDuration * 60
        }
    }
    
    private func checkForSettingsChanges() {
        let expectedTime: Int
        switch currentPhase {
        case .work:
            expectedTime = workDuration * 60
        case .shortBreak:
            expectedTime = shortBreakDuration * 60
        case .longBreak:
            expectedTime = longBreakDuration * 60
        case .paused:
            expectedTime = workDuration * 60
        }
        
        // Only sync if the timer is not running and the time doesn't match
        // This prevents interrupting an active timer
        if !isRunning && timeRemaining != expectedTime {
            syncTimeWithSettings()
        }
    }
    
    func start() {
        isRunning = true
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateTimer()
            }
    }
    
    func pause() {
        isRunning = false
        timer?.cancel()
        currentPhase = .paused
    }
    
    func reset() {
        pause()
        syncTimeWithSettings()
    }
    
    private func updateTimer() {
        guard timeRemaining > 0 else {
            nextPhase()
            return
        }
        timeRemaining -= 1
    }
    
    func nextPhase() {
        let wasRunning = isRunning
        
        switch currentPhase {
        case .work:
            completedPomodoros += 1
            saveSession(duration: workDuration * 60, phase: .work)
            if completedPomodoros % pomodorosUntilLongBreak == 0 {
                currentPhase = .longBreak
                timeRemaining = longBreakDuration * 60
            } else {
                currentPhase = .shortBreak
                timeRemaining = shortBreakDuration * 60
            }
        case .shortBreak, .longBreak:
            currentPhase = .work
            timeRemaining = workDuration * 60
        case .paused:
            break
        }
        
        // Auto-start timer for breaks if it was running before
        if wasRunning && currentPhase != .paused {
            start()
        }
        
        playSound()
        pickRandomQuote()
        updateStreakAndAchievements()
    }
    
    private func playSound() {
        // TODO: Implement sound
    }
    
    private func saveSession(duration: Int, phase: Phase) {
        let session = SessionStat(duration: duration, phase: phase)
        sessions.append(session)
        saveSessions()
    }
    
    private func saveSessions() {
        if let encoded = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(encoded, forKey: "sessions")
        }
    }
    
    private func loadSessions() {
        if let data = UserDefaults.standard.data(forKey: "sessions"),
           let decoded = try? JSONDecoder().decode([SessionStat].self, from: data) {
            sessions = decoded
        }
    }
    
    func updateStreakAndAchievements() {
        // streak: сколько дней подряд были work-сессии
        let days = Set(sessions.filter { $0.phase == .work }.map { Calendar.current.startOfDay(for: $0.date) })
        let sortedDays = days.sorted(by: >)
        var streakCount = 0
        var prev = Calendar.current.startOfDay(for: Date())
        for day in sortedDays {
            if Calendar.current.dateComponents([.day], from: day, to: prev).day ?? 0 <= 1 {
                streakCount += 1
                prev = day
            } else {
                break
            }
        }
        streak = streakCount
        // Ачивки
        var newAchievements: [String] = []
        // 5 Pomodoros in a day
        let today = Calendar.current.startOfDay(for: Date())
        let todayCount = sessions.filter { $0.phase == .work && Calendar.current.isDate($0.date, inSameDayAs: today) }.count
        if todayCount >= 5 { newAchievements.append("5 Pomodoros in a day") }
        // First Long Break
        if sessions.contains(where: { $0.phase == .longBreak }) { newAchievements.append("First Long Break") }
        // 7 days streak
        if streak >= 7 { newAchievements.append("7 days streak") }
        achievements = newAchievements
    }
    
    func pickRandomQuote() {
        currentQuote = quotes.randomElement() ?? quotes.first!
    }
} 
