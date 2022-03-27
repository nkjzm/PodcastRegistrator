import Foundation
import SwiftUI

struct Tab_AddUser: View {

    @State private var userId: String = ""
    @State private var imagePath: String = "未選択"
    @State private var showingAlert = false

    func Convert() -> Void {
        showingAlert = true
    }

    var body: some View {

        VStack {
            HStack(alignment: .center) {
                Text("TwitterId").frame(width: 100)
                TextField("nkjzm", text: $userId)
            }
            HStack(alignment: .center) {
                Text("ファイル")
                    .frame(width: 100)
                Text("\(self.imagePath)").frame(maxWidth: .infinity)
                Button(action: {
                    self.imagePath = TabAView.OpenAudio()
                }) {
                    Text("アイコン画像を開く")
                }
            }
            Button(action: { self.Convert() }) {
                Text("変換する")
            }.padding()
                .alert("ユーザー追加完了", isPresented: $showingAlert) {
                Button("OK") {
                    // 了解ボタンが押された時の処理
                }
            } message: {
                Text(userId + "を追加しました。")
            }
        }.padding().frame(width: 400)
    }
}

struct Tab_AddUser_Previews: PreviewProvider {
    static var previews: some View {
        Tab_AddUser()
    }
}
