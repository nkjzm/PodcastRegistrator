import Foundation
import SwiftUI
import AVFoundation

struct TabAView: View {
    
    @State private var enableConvert: Bool = true
    @AppStorage("episodeNumber") private var episodeNumber: Int = 0
    @State private var audioPath: String = "未選択"
    @AppStorage("title") private var title: String = ""
    @AppStorage("description") private var description: String = ""
    @State private var content: String = """
    ## 関連リンク
    
    - 公式Twitter: [@xRfrn](https://twitter.com/xrfrn)
    - ハッシュタグ: [#xRfm](https://twitter.com/hashtag/xRfm?src=hash)
    """
    @State private var array: [String] = [
        "ikkou",
        "nkjzm",
        "",
        "",
        "",
    ]
    
    @State private var progress: String = "処理開始前"
    @State var date = Date()
    
    let gitRootPath: String = "/Users/nkjzm/Projects/xrfm.github.io/docs"
    let audioRootPath: String = "/Users/nkjzm/Projects/xrfm.github.io/docs/audio"
    let mdRootPath: String = "/Users/nkjzm/Projects/xrfm.github.io/docs/_posts"
    let artworkPath: String = "/Users/nkjzm/Dropbox/xrpodcast.png"
    
    // 一連の処理を実行する
    func execute() -> Void {
        Task {
            do {
                let audioFilename = GetAudioName(episodeNumber: episodeNumber)
                
                if(enableConvert) {
                    self.progress = "音声ファイルを変換しています"
                    try await self.convertToMp3(path: self.audioPath, filename: audioFilename)
                }
                
                // mdファイルを作成
                let mdFilename = try await self.makeMarkdown(audioFilename: audioFilename)
                
                // Gitリポジトリにアップロード
                self.progress = "アップロード中"
                try await self.uoloadToGitHub(audioFilename: audioFilename, mdFilename: mdFilename,count:episodeNumber)
                
                self.progress = "アップロード完了!"
                
            }catch {
                print("Error: \(error)")
            }
        }
    }
    
    // wavファイルを変換してアートワークを設定する
    func convertToMp3(path: String, filename: String) async throws -> Void {
        return try await withCheckedThrowingContinuation { continuation in
            
            let noiseProf: String = "\"\(gitRootPath)/noise.prof\""
            let noiseRemoved: String = "\"\(gitRootPath)/noise_removed.wav\""
            let silenceRemoved: String = "\"\(gitRootPath)/silence_removed.wav\""
            let formatConverted: String = "\"\(gitRootPath)/format_converted.mp3\""
            
            let task = Process()
            task.launchPath = "/bin/sh"
            
            let createNoiseprofArg = "/usr/local/bin/sox \"\(path)\" -n noiseprof \(noiseProf);"
            let removeNoiseArg = "/usr/local/bin/sox \"\(path)\" \(noiseRemoved) noisered \(noiseProf) 0.2;"
            //let compressArg = "/usr/local/bin/sox \(noiseRemoved) \(gitRootPath)/compressed.wav\" compand 0.01,1 -90,-90,-70,-70,-60,-20,0,0 -5;"
            let removeSilenceArg = "/usr/local/bin/sox \(noiseRemoved) \(silenceRemoved) silence -l 1 0.2 0% -1 0.8 0%;"
            let convertArg = "/usr/local/bin/ffmpeg -i \(silenceRemoved) -f mp3 -b:a 192k \(formatConverted) -y;"
            let addArtworkArg = "/usr/local/bin/ffmpeg -i \(formatConverted) -i \(artworkPath) -disposition:v:1 attached_pic -map 0 -map 1 -c copy -id3v2_version 3 -metadata:s:v title=\"Album cover\" -metadata:s:v comment=\"Cover (front)\" \(audioRootPath)/\(filename);"
            let removeFilesArg = "rm \(noiseProf) \(noiseRemoved) \(silenceRemoved) \(formatConverted);"
            task.arguments = ["-c", createNoiseprofArg + removeNoiseArg + removeSilenceArg + convertArg + addArtworkArg + removeFilesArg]
            task.terminationHandler = { _ in continuation.resume() }
            // コマンド実行
            task.launch()
        }
    }
    
    // ファイルサイズを取得する
    func getFileSize(filename: String) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            let task = Process()
            
            // 起動するプログラムを絶対パスで指定
            task.launchPath = "/usr/bin/wc"
            // オプションを指定
            task.arguments = ["-c", "\(audioRootPath)/\(filename)"]
            
            let outputPipe = Pipe()
            task.standardOutput = outputPipe
            
            task.terminationHandler = { _ in
                let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
                let output = String(data: outputData, encoding: .utf8)
                let arr: [String] = output!.components(separatedBy: " ")
                
                continuation.resume(returning: arr[1])
            }
            
