import SwiftUI
import AVFoundation

struct ContentView: View {
    
    var body: some View {
        TabView {
            TabAView()
                .tabItem {
                    VStack {
//                        Image(systemName: "a")
                        Text("アップローダー")
                    }
            }.tag(1)
            TabBView()
                .tabItem {
                    VStack {
//                        Image(systemName: "bold")
                        Text("コンバーター")
                        
                    }
            }.tag(2).frame(width: 500)
        }
    }
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
}
