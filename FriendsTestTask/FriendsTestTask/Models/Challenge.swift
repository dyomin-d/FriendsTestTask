import Foundation

struct Challenge: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let duration: Int
    let tasksPerDay: Int
    let isActive: Bool
    
    init(id: String, title: String, description: String, duration: Int, tasksPerDay: Int, isActive: Bool = true) {
        self.id = id
        self.title = title
        self.description = description
        self.duration = duration
        self.tasksPerDay = tasksPerDay
        self.isActive = isActive
    }
}

