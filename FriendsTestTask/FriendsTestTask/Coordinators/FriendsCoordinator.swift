import SwiftUI

final class FriendsCoordinator: Coordinator {
    private let friendsService: FriendsServiceProtocol
    
    init(friendsService: FriendsServiceProtocol = FriendsService()) {
        self.friendsService = friendsService
    }
    
    @MainActor
    var contentView: some View {
        FriendsView(viewModel: FriendsViewModel(friendsService: friendsService))
    }
}
