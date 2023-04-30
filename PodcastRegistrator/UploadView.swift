import Foundation
import SwiftUI
import AVFoundation

struct UploadView: View {
    
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
    
    @State private var progressTexts: [String] = [
        "",
        "開始しました",
        "音声ファイルを変換しています",
        "mdファイルを生成しています",
        "アップロード中",
        "完了",
    ]
    
    struct progressStyle {
        var textColor : Color
        var imageColor : Color
        var fontWeight : Font.Weight
    }
    
    private let doneStyle = progressStyle(textColor: .primary, imageColor: .secondary, fontWeight: .regular)
    private let doingStyle = progressStyle(textColor: .primary, imageColor: .accentColor, fontWeight: .bold)
    private let todoStyle = progressStyle(textColor: Color(NSColor.tertiaryLabelColor), imageColor: Color(NSColor.tertiaryLabelColor), fontWeight: .regular)
    
    @State var date = Date()
    
    @State var progressIndex: Int = 0
    @State var progressValue: CGFloat = 0
    
    func updateProgress(index: Int) -> Void {
        progressIndex = index
        progressValue = CGFloat(index) / CGFloat(progressTexts.count - 1)
    }
    
    @State var createdFiles: [String] = []
    
    // 一連の処理を実行する
    func execute() -> Void {
        Task {
            do {
                updateProgress(index: 1)
                
                let audioFilename = GetAudioName(episodeNumber: episodeNumber)
                
                // 変換後のパスを代入する変数
                var outputAudioPath = audioPath
                
                if(enableConvert) {
                    updateProgress(index: 2)
                    let noiseProf = try await makeNoiseProf(audioPath: outputAudioPath)
                    outputAudioPath = try await removeNoise(audioPath: outputAudioPath, noiseProf: noiseProf)
                    outputAudioPath = try await removeSilence(audioPath: outputAudioPath)
                    outputAudioPath = try await addBgm(audioPath: outputAudioPath)
                    outputAudioPath = try await convertToMp3(audioPath: outputAudioPath)
                    try await rename(audioPath: outputAudioPath, outputFileName: audioFilename)
                    try await removeFiles()
                }
                
                // mdファイルを作成
                updateProgress(index: 3)
                let mdFilename = try await self.makeMarkdown(audioFilename: audioFilename)
                
                // Gitリポジトリにアップロード
                updateProgress(index: 4)
                // try await self.uoloadToGitHub(audioFilename: audioFilename, mdFilename: mdFilename,count:episodeNumber)
                
                updateProgress(index: 5)
            }catch {
                print("Error: \(error)")
            }
        }
    }
    
