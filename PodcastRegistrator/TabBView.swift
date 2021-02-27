//
//  TabBView.swift
//  PodcastRegistrator
//
//  Created by 中地功貴 on 2021/02/27.
//  Copyright © 2021 Nakaji Kohki. All rights reserved.
//

import Foundation
import SwiftUI

struct TabBView: View {
    
    @State private var number : String  = ""
    @State private var audioPath : String = "未選択"
    @State private var progress : String = "処理開始前"
    @State private var enableSavingPreConvertedFile = true
    @State private var enableOptimization = false
    
    
    var body: some View {
        
        VStack {
            Text("変換する内容を入力してください")
                .frame(maxWidth: .infinity)
            HStack(alignment: .center){
                Text("ファイル").frame(width: 100)
                Text("\(self.audioPath)").frame(maxWidth: .infinity)
                Button(action: {
                    //self.audioPath = self.OpenAudio()
                }){
                    Text("オーディオファイルを開く")
                }
            }
            HStack(alignment: .center){
                Text("回数").frame(width: 100)
                TextField("0", text: $number)
            }
            HStack(alignment: .center){
                Text("変換オプション").frame(width: 100)
                VStack(alignment: HorizontalAlignment.leading){
                    Toggle(isOn: $enableSavingPreConvertedFile) {
                        Text("最適化前のファイルを保存する")
                    }.disabled(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                    Toggle(isOn: $enableOptimization) {
                        Text("最適化処理を有効にする")
                    }
                }
                Spacer()
            }
            Button(action: {
                //self.ConvertAndUpload()
            }) {
                Text("変換する")
            }.padding()
            HStack(alignment: .center){
                Text("進捗状況").frame(width: 100)
                Text(verbatim: progress)
                Spacer()
            }
        }.padding().frame(width: 400)
    }
}

struct TabBView_Previews: PreviewProvider {
    static var previews: some View {
        TabBView()
    }
}
