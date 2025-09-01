import Foundation

struct User: Identifiable, Codable {
    let id: String
    let displayName: String
    let email: String
    let avatarUrl: String?
    
    init(id: String, displayName: String, email: String, avatarUrl: String? = nil) {
        self.id = id
        self.displayName = displayName
        self.email = email
        self.avatarUrl = avatarUrl
    }
}

