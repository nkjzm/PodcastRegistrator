import SwiftUI

@main
struct LifeCycleSwiftUIApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView().frame(width: 500)
        }
        #if os(macOS)
        Settings {
            SettingsView()
        }
        #endif
    }
}
