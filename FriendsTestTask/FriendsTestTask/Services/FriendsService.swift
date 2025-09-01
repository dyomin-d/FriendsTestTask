import Foundation
import Combine

protocol FriendsServiceProtocol {
    func getFriendsWithProgress(for userId: String) async throws -> [FriendWithProgress]
    func observeFriendsUpdates(for userId: String) -> AnyPublisher<[FriendWithProgress], Error>
}

final class FriendsService: FriendsServiceProtocol {
    private let firebaseService: FirebaseServiceProtocol
    
    init(firebaseService: FirebaseServiceProtocol = FirebaseService()) {
        self.firebaseService = firebaseService
    }
    
    func getFriendsWithProgress(for userId: String) async throws -> [FriendWithProgress] {
        let friendIds = try await firebaseService.getFriends(for: userId)
        
        // Load data for each friend in parallel - can have multiple challenges per friend
        let friendsData = await withTaskGroup(of: [FriendWithProgress].self) { group in
            for friendId in friendIds {
                group.addTask {
                    await self.loadAllFriendData(friendId: friendId)
                }
            }
            
            var results: [FriendWithProgress] = []
            for await friendResults in group {
                results.append(contentsOf: friendResults)
            }
            return results
        }
        
        return friendsData
    }
    
    private func loadAllFriendData(friendId: String) async -> [FriendWithProgress] {
        do {
            async let userTask = loadUser(userId: friendId)
            async let challengesTask = loadUserActiveChallenges(userId: friendId)
            
            let user = try await userTask
            let challengesData = try await challengesTask
            
            var friends: [FriendWithProgress] = []
            for (challenge, userChallenge) in challengesData {
                friends.append(FriendWithProgress(
                    user: user,
                    challenge: challenge,
                    userChallenge: userChallenge
                ))
            }
            
            if friends.isEmpty {
                friends.append(FriendWithProgress(
                    user: user,
                    challenge: nil,
                    userChallenge: nil
                ))
            }
            
            return friends
            
        } catch {
            print("Error loading friend data for \(friendId): \(error)")
            return []
        }
    }
    
    private func loadUser(userId: String) async throws -> User {
        guard let user = try await firebaseService.getUser(by: userId) else {
            throw NSError(domain: "UserError", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not found: \(userId)"])
        }
        return user
    }
    
    private func loadUserActiveChallenges(userId: String) async throws -> [(Challenge, UserChallenge)] {
        let userChallenges = try await firebaseService.getUserChallenges(for: userId)
        let activeChallenges = userChallenges.filter { $0.status == .active }
        
        var results: [(Challenge, UserChallenge)] = []
        for userChallenge in activeChallenges {
            if let challenge = try await firebaseService.getChallenge(by: userChallenge.challengeId) {
                results.append((challenge, userChallenge))
            }
        }
        
        return results
    }
    
    func observeFriendsUpdates(for userId: String) -> AnyPublisher<[FriendWithProgress], Error> {
        return Future<[FriendWithProgress], Error> { promise in
            Task {
                do {
                    let friendIds = try await self.firebaseService.getFriends(for: userId)
                    
                    // Start observing user challenges updates for all friends
                    self.firebaseService.observeUserChallengesUpdates(for: friendIds)
                        .sink(
                            receiveCompletion: { completion in
                                if case .failure(let error) = completion {
                                    promise(.failure(error))
                                }
                            },
                            receiveValue: { _ in
                                // When challenges update, reload friends data
                                Task {
                                    do {
                                        let friendsData = try await self.getFriendsWithProgress(for: userId)
                                        promise(.success(friendsData))
                                    } catch {
                                        promise(.failure(error))
                                    }
                                }
                            }
                        )
                        .store(in: &self.cancellables)
                    
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    private var cancellables = Set<AnyCancellable>()
}
