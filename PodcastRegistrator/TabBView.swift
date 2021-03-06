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
    @State private var valueAmount : Float = -1;
    
    let gitRootPath : String = "/Users/nkjzm/Projects/xrfm.github.io"
    let audioRootPath : String = "/Users/nkjzm/Projects/xrfm.github.io/audio"
    let rawAudioRootPath : String = "/Users/nkjzm/Projects/xrfm.github.io/audio/raw"
    let mdRootPath : String = "/Users/nkjzm/Projects/xrfm.github.io/_posts"
    let artworkPath : String = "/Users/nkjzm/Dropbox/xrpodcast.png"

    func Convert(callback: @escaping () -> Void) -> Void {
        
        progress = "変換処理開始"
        self.valueAmount = 20
        
        let original = "\"\(audioPath)\""
        
        if enableSavingPreConvertedFile
        {
            let outputFilePath = "\(self.rawAudioRootPath)/\(TabBView.GetRawAudioName(number: self.number))"
            self.ConvertToMp3(path: original, outputFilePath: outputFilePath) {
                progress = "最適化前のファイルの保存が完了"
                self.valueAmount += 20
            }
        }
        
        if enableOptimization
        {
            
        }
        
        callback()
    }

    // wavファイルを変換してアートワークを設定する
    func ConvertToMp3(path : String, outputFilePath : String, callback: @escaping () -> Void) -> Void {
        
        let formatConverted : String = "\"\(gitRootPath)/format_converted.mp3\""
        
        let task = Process()
        task.launchPath = "/bin/sh"
        
        let convertArg = "/usr/local/bin/ffmpeg -i \(path) -f mp3 -b:a 192k \(outputFilePath) -y;"
        
        task.arguments = ["-c",convertArg]
        task.terminationHandler = { _ in callback()}
        
        // コマンド実行
        task.launch()
    }
    
    static func GetAudioName(number : String) -> String {
        let episodeNumber = Int(number)!
        return "xrfm_\(String(format: "%03d", episodeNumber)).mp3"
    }

    static func GetRawAudioName(number : String) -> String {
        let episodeNumber = Int(number)!
        return "xrfm_\(String(format: "%03d", episodeNumber))_raw.mp3"
    }
    
    var body: some View {
        
        VStack {
            Text("変換する内容を入力してください")
                .frame(maxWidth: .infinity)
            HStack(alignment: .center){
                Text("ファイル").frame(width: 100)
                Text("\(self.audioPath)").frame(maxWidth: .infinity)
                Button(action: {
                    self.audioPath = TabAView.OpenAudio()
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
                self.Convert(callback: {
                    progress = "変換処理完了"
                    self.valueAmount = 100
                })
            }) {
                Text("変換する")
            }.padding()
            if self.valueAmount > 0
            {
                if #available(OSX 11.0, *) {
                    ProgressView(self.progress, value : self.valueAmount, total : 100)
                } else {
                    HStack(alignment: .center){
                        Text("進捗状況").frame(width: 100)
                        Text(verbatim: progress)
                        Spacer()
                    }
                }
            }
        }.padding().frame(width: 400)
    }
}

struct TabBView_Previews: PreviewProvider {
    static var previews: some View {
        TabBView()
    }
}
