import Foundation
import SwiftUI

struct Tab_AddUser: View {
    
    @State private var userId : String  = ""
    @State private var imagePath : String = "未選択"
    
    func Convert() -> Void {
        
    }
    
    var body: some View {
        
        VStack {
            HStack(alignment: .center){
                Text("TwitterId").frame(width: 100)
                TextField("nkjzm", text: $userId)
            }
            HStack(alignment: .center){
                Text("ファイル")
                    .frame(width: 100)
                Text("\(self.imagePath)").frame(maxWidth: .infinity)
                Button(action: {
                    self.imagePath = TabAView.OpenAudio()
                }){
                    Text("アイコン画像を開く")
                }
            }
            Button(action: {self.Convert()}) {
                Text("変換する")
            }.padding()
        }.padding().frame(width: 400)
    }
}

struct Tab_AddUser_Previews: PreviewProvider {
    static var previews: some View {
        Tab_AddUser()
    }
}
