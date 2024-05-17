import SwiftUI
import LocalAuthentication

struct ContentView: View {
    @EnvironmentObject var globalData: GlobalData
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            JournalView()
                .tabItem {
                    Label("Journal", systemImage: "book.fill")
                }
            
            StatsView()
                .tabItem {
                    Label("Stats", systemImage: "chart.bar.fill")
                }
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .onAppear {
            NotificationCenter.default.addObserver(forName: .appDidBecomeActive, object: nil, queue: .main) { _ in
                if globalData.isFaceIDEnabled {
                    authenticateUser()
                }
            }
        }
        .onDisappear {
            NotificationCenter.default.removeObserver(self, name: .appDidBecomeActive, object: nil)
        }
    }
    
    private func authenticateUser() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Authenticate to access the app"

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if !success {
                        globalData.isFaceIDEnabled = false
                        // Optionally show alert or handle authentication error
                    }
                }
            }
        } else {
            globalData.isFaceIDEnabled = false
            // Optionally show alert or handle no biometric capability
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(GlobalData())
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
