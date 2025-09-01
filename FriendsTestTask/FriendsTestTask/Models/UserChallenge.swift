import Foundation

struct UserChallenge: Identifiable, Codable {
    let id: String
    let userId: String
    let challengeId: String
    let currentDay: Int
    let status: ChallengeStatus
    let completedTasks: Int
    let totalTasks: Int
    let startDate: Date
    let lastUpdated: Date
    
    enum ChallengeStatus: String, Codable, CaseIterable {
        case active = "active"
        case completed = "completed"
        case paused = "paused"
    }
    
    init(id: String, userId: String, challengeId: String, currentDay: Int, status: ChallengeStatus, completedTasks: Int, totalTasks: Int, startDate: Date = Date(), lastUpdated: Date = Date()) {
        self.id = id
        self.userId = userId
        self.challengeId = challengeId
        self.currentDay = currentDay
        self.status = status
        self.completedTasks = completedTasks
        self.totalTasks = totalTasks
        self.startDate = startDate
        self.lastUpdated = lastUpdated
    }
}

