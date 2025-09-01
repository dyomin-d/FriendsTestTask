import SwiftUI

struct ActivityRowView: View {
    let friend: FriendWithProgress
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: avatarColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 40)
                
                if let avatarUrl = friend.user.avatarUrl, !avatarUrl.isEmpty {
                    AsyncImage(url: URL(string: avatarUrl)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Text(friend.user.displayName.prefix(1))
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    .frame(width: 40, height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    Text(friend.user.displayName.prefix(1))
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(friend.user.displayName)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text(timeAgo)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Text(friend.challenge?.title ?? "Challenge")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                HStack(spacing: 8) {
                    Image(systemName: "checkmark")
                        .font(.caption)
                        .foregroundColor(.green)
                    
                    Text(randomTaskName)
                        .font(.subheadline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("\(remainingTasks) to go")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.gray.opacity(0.15))
                .cornerRadius(12)
            }
        }
        .padding(.vertical, 8)
    }
    
    private var avatarColors: [Color] {
        let hash = friend.user.displayName.hashValue
        let colorOptions: [[Color]] = [
            [.orange, .yellow],
            [.blue, .cyan],
            [.purple, .pink],
            [.green, .mint],
            [.red, .orange]
        ]
        return colorOptions[abs(hash) % colorOptions.count]
    }
    
    private var timeAgo: String {
        let randomTimeToday = friend.randomTimeToday
        let now = Date()
        let timeInterval = now.timeIntervalSince(randomTimeToday)
        
        if timeInterval < 60 {
            return "Now"
        } else if timeInterval < 3600 {
            let minutes = Int(timeInterval / 60)
            return "\(minutes)m ago"
        } else if timeInterval < 86400 {
            let hours = Int(timeInterval / 3600)
            return "\(hours)h ago"
        } else {
            return "Yesterday"
        }
    }
    
    private var remainingTasks: Int {
        guard let userChallenge = friend.userChallenge else { return 0 }
        return max(0, userChallenge.totalTasks - userChallenge.completedTasks)
    }
    
    private var randomTaskName: String {
        let tasks = [
            "First workout",
            "Second workout", 
            "Progress picture",
            "No alcohol or cheat meals",
            "Morning run",
            "Meditation session",
            "Healthy breakfast"
        ]
        return tasks[abs(friend.user.displayName.hashValue) % tasks.count]
    }
}
