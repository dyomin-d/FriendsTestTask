# Friends Test Task - iOS SwiftUI App

A modern iOS application built with SwiftUI that displays a friends list with their challenge activities and progress tracking.

## 🎯 Features

- **Friends Grid**: Horizontal scrollable list of friends with their avatars and challenge progress
- **Activity Feed**: Real-time activity updates from friends' challenges
- **Challenge Progress**: Visual indicators showing current day and task completion
- **User Filtering**: Tap on a friend to filter activities by that specific user
- **Real-time Updates**: Live data synchronization with Firebase Firestore

## 🏗️ Architecture

The app follows **MVVM+C (Model-View-ViewModel-Coordinator)** pattern:

- **Models**: `User`, `Challenge`, `UserChallenge`, `Friendship`, `FriendWithProgress`
- **Views**: SwiftUI views with components for modularity
- **ViewModels**: `FriendsViewModel` handles business logic and state management
- **Coordinators**: `AppCoordinator`, `FriendsCoordinator` manage navigation flow
- **Services**: `FirebaseService`, `FriendsService` handle data operations

## 🛠️ Tech Stack

- **SwiftUI** - Modern declarative UI framework
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

### Activity Timestamps
- **Randomized**: Activity times are generated using seeded randomization
- **Range**: Between 6 AM and current time (or 11 PM if current time is later)
- **Consistency**: Same challenge always shows the same time based on user+challenge ID
- **Location**: `FriendWithProgress.randomTimeToday` computed property

### Task Names
- **Randomized**: Task names are selected from a predefined list
- **Examples**: "Morning run", "Meditation session", "Healthy breakfast", etc.
- **Location**: `ActivityRowView.randomTaskName` computed property

## 🚀 Getting Started

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd FriendsTestTask
   ```

2. **Open in Xcode**
   ```bash
   open FriendsTestTask.xcodeproj
   ```

3. **Install Dependencies**
   - Firebase SDK is already configured in the project
   - `GoogleService-Info.plist` is included

4. **Run the app**
   - Select a simulator or device
   - Press `Cmd + R` to build and run

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

## 🔄 Real-time Updates

The app uses **Combine framework** with Firebase's `addSnapshotListener` to provide real-time updates:

- Friend list updates automatically when data changes
- Activity feed refreshes with new challenge progress
- No manual refresh needed - everything updates live

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

**Project Status**: ✅ Complete - Ready for review and testing

**Last Updated**: December 2024