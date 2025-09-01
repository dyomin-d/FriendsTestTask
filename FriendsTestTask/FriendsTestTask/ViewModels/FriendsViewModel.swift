import Foundation
import Combine

@MainActor
final class FriendsViewModel: ObservableObject {
    @Published var friends: [FriendWithProgress] = []
    @Published var isLoading = false
    @Published var error: String?
    @Published var selectedUserId: String? = nil
    
    private let friendsService: FriendsServiceProtocol
    private let currentUserId = "ben" // In real app would get from Auth
    private var cancellables = Set<AnyCancellable>()
    @Published var allFriends: [FriendWithProgress] = []
    
    init(friendsService: FriendsServiceProtocol) {
        self.friendsService = friendsService
    }
    
    private func setupRealTimeUpdates() {
        friendsService.observeFriendsUpdates(for: currentUserId)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.error = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] friendsData in
                    guard let self = self else { return }
                    self.allFriends = friendsData.sorted { $0.user.displayName < $1.user.displayName }
                    self.filterFriends()
                }
            )
            .store(in: &cancellables)
    }
    
    func loadFriends() async {
        isLoading = true
        error = nil
        
        // Start real-time updates on first load
        setupRealTimeUpdates()
        
        do {
            let friendsData = try await friendsService.getFriendsWithProgress(for: currentUserId)
            allFriends = friendsData.sorted { $0.user.displayName < $1.user.displayName }
            friends = allFriends
            isLoading = false
        } catch {
            self.error = error.localizedDescription
            isLoading = false
        }
    }
    
    func refresh() async {
        await loadFriends()
    }
    
    func selectUser(_ userId: String?) {
        selectedUserId = userId
        filterFriends()
    }
    
    private func filterFriends() {
        if let selectedUserId = selectedUserId {
            friends = allFriends.filter { $0.user.id == selectedUserId }
        } else {
            friends = allFriends
        }
    }
    
    var filteredActivityFriends: [FriendWithProgress] {
        let activeFriends: [FriendWithProgress]
        if let selectedUserId = selectedUserId {
            activeFriends = allFriends.filter { $0.user.id == selectedUserId && $0.isActive }
        } else {
            activeFriends = allFriends.filter { $0.isActive }
        }
        
        return activeFriends.sorted { first, second in
            let firstTime = first.randomTimeToday
            let secondTime = second.randomTimeToday
            
            return firstTime > secondTime
        }
    }
    
    var uniqueFriendsForGrid: [FriendWithProgress] {
        var userMap: [String: FriendWithProgress] = [:]
        
        for friend in allFriends {
            let userId = friend.user.id
            
            if userMap[userId] == nil || friend.isActive {
                userMap[userId] = friend
            }
        }
        
        return Array(userMap.values).sorted { $0.user.displayName < $1.user.displayName }
    }
}
