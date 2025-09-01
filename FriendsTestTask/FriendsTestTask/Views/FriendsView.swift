import SwiftUI

struct FriendsView: View {
    @StateObject private var viewModel: FriendsViewModel
    
    init(viewModel: FriendsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea(.all)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Friends")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Button(action: {}) {
                                Image(systemName: "bell")
                                    .font(.title2)
                                    .foregroundColor(.white)
                            }
                            
                            Button(action: {}) {
                                Image(systemName: "person.crop.circle.badge.plus")
                                    .font(.title2)
                                    .foregroundColor(.white)
                            }
                        }
                        
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
                        } else {
                            friendsGrid
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Activity")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            if let selectedUserId = viewModel.selectedUserId,
                               let selectedFriend = viewModel.uniqueFriendsForGrid.first(where: { $0.user.id == selectedUserId }) {
                                Text("• \(selectedFriend.user.displayName)")
                                    .font(.title3)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            if viewModel.selectedUserId != nil {
                                Button("Clear") {
                                    viewModel.selectUser(nil)
                                }
                                .font(.caption)
                                .foregroundColor(.orange)
                            }
                        }
                        
                        if viewModel.isLoading {
                            HStack {
                                Spacer()
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                Spacer()
                            }
                            .padding(.vertical, 40)
                        } else if viewModel.uniqueFriendsForGrid.isEmpty {
                            emptyActivityView
                        } else if viewModel.filteredActivityFriends.isEmpty {
                            emptyActivityView
                        } else {
                            activityList
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
            }
        }
        .task {
            await viewModel.loadFriends()
        }
        .refreshable {
            await viewModel.refresh()
        }
    }
    
    private var friendsGrid: some View {
        let uniqueFriends = viewModel.uniqueFriendsForGrid
        let friendsCount = uniqueFriends.count
        let inviteCount = friendsCount < 4 ? (4 - friendsCount) : 0
        
        return ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(uniqueFriends) { friend in
                    FriendCardView(friend: friend)
                        .frame(width: 80)
                        .onTapGesture {
                            // Toggle selection: if already selected, deselect; otherwise select
                            if viewModel.selectedUserId == friend.user.id {
                                viewModel.selectUser(nil)
                            } else {
                                viewModel.selectUser(friend.user.id)
                            }
                        }
                }
                
                // Show invite cards only if less than 4 friends
                if friendsCount < 4 {
                    ForEach(0..<inviteCount, id: \.self) { _ in
                        AddFriendCardView()
                            .frame(width: 80)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.horizontal, -20)
    }
    
    private var activityList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today")
                .font(.caption)
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .center)
            
            ForEach(viewModel.filteredActivityFriends) { friend in
                ActivityRowView(friend: friend)
            }
        }
    }
    
    private var emptyActivityView: some View {
        VStack(spacing: 16) {
            Text("😅")
                .font(.system(size: 60))
            
            Text(emptyActivityText)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Text(emptyActivitySubtext)
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            Button(action: {
                // TODO: Implement nudge functionality
            }) {
                HStack {
                    Text("Nudge")
                    Text("💪")
                }
                .font(.headline)
                .foregroundColor(.black)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.white)
                .cornerRadius(25)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
    
    private var emptyActivityText: String {
        if let selectedUserId = viewModel.selectedUserId,
           let selectedFriend = viewModel.uniqueFriendsForGrid.first(where: { $0.user.id == selectedUserId }) {
            return "\(selectedFriend.user.displayName)'s warming up"
        } else {
            return "Friends warming up"
        }
    }
    
    private var emptyActivitySubtext: String {
        if let selectedUserId = viewModel.selectedUserId,
           let selectedFriend = viewModel.uniqueFriendsForGrid.first(where: { $0.user.id == selectedUserId }) {
            return "Nudge \(selectedFriend.user.displayName.components(separatedBy: " ").first ?? selectedFriend.user.displayName.lowercased()) to start"
        } else {
            return "Nudge them to start"
        }
    }
}
