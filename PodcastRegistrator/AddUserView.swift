import Foundation
import SwiftUI

struct AddUserView: View {
    
    @AppStorage("guestUserId") private var userId: String = ""
    @State private var imagePath: String = "未選択"
    @State private var showingAlert = false
        
    func Convert() -> Void {
        
        // 拡張子を取得
        let path = NSString(string: imagePath)
        let pathExtension = "." + path.pathExtension
        
        let imageName = userId + pathExtension
        // アイコンを保存
        SameImage(sourcePath: imagePath, outputPath: "\(actorImageRootPath)/\(imageName)")
        
        print(LoadTextFile(filePath: configPath))
        var configText = LoadTextFile(filePath: configPath)
        
        let actor = """
              \(userId):
                image_url: /images/actors/\(imageName)
                name: \(userId)
                url: https://twitter.com/\(userId)
            author: nkjzm
            """
        
        configText = configText.replacingOccurrences(of: "author: nkjzm", with: actor)
        
        SaveTextFile(filePath: configPath, message: configText)
        
        showingAlert = true
    }
    
    // Gitリポジトリにアップロード
    func SameImage(sourcePath: String, outputPath: String) -> Void {
        print(sourcePath)
        print(outputPath)
        let task = Process()
        // 起動するプログラムを絶対パスで指定
        task.launchPath = "/bin/sh"
        // オプションを指定
        task.arguments = ["-c", "mv \(sourcePath) \(outputPath);"]
        // コマンド実行
        task.launch()
    }
    
    var body: some View {
        
        VStack {
            HStack(alignment: .center) {
                Text("TwitterId").frame(width: 100)
                TextField("nkjzm", text: $userId)
            }
            HStack(alignment: .center) {
                Text("ファイル").frame(width: 150)
                VStack{
                    if let image = loadImage(from: imagePath) {
                        Image(nsImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                    } else {
                        Text("画像が見つかりません")
                    }
                    HStack(alignment: .center) {
                        Text(self.imagePath)
                        Button(action: {
                            self.imagePath = openImage()
                        }) {
                            Text("アイコン画像を選択")
                        }.frame(maxWidth: .infinity)
                    }
                }
            }
            Button(action: { self.Convert() }) {
                Text("追加する")
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
        AddUserView()
    }
}
