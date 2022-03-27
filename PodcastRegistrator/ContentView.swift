import SwiftUI
import AVFoundation

struct ContentView: View {

    var body: some View {
        TabView {
            TabAView().tabItem { VStack { Text("アップローダー") } }.tag(1)
            TabBView().tabItem { VStack { Text("コンバーター") } }.tag(2)
            TabCView().tabItem { VStack { Text("動画に変換") } }.tag(3)
            TabCView().tabItem { VStack { Text("ユーザー登録") } }.tag(4)
        }.frame(width: 500)
    }

    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
}
