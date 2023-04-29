import SwiftUI
import AVFoundation

struct ContentView: View {
    
    @AppStorage("selection") private var selection = 0
    
    var body: some View {
        TabView(selection: $selection) {
            UploadView().tabItem { Text("アップローダー") }.tag(1)
            ConvertAudioView().tabItem { Text("コンバーター")  }.tag(2)
            ConvertToVideoView().tabItem { Text("動画に変換")  }.tag(3)
            AddUserView().tabItem { Text("ユーザー登録")  }.tag(4)
        }
    }
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
}
