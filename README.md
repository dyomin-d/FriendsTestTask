## 🎯 Features

- **Friends Grid**: Horizontal scrollable list of friends with their avatars and challenge progress
- **Activity Feed**: Real-time activity updates from friends' challenges
- **Challenge Progress**: Visual indicators showing current day and task completion
- **User Filtering**: Tap on a friend to filter activities by that specific user
- **Real-time Updates**: Live data synchronization with Firebase Firestore

## 🏗️ Architecture

The app follows **MVVM+C** pattern:

- **Models**: `User`, `Challenge`, `UserChallenge`, `Friendship`, `FriendWithProgress`
- **Views**: SwiftUI views with components for modularity
- **ViewModels**: `FriendsViewModel` handles business logic and state management
- **Coordinators**: `AppCoordinator`, `FriendsCoordinator` manage navigation flow
- **Services**: `FirebaseService`, `FriendsService` handle data operations

## 🛠️ Tech Stack

- **SwiftUI** - UI framework
- **Firebase Firestore** - Real-time NoSQL database
- **Swift Concurrency** - Async/await for initial data loading
- **Combine Framework** - Reactive programming for real-time updates
- **MVVM+C Architecture** - Clean, scalable code organization

## 🔥 Firebase Database

**Database URL**: [https://console.firebase.google.com/project/friends-test-task/overview](https://console.firebase.google.com/project/friends-test-task/overview)

### Collections Structure:

```
users/
├── userId: {
│   ├── displayName: string
│   ├── email: string
│   └── avatarUrl: string
│   }

challenges/
├── challengeId: {
│   ├── title: string
│   ├── description: string
│   ├── duration: number (days)
│   ├── tasksPerDay: number
│   └── isActive: boolean
│   }

userChallenges/
├── userChallengeId: {
│   ├── userId: string
│   ├── challengeId: string
│   ├── currentDay: number
│   ├── status: "active" | "completed" | "paused"
│   ├── completedTasks: number
│   ├── totalTasks: number
│   ├── startDate: timestamp
│   └── lastUpdated: timestamp
│   }

friendships/
├── friendshipId: {
│   ├── userId1: string
│   ├── userId2: string
│   └── status: "active"
│   }
```

## ⚙️ Configuration & Mocked Data

### Current User
- **Hardcoded**: Currently set to `"ben"` in `FriendsViewModel`
- **Location**: `FriendsTestTask/ViewModels/FriendsViewModel.swift:12`
- **TODO**: Replace with actual authentication system

### Task Names
- **Randomized**: Task names are selected from a predefined list
- **Examples**: "Morning run", "Meditation session", "Healthy breakfast", etc.
- **Location**: `ActivityRowView.randomTaskName` computed property

## 📱 UI Features

### Friends Section
- Shows up to 4 friends in grid view
- Horizontal scrolling for more friends
- Shows "Invite" placeholders when less than 4 friends
- Displays current day badge and task progress

### Activity Section
- Chronological feed of friend activities
- Real-time time stamps (5m ago, 2h ago, Yesterday)
- Challenge progress with "X to go" indicators
- Tap friends to filter activities by user

## 📝 Key Implementation Details

### Data Flow
1. `FriendsViewModel` loads initial data via `FriendsService`
2. `FriendsService` orchestrates parallel data loading from `FirebaseService`
3. Real-time updates flow through Combine publishers
4. UI automatically updates via SwiftUI's reactive bindings

### Performance Optimizations
- **Parallel loading**: Multiple API calls executed concurrently
- **Efficient updates**: Only changed data triggers UI updates
- **Memory management**: Proper cleanup of Combine subscriptions

### Error Handling
- Network errors displayed to user
- Graceful fallbacks for missing data
- Loading states with progress indicators

---