import Foundation

struct Friendship: Identifiable, Codable {
    let id: String
    let userId1: String
    let userId2: String
    let status: FriendshipStatus
    let createdAt: Date
    let updatedAt: Date
    
    enum FriendshipStatus: String, Codable, CaseIterable {
        case pending = "pending"
        case accepted = "accepted"
        case blocked = "blocked"
    }
    
    init(id: String, userId1: String, userId2: String, status: FriendshipStatus, createdAt: Date = Date(), updatedAt: Date = Date()) {
        self.id = id
        self.userId1 = userId1
        self.userId2 = userId2
        self.status = status
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