            task.launch()
        }
    }
    
    // GitHubリポジトリにアップロード
    func uoloadToGitHub(audioFilename: String, mdFilename: String, count: Int) async throws -> Void {
        return try await withCheckedThrowingContinuation { continuation in
            
            let task = Process()
            // 起動するプログラムを絶対パスで指定
            task.launchPath = "/bin/sh"
            // オプションを指定
            task.arguments = ["-c", "cd \(gitRootPath); pwd; git add \(audioRootPath)/\(audioFilename); git add \(mdRootPath)/\(mdFilename); git commit -m \"Add \(count)\"; git push origin main"]
            task.terminationHandler = { _ in
                continuation.resume()
            }
            // コマンド実行
            task.launch()
        }
    }
    
    
    func getDateStr() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd" // 日付フォーマットの設定
        return dateFormatter.string(from: self.date)
    }
    
    func getMdFilename() -> String {
        let dateStr = getDateStr()
        return "\(dateStr)-\(episodeNumber).md"
    }
    
    func makeMarkdown(audioFilename: String) async throws -> String {
        // mdファイルの名前を取得
        let mdFilename = getMdFilename()
        // mdファイルを作成
        self.touch(filename: mdFilename)
        
        self.progress = "mdファイルを生成しています"
        
        // 音声ファイルのサイズ取得
        let fileSize = try await self.getFileSize(filename: audioFilename)
        self.setMarkdown(sizeStr: fileSize, audioFilename: audioFilename)
        
        return mdFilename;
    }
    
    // ファイルを作成
    func touch(filename: String) -> Void {
        let task = Process()
        // 起動するプログラムを絶対パスで指定
        task.launchPath = "/usr/bin/touch"
        // オプションを指定
        task.arguments = ["\(mdRootPath)/\(filename)"]
        // コマンド実行
        task.launch()
    }
    
    func setMarkdown(sizeStr: String, audioFilename: String)
    {
        // サイズをMB表記に変換
        let size = String(format: "%.01f", Float(sizeStr)! / 1000000)
        
        // 音声の長さを取得
        let asset = AVURLAsset(url: URL(fileURLWithPath: "\(self.audioRootPath)/\(audioFilename)"))
        let duration = Double(CMTimeGetSeconds(asset.duration))
        
        // 秒数を時間に整形
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.minute, .hour, .second]
        let outputString = formatter.string(from: duration)!
        
        var actors = ""
        
        for i in 0..<array.count {
            let name = array[i]
            if name != "" {
                actors += "\n- \(name)"
            }
        }
        
        let dateStr = getDateStr()
        let message = """
            ---
            actor_ids: \(actors)
            audio_file_path: /audio/\(audioFilename)
            audio_file_size: \(size) MB
            date: \(dateStr) 00:00:00 +0900
            description: "\(self.description)"
            duration: "\(outputString)"
            layout: article
            title: 第\(episodeNumber)回「\(self.title)」
            ---
            
            \(self.content)
            """
        
        self.progress = "mdファイルを書き込んでいます"
        
        // mdファイルに書き込み
        let mdFilename = getMdFilename()
        // 保存する場所
        let filePath = "\(mdRootPath)/\(mdFilename)"
        
        SaveTextFile(filePath: filePath, message: message)
    }

    
    var body: some View {
        VStack {
            VStack (spacing: 5) {
                Text("エピソードの情報を入力してください").frame(maxWidth: .infinity)
                HStack(alignment: .center) {
                    Text("ファイル") .frame(width: 100)
                    Text("\(self.audioPath)").frame(maxWidth: .infinity)
                    Button(action: {
                        self.audioPath = openAudio()
                    }) {
                        Text("オーディオファイルを開く")
                    }
                }
                HStack(alignment: .center) {
                    Text("回数") .frame(width: 100)
                    TextField("0", value: $episodeNumber, formatter: NumberFormatter())
                }
                DatePicker(selection: $date, in: ...Date(), displayedComponents: .date) {
                    Text("収録日") .frame(width: 100)
                }
                HStack(alignment: .center) {
                    Text("タイトル") .frame(width: 100)
                    Spacer()
                    TextField("エピソードのタイトルを入力", text: $title)
                }
                HStack(alignment: .center) {
                    Text("内容") .frame(width: 100)
                    Spacer()
                    TextField("エピソードの説明を入力", text: $description)
                }
                HStack(alignment: .center) {
                    Text("関連リンク").frame(width: 100, height: 100)
                    Spacer()
                    TextEditor(text: $content)
                }
            }
            VStack (spacing: 0) {
                ForEach(0..<array.count) { num in
                    HStack(alignment: .center) {
                        Text("ゲスト: \(num + 1)") .frame(width: 100)
                        Spacer()
                        TextField("nkjzm", text: $array[num])
                    }
                }
            }.padding(.leading)
            Toggle(isOn: $enableConvert) {
                Text("変換処理を有効にする")
            }.padding()
            Button(action: {
                self.execute()
            }) {
                Text("アップロード")
            }.padding()
            HStack(alignment: .center) {
                Text("進捗状況").frame(width: 100)
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
