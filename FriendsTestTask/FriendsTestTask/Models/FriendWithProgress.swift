import Foundation

struct FriendWithProgress: Identifiable {
    let user: User
    let challenge: Challenge?
    let userChallenge: UserChallenge?
    
    var id: String { 
        if let userChallengeId = userChallenge?.id {
            return "\(user.id)_\(userChallengeId)"
        } else {
            return user.id
        }
    }
    
    var displayProgress: String {
        guard let challenge = challenge,
              let userChallenge = userChallenge else {
            return "No active challenge"
        }
        
        return "Day \(userChallenge.currentDay), \(userChallenge.completedTasks)/\(userChallenge.totalTasks) tasks"
    }
    
    var dayNumber: Int {
        userChallenge?.currentDay ?? 0
    }
    
    var tasksProgress: String {
        guard let userChallenge = userChallenge else { return "0/0" }
        return "\(userChallenge.completedTasks)/\(userChallenge.totalTasks)"
    }
    
    var isActive: Bool {
        userChallenge?.status == .active
    }
    
    var randomTimeToday: Date {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        let seedString = "\(user.id)_\(userChallenge?.id ?? "default")"
        let seed = UInt64(abs(seedString.hashValue))
        
        var generator = SeededRandomNumberGenerator(seed: seed)
        
        let sixAM = calendar.date(byAdding: .hour, value: 6, to: today) ?? today
        let elevenPM = calendar.date(byAdding: .hour, value: 23, to: today) ?? today
        let now = Date()
        
        let endTime = min(now, elevenPM)
        let timeRange = endTime.timeIntervalSince(sixAM)
        
        guard timeRange > 0 else { return sixAM }
        
        let randomOffset = Double.random(in: 0...timeRange, using: &generator)
        return sixAM.addingTimeInterval(randomOffset)
    }
}

