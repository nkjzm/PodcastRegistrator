import SwiftUI

@main
struct LifeCycleSwiftUIApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView().frame(minWidth: 800)
        }
        #if os(macOS)
        Settings {
            SettingsView()
        }
        #endif
    }
}
