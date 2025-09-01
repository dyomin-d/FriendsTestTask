import SwiftUI

struct FriendCardView: View {
    let friend: FriendWithProgress
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: avatarColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                
                if let avatarUrl = friend.user.avatarUrl, !avatarUrl.isEmpty {
                    AsyncImage(url: URL(string: avatarUrl)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        userInitials
                    }
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                } else {
                    userInitials
                }
                
                if friend.isActive {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            dayBadge
                        }
                    }
                }
            }
            
            Text(friend.user.displayName)
                .font(.footnote)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .lineLimit(1)
            
            if friend.isActive {
                Text(friend.tasksProgress + " tasks")
                    .font(.caption2)
                    .foregroundColor(.gray)
            } else {
                Text("No active challenge")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 120)
    }
    
    private var userInitials: some View {
        Text(friend.user.displayName.prefix(1))
            .font(.title2)
            .fontWeight(.bold)
            .foregroundColor(.white)
    }
    
    private var dayBadge: some View {
        ZStack {
            Circle()
                .fill(Color.orange)
                .frame(width: 32, height: 32)
            
            VStack(spacing: -2) {
                Text("\(friend.userChallenge?.currentDay ?? 0)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                Text("Day")
                    .font(.system(size: 8))
                    .fontWeight(.medium)
                    .foregroundColor(.black)
            }
        }
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
}

struct AddFriendCardView: View {
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "plus")
                    .font(.title2)
                    .foregroundColor(.gray)
            }
            
            Text("Invite")
                .font(.footnote)
                .fontWeight(.medium)
                .foregroundColor(.gray)
                
            Text("")
                .font(.caption2)
                .foregroundColor(.clear)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 120)
    }
}
