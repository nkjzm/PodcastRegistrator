import SwiftUI
import AVFoundation

struct ContentView: View {

    @AppStorage("selection") private var selection = 0

    var body: some View {
        TabView(selection: $selection) {
            TabAView().tabItem { VStack { Text("アップローダー") } }.tag(1)
            TabBView().tabItem { VStack { Text("コンバーター") } }.tag(2)
            TabCView().tabItem { VStack { Text("動画に変換") } }.tag(3)
            Tab_AddUser().tabItem { VStack { Text("ユーザー登録") } }.tag(4)
        }.frame(width: 500)
    }

    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
}