    // ノイズ除去の事前ファイル作成
    func makeNoiseProf(audioPath: String) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            let task = Process()
            task.launchPath = "/bin/sh"
            let noiseProf: String = "\"\(gitRootPath)/noise.prof\""
            let createNoiseprofArg = "/usr/local/bin/sox \"\(audioPath)\" -n noiseprof \(noiseProf);"
            task.arguments = ["-c", createNoiseprofArg]
            task.terminationHandler = { _ in
                self.createdFiles.append(noiseProf)
                continuation.resume(returning: noiseProf)
            }
            task.launch()
        }
    }
    
    // ノイズ除去
    func removeNoise(audioPath: String, noiseProf: String) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            let task = Process()
            task.launchPath = "/bin/sh"
            let noiseRemoved: String = "\"\(gitRootPath)/noise_removed.wav\""
            let removeNoiseArg = "/usr/local/bin/sox \"\(audioPath)\" \(noiseRemoved) noisered \(noiseProf) 0.2;"
            //let compressArg = "/usr/local/bin/sox \(noiseRemoved) \(gitRootPath)/compressed.wav\" compand 0.01,1 -90,-90,-70,-70,-60,-20,0,0 -5;"
            task.arguments = ["-c", removeNoiseArg]
            task.terminationHandler = { _ in
                self.createdFiles.append(noiseRemoved)
                continuation.resume(returning: noiseRemoved)
            }
            task.launch()
        }
    }
    
    // 無音区間の削除
    func removeSilence(audioPath: String) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            let task = Process()
            task.launchPath = "/bin/sh"
            let silenceRemoved: String = "\"\(gitRootPath)/silence_removed.wav\""
            let removeSilenceArg = "/usr/local/bin/sox \(audioPath) \(silenceRemoved) silence -l 1 0.2 0% -1 0.8 0%;"
            task.arguments = ["-c", removeSilenceArg]
            task.terminationHandler = { _ in
                self.createdFiles.append(silenceRemoved)
                continuation.resume(returning: silenceRemoved)
            }
            task.launch()
        }
    }
    
    // BGMを追加
    func addBgm(audioPath: String) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            let task = Process()
            task.launchPath = "/bin/sh"
            let bgmAdded: String = "\"\(gitRootPath)/bgm_added.wav\""
            // $ ffmpeg -i /Users/nkjzm/Downloads/origin.m4a -stream_loop -1  -i /Users/nkjzm/Downloads/bgm.mp3  -filter_complex "[0]adelay=1000[a0];adelay=2000[a1];[a0][a1]amix=inputs=2:duration=shortest:weights=1 0.5[a]" -map "[a]" out.mp3
            let bgmArg = "/usr/local/bin/ffmpeg -i \(audioPath) -stream_loop -1 -i \(bgmPath) -filter_complex \"[0][a0];[a1];[a0][a1]amix=inputs=2:duration=shortest:weights=1 0.5[a]\" -map \"[a]\" \(bgmAdded)"
            task.arguments = ["-c", bgmArg]
            task.terminationHandler = { _ in
                self.createdFiles.append(bgmAdded)
                continuation.resume(returning: bgmAdded)
            }
            task.launch()
        }
    }
    
    // mp3に変換
    func convertToMp3(audioPath: String) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            let task = Process()
            task.launchPath = "/bin/sh"
            let bgmAdded: String = "\"\(gitRootPath)/bgm_added.wav\""
            let convertArg = "/usr/local/bin/ffmpeg -i \(bgmAdded) -f mp3 -b:a 192k \(audioPath) -y;"
            task.arguments = ["-c", convertArg]
            task.terminationHandler = { _ in
                self.createdFiles.append(bgmAdded)
                continuation.resume(returning: bgmAdded)
            }
            task.launch()
        }
    }
    
    // アートワークを設定
    func addArtwork(audioPath: String) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            let task = Process()
            task.launchPath = "/bin/sh"
            let artworkAdded: String = "\"\(gitRootPath)/bgm_added.wav\""
            let addArtworkArg = "/usr/local/bin/ffmpeg -i \(audioPath) -i \(artworkPath) -disposition:v:1 attached_pic -map 0 -map 1 -c copy -id3v2_version 3 -metadata:s:v title=\"Album cover\" -metadata:s:v comment=\"Cover (front)\" \(artworkAdded);"
            task.arguments = ["-c", addArtworkArg]
            task.terminationHandler = { _ in
                self.createdFiles.append(artworkAdded)
                continuation.resume(returning: artworkAdded)
            }
            task.launch()
        }
    }
    
    // リネーム
    func rename(audioPath: String, outputFileName: String) async throws -> Void {
        return try await withCheckedThrowingContinuation { continuation in
            let task = Process()
            task.launchPath = "/bin/sh"
            let renamed: String = "\"\(gitRootPath)/\(outputFileName)\""
            let renameArg = "mv \(audioPath) \(renamed);"
            task.arguments = ["-c", renameArg]
            task.terminationHandler = { _ in
                // リネーム元のファイル名をリストから消す
                self.createdFiles.removeLast()
                continuation.resume()
            }
            task.launch()
        }
    }
    // 使い終わった不要なファイルを削除
    func removeFiles() async throws -> Void{
        return try await withCheckedThrowingContinuation { continuation in
            
            let task = Process()
            task.launchPath = "/bin/sh"
            
            var removeFilesArg = "rm"
            
            for file in  createdFiles {
                removeFilesArg.append(" \(file)")
            }
            
            task.arguments = ["-c", removeFilesArg]
            task.terminationHandler = { _ in continuation.resume() }
            task.launch()
        }
    }
    
    // ファイルサイズを取得する
    func getFileSize(filename: String) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            let task = Process()
            task.launchPath = "/usr/bin/wc"
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
        let asset = AVURLAsset(url: URL(fileURLWithPath: "\(audioRootPath)/\(audioFilename)"))
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
        
        // mdファイルに書き込み
        let mdFilename = getMdFilename()
        // 保存する場所
        let filePath = "\(mdRootPath)/\(mdFilename)"
        
        SaveTextFile(filePath: filePath, message: message)
    }
    
    
    var body: some View {
        HStack{
            VStack {
                VStack (spacing: 10) {
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
                        Text("内容") .frame(width: 100, height: 100)
                        Spacer()
                        TextEditor(text: $description)
                    }
                    HStack(alignment: .center) {
                        Text("関連リンク").frame(width: 100, height: 100)
                        Spacer()
                        TextEditor(text: $content)
                    }
                }
                VStack (spacing: 0) {
                    ForEach(0..<array.count, id: \.self) { num in
                        HStack(alignment: .center) {
                            Text("ゲスト: \(num + 1)") .frame(width: 100)
                            Spacer()
                            TextField("nkjzm", text: $array[num])
                        }
                    }
                }.padding(.leading)
            }.padding().frame(width: 400)
            VStack {
                Toggle("変換処理を有効にする", isOn: $enableConvert).padding().toggleStyle(.switch)
                Button("アップロード", action: {self.execute()} ).padding()
                HStack{
                    CircularProgressBar(progress: $progressValue)
                        .frame(width: 100, height: 100)
                        .padding(32.0)
                    VStack(alignment: .leading, spacing: 10) {
                        
                        ForEach(1..<progressTexts.count, id: \.self) { num in
                            let style = num < progressIndex ? doneStyle : ( num == progressIndex ? doingStyle : todoStyle)
                            Label(
                                title: { Text(progressTexts[num]).foregroundColor(style.textColor).fontWeight(style.fontWeight) },
                                icon: { Image(systemName: "circlebadge.fill").foregroundColor(style.imageColor)}
                            )
                        }
                        
                    }.padding().frame(maxWidth: .infinity)
                }
                Spacer()
            }.frame(width: 400)
        }
    }
}

struct TabAView_Previews: PreviewProvider {
    static var previews: some View {
        UploadView()
    }
}
