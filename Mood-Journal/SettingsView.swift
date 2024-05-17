import SwiftUI
import LocalAuthentication

struct SettingsView: View {
    @EnvironmentObject var globalData: GlobalData
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack {
            Text("Settings")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
//            // Sleep Time Slider
//            Slider(value: $globalData.sleepTime, in: 0...24, step: 0.5) {
//                Text("Sleep Time")
//            }
//            .padding()
//            
//            Text("Selected Sleep Time: \(globalData.sleepTime, specifier: "%.1f") hours")
            
            // Theme Picker
            Picker("Theme", selection: $globalData.selectedTheme) {
                ForEach(GlobalData.Theme.allCases, id: \.self) { theme in
                    Text(theme.rawValue).tag(theme)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            // Face ID Toggle
            Toggle("Enable Face ID", isOn: $globalData.isFaceIDEnabled)
                .padding()
                .onChange(of: globalData.isFaceIDEnabled) { newValue in
                    if newValue {
                        authenticateUser()
                    }
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
            Alert(title: Text("Authentication Failed"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
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

#Preview {
    SettingsView().environmentObject(GlobalData())
}
