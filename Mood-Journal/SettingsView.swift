import SwiftUI
import LocalAuthentication
import UIKit

struct SettingsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var globalData: GlobalData
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var backupURL: URL?
    @State private var showShareSheet = false

    var body: some View {
        VStack {
            Text("Settings")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            // Theme Picker
            Picker("Theme", selection: $globalData.selectedTheme) {
                ForEach(GlobalData.Theme.allCases, id: \.self) { theme in
                    Text(theme.rawValue).tag(theme)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            // Backup Button
            Button(action: backupJournalEntries) {
                Text("Backup Journal Entries")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
        }
        .padding()
        .onChange(of: globalData.selectedTheme) { _ in
            applyTheme(globalData.selectedTheme)
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
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Backup Complete"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .sheet(isPresented: $showShareSheet) {
            if let url = backupURL {
                ShareSheet(activityItems: [url])
            }
        }
    }
    
    private func applyTheme(_ theme: GlobalData.Theme) {
        switch theme {
        case .light:
            UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .light
        case .dark:
            UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .dark
        case .device:
            UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .unspecified
        }
    }
    
    private func backupJournalEntries() {
        if let backupURL = BackupService.shared.backupJournalEntries(viewContext: viewContext) {
            self.backupURL = backupURL
            self.alertMessage = "Your backup has been created successfully."
            self.showShareSheet = true
        } else {
            self.alertMessage = "Failed to create backup. Please try again."
        }
        self.showAlert = true
    }

    private func authenticateUser() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Authenticate to access the app"

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        globalData.isFaceIDEnabled = true
                    } else {
                        globalData.isFaceIDEnabled = false
                        alertMessage = authenticationError?.localizedDescription ?? "Unknown error"
                        showAlert = true
                    }
                }
            }
        } else {
            globalData.isFaceIDEnabled = false
            alertMessage = error?.localizedDescription ?? "Face ID/Touch ID not available"
            showAlert = true
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    SettingsView().environmentObject(GlobalData())
}
