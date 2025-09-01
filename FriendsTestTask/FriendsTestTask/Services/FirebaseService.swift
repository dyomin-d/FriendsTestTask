import Foundation
import FirebaseFirestore
import Combine

protocol FirebaseServiceProtocol {
    func getUsers() async throws -> [User]
    func getUser(by id: String) async throws -> User?
    func getChallenges() async throws -> [Challenge]
    func getUserChallenges(for userId: String) async throws -> [UserChallenge]
    func getFriends(for userId: String) async throws -> [String]
    func getChallenge(by id: String) async throws -> Challenge?
    func observeUserChallengesUpdates(for userIds: [String]) -> AnyPublisher<[UserChallenge], Error>
}

final class FirebaseService: FirebaseServiceProtocol {
    private let db = Firestore.firestore()
    
    func getUsers() async throws -> [User] {
        let snapshot = try await db.collection("users").getDocuments()
        
        return snapshot.documents.compactMap { document in
            let data = document.data()
            guard let displayName = data["displayName"] as? String,
                  let email = data["email"] as? String else {
                return nil
            }
            
            return User(
                id: document.documentID,
                displayName: displayName,
                email: email,
                avatarUrl: data["avatarUrl"] as? String
            )
        }
    }
    
    func getChallenges() async throws -> [Challenge] {
        let snapshot = try await db.collection("challenges").getDocuments()
        
        return snapshot.documents.compactMap { document in
            let data = document.data()
            guard let title = data["title"] as? String,
                  let description = data["description"] as? String,
                  let duration = data["duration"] as? Int,
                  let tasksPerDay = data["tasksPerDay"] as? Int else {
                return nil
            }
            
            return Challenge(
                id: document.documentID,
                title: title,
                description: description,
                duration: duration,
                tasksPerDay: tasksPerDay,
                isActive: data["isActive"] as? Bool ?? true
            )
        }
    }
    
    func getUserChallenges(for userId: String) async throws -> [UserChallenge] {
        let snapshot = try await db.collection("userChallenges")
            .whereField("userId", isEqualTo: userId)
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            let data = document.data()
            guard let userId = data["userId"] as? String,
                  let challengeId = data["challengeId"] as? String,
                  let currentDay = data["currentDay"] as? Int,
                  let statusString = data["status"] as? String,
                  let status = UserChallenge.ChallengeStatus(rawValue: statusString),
                  let completedTasks = data["completedTasks"] as? Int,
                  let totalTasks = data["totalTasks"] as? Int else {
                return nil
            }
            
            return UserChallenge(
                id: document.documentID,
                userId: userId,
                challengeId: challengeId,
                currentDay: currentDay,
                status: status,
                completedTasks: completedTasks,
                totalTasks: totalTasks
            )
        }
    }
    
    func getFriends(for userId: String) async throws -> [String] {
        // Find friendships where user is userId1
        let snapshot1 = try await db.collection("friendships")
            .whereField("userId1", isEqualTo: userId)
            .getDocuments()
        
        // Find friendships where user is userId2
        let snapshot2 = try await db.collection("friendships")
            .whereField("userId2", isEqualTo: userId)
            .getDocuments()
            
        var friendIds: Set<String> = []
        
        // Extract friends from first query
        for document in snapshot1.documents {
            let data = document.data()
            let status = data["status"] as? String ?? "no_status"
            
            if let friendId = data["userId2"] as? String, status == "active" {
                friendIds.insert(friendId)
            }
        }
        
        // Extract friends from second query
        for document in snapshot2.documents {
            let data = document.data()
            let status = data["status"] as? String ?? "no_status"
            
            if let friendId = data["userId1"] as? String, status == "active" {
                friendIds.insert(friendId)
            }
        }
        
        return Array(friendIds)
    }
    
    func getUser(by id: String) async throws -> User? {
        let document = try await db.collection("users").document(id).getDocument()
        
        guard let data = document.data(),
              let displayName = data["displayName"] as? String,
              let email = data["email"] as? String else {
            return nil
        }
        
        return User(
            id: document.documentID,
            displayName: displayName,
            email: email,
            avatarUrl: data["avatarUrl"] as? String
        )
    }
    
    func getChallenge(by id: String) async throws -> Challenge? {
        let document = try await db.collection("challenges").document(id).getDocument()
        
        guard let data = document.data(),
              let title = data["title"] as? String,
              let description = data["description"] as? String,
              let duration = data["duration"] as? Int,
              let tasksPerDay = data["tasksPerDay"] as? Int else {
            return nil
        }
        
        return Challenge(
            id: document.documentID,
            title: title,
            description: description,
            duration: duration,
            tasksPerDay: tasksPerDay,
            isActive: data["isActive"] as? Bool ?? true
        )
    }
    
    func observeUserChallengesUpdates(for userIds: [String]) -> AnyPublisher<[UserChallenge], Error> {
        guard !userIds.isEmpty else {
            return Just([])
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        return Future<[UserChallenge], Error> { promise in
            _ = self.db.collection("userChallenges")
                .whereField("userId", in: userIds)
                .addSnapshotListener { snapshot, error in
                    if let error = error {
                        promise(.failure(error))
                        return
                    }
                    
                    guard let documents = snapshot?.documents else {
                        promise(.success([]))
                        return
                    }
                    
                    let userChallenges = documents.compactMap { document -> UserChallenge? in
                        let data = document.data()
                        guard let userId = data["userId"] as? String,
                              let challengeId = data["challengeId"] as? String,
                              let currentDay = data["currentDay"] as? Int,
                              let statusString = data["status"] as? String,
                              let status = UserChallenge.ChallengeStatus(rawValue: statusString),
                              let completedTasks = data["completedTasks"] as? Int,
                              let totalTasks = data["totalTasks"] as? Int else {
                            return nil
                        }
                        
                        return UserChallenge(
                            id: document.documentID,
                            userId: userId,
                            challengeId: challengeId,
                            currentDay: currentDay,
                            status: status,
                            completedTasks: completedTasks,
                            totalTasks: totalTasks
                        )
                    }
                    
                    promise(.success(userChallenges))
                }
        }
        .eraseToAnyPublisher()
    }
}
