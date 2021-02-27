//
//  TabAView.swift
//  PodcastRegistrator
//
//  Created by 中地功貴 on 2021/02/27.
//  Copyright © 2021 Nakaji Kohki. All rights reserved.
//

import Foundation
import SwiftUI
import AVFoundation

struct TabAView: View {
    
    @State private var number : String  = ""
    @State private var audioPath : String = "未選択"
    @State private var title : String = ""
    @State private var description : String = ""
    @State private var progress : String = "処理開始前"
    @State var date = Date()
    
    let gitRootPath : String = "/Users/nkjzm/Projects/xrfm.github.io"
    let audioRootPath : String = "/Users/nkjzm/Projects/xrfm.github.io/audio"
    let mdRootPath : String = "/Users/nkjzm/Projects/xrfm.github.io/_posts"
    let artworkPath : String = "/Users/nkjzm/Dropbox/xrpodcast.png"
    
    // wavファイルを変換してアートワークを設定する
    func ConvertToMp3(path : String ,filename : String, callback: @escaping () -> Void) -> Void {
        
        let noiseProf : String = "\"\(gitRootPath)/noise.prof\""
        let noiseRemoved : String = "\"\(gitRootPath)/noise_removed.wav\""
        let silenceRemoved : String = "\"\(gitRootPath)/silence_removed.wav\""
        let formatConverted : String = "\"\(gitRootPath)/format_converted.mp3\""
        
        let task = Process()
        task.launchPath = "/bin/sh"
        
        let createNoiseprofArg = "/usr/local/bin/sox \"\(path)\" -n noiseprof \(noiseProf);"
        let removeNoiseArg = "/usr/local/bin/sox \"\(path)\" \(noiseRemoved) noisered \(noiseProf) 0.2;"
        //let compressArg = "/usr/local/bin/sox \(noiseRemoved) \(gitRootPath)/compressed.wav\" compand 0.01,1 -90,-90,-70,-70,-60,-20,0,0 -5;"
        let removeSilenceArg = "/usr/local/bin/sox \(noiseRemoved) \(silenceRemoved) silence -l 1 0.1 1% -1 0.8 15%;"
        let convertArg = "/usr/local/bin/ffmpeg -i \(silenceRemoved) -f mp3 -b:a 192k \(formatConverted) -y;"
        let addArtworkArg = "/usr/local/bin/ffmpeg -i \(formatConverted) -i \(artworkPath) -disposition:v:1 attached_pic -map 0 -map 1 -c copy -id3v2_version 3 -metadata:s:v title=\"Album cover\" -metadata:s:v comment=\"Cover (front)\" \(audioRootPath)/\(filename);"
        let removeFilesArg = "rm \(noiseProf) \(noiseRemoved) \(silenceRemoved) \(formatConverted);"
        task.arguments = ["-c", createNoiseprofArg + removeNoiseArg + removeSilenceArg + convertArg + addArtworkArg + removeFilesArg]
        task.terminationHandler = { _ in callback()}
        // コマンド実行
        task.launch()
    }
    
    // ファイルを作成
    func Touch(filename : String) -> Void {
        let task = Process()
        // 起動するプログラムを絶対パスで指定
        task.launchPath = "/usr/bin/touch"
        // オプションを指定
        task.arguments = ["\(mdRootPath)/\(filename)"]
        // コマンド実行
        task.launch()
    }
    
    // ファイルサイズを取得
    func GetFileSize(filename : String, callback: @escaping (String) -> Void) -> Void {
        let task = Process()
        // 起動するプログラムを絶対パスで指定
        task.launchPath = "/usr/bin/wc"
        // オプションを指定
        task.arguments = ["-c", "\(audioRootPath)/\(filename)"]
        print(task.arguments)
        
        let pipe = Pipe()
        task.standardOutput = pipe
        
        task.terminationHandler = {
            (process: Process) -> Void in
            
            let readHandle = pipe.fileHandleForReading
            let data = readHandle.readDataToEndOfFile()
            
            if let output = String(data: data, encoding: .utf8)
            {
                let arr:[String] = output.components(separatedBy: " ")
                callback(arr[1])
            }
        }
        // コマンド実行
        task.launch()
    }
    
    func SaveFile(filename : String, message : String, callback: @escaping () -> Void) -> Void {
        // 保存する場所
        let filePath = "\(mdRootPath)/\(filename)"
        
        // 保存処理
        do {
            try message.write(toFile: filePath, atomically: true, encoding: String.Encoding.utf8)
            callback();
        } catch { }
    }
    
    // オーディオファイルを開く
    static func OpenAudio() -> String {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false   //複数ファイルの選択
        openPanel.canChooseDirectories    = false   //ディレクトリの選択
        openPanel.canCreateDirectories    = false   //ディレクトリの作成
        openPanel.canChooseFiles          = true    //ファイルの選択
        openPanel.allowedFileTypes        = ["wav", "mp3"] //ファイルの種類
        
        let reault = openPanel.runModal()
        if( reault == NSApplication.ModalResponse.OK ) {
            if let panelURL = openPanel.url {
                
                let path:String = panelURL.path
                print(path)
                return path
            }
        }
        return ""
    }
    
