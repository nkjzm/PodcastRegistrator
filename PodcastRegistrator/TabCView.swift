//
//  TabCView.swift
//  PodcastRegistrator
//
//  Created by Nakaji Kohki on 2022/03/01.
//  Copyright © 2022 Nakaji Kohki. All rights reserved.
//

import Foundation
import SwiftUI


struct TabCView: View {
    
    @State private var number : String  = ""
    @State private var progress : String = "処理開始前"
    // 一括変換
    @State private var enableMultipleConvert = false
    @State private var valueAmount : Float = -1;
    
    let gitRootPath : String = "/Users/nkjzm/Projects/xrfm.github.io"
    let audioRootPath : String = "/Users/nkjzm/Projects/xrfm.github.io/audio"
    let movieRootPath : String = "/Users/nkjzm/Projects/xrfm.github.io/movie"
    let mdRootPath : String = "/Users/nkjzm/Projects/xrfm.github.io/_posts"
    let artworkPath : String = "/Users/nkjzm/Dropbox/xrpodcast.png"
    let thubnailPath : String = "/Users/nkjzm/Projects/xrfm.github.io/images/thumbnail.png"
    
    func Convert(callback: @escaping () -> Void) -> Void {
        
        progress = "変換処理開始"
        self.valueAmount = 0.1
        
        
        if(self.enableMultipleConvert){
            convertMultiple()
        }else{
            convert(number: self.number, rate: 100)
        }
        
        callback()
    }
    
    func convertMultiple()
    {
        let files = getFileInfoListInDir(self.audioRootPath)
        let rate : Float = 100.0 / Float(files.count)
        
        for (_,file) in files.enumerated() {
            
            if(file == ".DS_Store" || file == "raw")
            {
                continue
            }
            
            let number = file.replacingOccurrences(of: ".mp3", with: "")
            
            convert(number: number, rate: rate)
        }
    }
    
    func convert(number: String, rate: Float)
    {
        let original = "\(self.audioRootPath)/\(TabBView.GetAudioName(number: number))"
        let outputFilePath = "\(self.movieRootPath)/\(TabBView.GetMovieName(number: number))"
        
        progress = "変換開始: " + number
        
        self.ConvertToMp4(path: original, outputFilePath: outputFilePath) {
            progress = "変換完了: " + number
            self.valueAmount += rate
        }
    }
    
    func getFileInfoListInDir(_ dirName: String) -> [String] {
        let fileManager = FileManager.default
        var files: [String] = []
        do {
            files = try fileManager.contentsOfDirectory(atPath: dirName)
        } catch {
            return files
        }
        return files
    }
    
    // wavファイルを変換してアートワークを設定する
    func ConvertToMp4(path : String, outputFilePath : String, callback: @escaping () -> Void) -> Void {
        
        let task = Process()
        task.launchPath = "/bin/sh"
        
        let convertArg = """
        /usr/local/bin/ffmpeg \
            -t `/usr/local/bin/ffprobe -v error -i \(path) -show_format | grep duration= | cut -d '=' -f 2` \
            -loop 1 \
            -r 1 \
            -i \(self.thubnailPath) \
            -i \(path) \
            -vcodec libx264 \
            -pix_fmt yuv420p \
            -shortest \
            \(outputFilePath);
        """
        
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
            Toggle(isOn: $enableMultipleConvert) {
                Text("一括変換する")
            }.padding()
            if !self.enableMultipleConvert
            {
                HStack(alignment: .center){
                    Text("回数").frame(width: 100)
                    TextField("0", text: $number)
                }
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

struct TabCView_Previews: PreviewProvider {
    static var previews: some View {
        TabCView()
    }
}
