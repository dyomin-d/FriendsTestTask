import SwiftUI

protocol Coordinator: ObservableObject {
    associatedtype ContentView: View
    var contentView: ContentView { get }
}

final class AppCoordinator: Coordinator {
    @Published var selectedTab: MainTabType = .friends
    
    enum MainTabType: Int, CaseIterable {
        case home = 0
        case friends = 1
        case insights = 2
        case gallery = 3
        case profile = 4
        
        var title: String {
            switch self {
            case .home: return "Home"
            case .friends: return "Friends"
            case .insights: return "Insights"
            case .gallery: return "Gallery"
            case .profile: return "Profile"
            }
        }
        
        var iconName: String {
            switch self {
            case .home: return "house"
            case .friends: return "person.2"
            case .insights: return "chart.bar"
            case .gallery: return "photo"
            case .profile: return "person.circle"
            }
        }
    }
    
    @MainActor
    var contentView: some View {
        TabView(selection: Binding(
            get: { self.selectedTab },
            set: { self.selectedTab = $0 }
        )) {
            ForEach(MainTabType.allCases, id: \.self) { tab in
                self.tabContent(for: tab)
                    .tabItem {
                        Image(systemName: tab.iconName)
                        Text(tab.title)
                    }
                    .tag(tab)
            }
        }
        .preferredColorScheme(.dark)
    }
    
    @MainActor
    @ViewBuilder
    private func tabContent(for tab: MainTabType) -> some View {
        switch tab {
        case .friends:
            FriendsCoordinator().contentView
        case .home, .insights, .gallery, .profile:
            PlaceholderView(title: tab.title)
        }
    }
}

struct PlaceholderView: View {
    let title: String
    
    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "hammer.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.gray)
                Text("\(title) Screen")
                    .font(.title)
                    .foregroundColor(.gray)
                Text("Coming Soon")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .navigationTitle(title)
        }
    }
}
