import Foundation

struct SessionStat: Identifiable, Codable {
    let id: UUID
    let date: Date
    let duration: Int // in seconds
    let phase: Phase
    
    init(id: UUID = UUID(), date: Date = Date(), duration: Int, phase: Phase) {
        self.id = id
        self.date = date
        self.duration = duration
        self.phase = phase
    }
} 