    // Gitリポジトリにアップロード
    func Upload(audioFilename: String, mdFilename: String, count: Int, callback: @escaping () -> Void) -> Void {
        let task = Process()
        // 起動するプログラムを絶対パスで指定
        task.launchPath = "/bin/sh"
        // オプションを指定
        task.arguments = ["-c", "cd \(gitRootPath); pwd; git add \(audioRootPath)/\(audioFilename); git add \(mdRootPath)/\(mdFilename); git commit -m \"Add \(count)\"; git push origin master"]
        task.terminationHandler = { _ in
            callback()
        }
        // コマンド実行
        task.launch()
    }
    
    // 音声ファイルを変換してGitリポジトリにアップロード
    func ConvertAndUpload()->Void{
        let episodeNumber = Int(number)!
        let audioFilename = TabBView.GetAudioName(number: self.number)

        self.progress = "音声ファイルを変換しています"
        
        // 音声ファイルの変換
        self.ConvertToMp3(path: self.audioPath, filename: audioFilename, callback: {
            
            // mdファイルの名前を取得
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd" // 日付フォーマットの設定
            let dateStr = dateFormatter.string(from: self.date)
            let mdFilename = "\(dateStr)-\(episodeNumber).md"
            
            // mdファイルを作成
            self.Touch(filename: mdFilename)
            
            self.progress = "mdファイルを生成しています"
            
            print("GetFileSize前")
            
            // 音声ファイルのサイズ取得
            self.GetFileSize(filename: audioFilename, callback: { out in
                
                // サイズをMB表記に変換
                let size = String(format: "%.01f", Float(out)!/1000000)
                
                // 音声の長さを取得
                let asset = AVURLAsset(url: URL(fileURLWithPath: "\(self.audioRootPath)/\(audioFilename)"))
                let duration =  Double(CMTimeGetSeconds(asset.duration))
                
                // 秒数を時間に整形
                let formatter = DateComponentsFormatter()
                formatter.unitsStyle = .positional
                formatter.allowedUnits = [.minute,.hour,.second]
                let outputString = formatter.string(from: duration)!
                
                let message = """
                ---
                actor_ids:
                - ikkou
                - nkjzm
                audio_file_path: /audio/\(audioFilename)
                audio_file_size: \(size) MB
                date: \(dateStr) 00:00:00 +0900
                description: "\(self.description)"
                duration: "\(outputString)"
                layout: article
                title: 第\(episodeNumber)回「\(self.title)」
                ---
                
                ## 関連リンク
                
                - 公式Twitter: [@xRfrn](https://twitter.com/xrfrn)
                - ハッシュタグ: [#xRfm](https://twitter.com/hashtag/xRfm?src=hash)
                """
                
                self.progress = "mdファイルを書き込んでいます"
                
                // mdファイルに書き込み
                self.SaveFile(filename: mdFilename, message: message, callback: {
                    
                    self.progress = "アップロード中"
                    
                    // Gitリポジトリにアップロード
                    self.Upload(audioFilename: audioFilename, mdFilename: mdFilename, count: episodeNumber, callback: {
                    self.progress = "アップロード完了!"
                    })
                })
            })
        })
    }
    
    var body: some View {
        VStack {
            Text("エピソードの情報を入力してください")
                .frame(maxWidth: .infinity)
            HStack(alignment: .center){
                Text("ファイル")
                    .frame(width: 100)
                Text("\(self.audioPath)").frame(maxWidth: .infinity)
                Button(action: {
                    self.audioPath = TabAView.OpenAudio()
                }){
                    Text("オーディオファイルを開く")
                }
            }
            HStack(alignment: .center){
                Text("回数")
                    .frame(width: 100)
                TextField("0", text: $number)
            }
            DatePicker(selection: $date,
                       in: ...Date(), displayedComponents: .date
            ){
                Text("収録日")
                    .frame(width: 100)
            }
            HStack(alignment: .center){
                Text("タイトル")
                    .frame(width: 100)
                Spacer()
                TextField("エピソードのタイトルを入力", text: $title)
            }
            HStack(alignment: .center){
                Text("内容")
                    .frame(width: 100)
                Spacer()
                TextField("エピソードの説明を入力", text: $description)
            }
            Button(action: {
                self.ConvertAndUpload()
            }) {
                Text("アップロード")
            }.padding()
            HStack(alignment: .center){
                Text("進捗状況")
                    .frame(width: 100)
                Text(verbatim: progress)
                Spacer()
            }
        }.padding().frame(width: 400)
    }
}

struct TabAView_Previews: PreviewProvider {
    static var previews: some View {
        TabAView()
    }
}
