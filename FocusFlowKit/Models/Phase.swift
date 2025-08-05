import Foundation

enum Phase: String, CaseIterable, Codable {
    case work = "Work"
    case shortBreak = "Short Break"
    case longBreak = "Long Break"
    case paused = "Paused"
    
    var color: String {
        switch self {
        case .work: return "mint"
        case .shortBreak: return "blue"
        case .longBreak: return "purple"
        case .paused: return "gray"
        }
    }
    
    var defaultDuration: Int {
        switch self {
        case .work: return 25 * 60
        case .shortBreak: return 5 * 60
        case .longBreak: return 15 * 60
        case .paused: return 0
        }
    }
} 