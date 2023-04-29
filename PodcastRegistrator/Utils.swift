import Foundation
import SwiftUI

var repositoryRootPath: String { UserDefaults.standard.string(forKey: "repositoryRootPath")! }
var artworkPath: String { UserDefaults.standard.string(forKey: "artworkPath")! }

var gitRootPath: String { "\(repositoryRootPath)/docs" }

var configPath: String { "\(gitRootPath)/_config.yml" }
var audioRootPath: String { "\(gitRootPath)/audio" }
var mdRootPath: String { "\(gitRootPath)/_posts"}
var movieThubnailPath: String { "\(gitRootPath)/images/thumbnail.png" }
var actorImageRootPath: String { "\(gitRootPath)/movie/actors" }

var rawAudioRootPath: String { "\(repositoryRootPath)/raw-audio" }
var movieRootPath: String { "\(repositoryRootPath)/movie" }

/// オーディオ名を取得
func GetAudioName(episodeNumber: Int) -> String {
    return String(format: "xrfm_%03d.mp3", episodeNumber)
}

/// Rawオーディオ名を取得
func GetRawAudioName(episodeNumber: Int) -> String {
    return String(format: "xrfm_%03d_raw.mp3", episodeNumber)
}

/// 動画名を取得
func GetMovieName(episodeNumber: Int) -> String {
    return String(format: "xrfm_%03d.mp4", episodeNumber)
}

/// ファイルを読み込む
func LoadTextFile(filePath: String) -> String {
    let fileURL = URL(fileURLWithPath: filePath)
    // 保存処理
    do {
        return try String(contentsOf: fileURL, encoding: .utf8)
    } catch { }
    return ""
}

/// ファイルを保存する
func SaveTextFile(filePath: String, message: String) -> Void {
    // 保存処理
    do {
        try message.write(toFile: filePath, atomically: true, encoding: String.Encoding.utf8)
    } catch { }
}

// ファイルパスから画像をロードする関数
func loadImage(from path: String) -> NSImage? {
    let url = URL(fileURLWithPath: path)
    guard let image = NSImage(contentsOf: url) else { return nil }
    return image
}

/// 画像を開く
func openImage() -> String {
    let openPanel = NSOpenPanel()
    openPanel.allowsMultipleSelection = false //複数ファイルの選択
    openPanel.canChooseDirectories = false //ディレクトリの選択
    openPanel.canCreateDirectories = false //ディレクトリの作成
    openPanel.canChooseFiles = true //ファイルの選択
    openPanel.allowedFileTypes = ["jpg", "png"] //ファイルの種類
    
    let reault = openPanel.runModal()
    if(reault == NSApplication.ModalResponse.OK) {
        if let panelURL = openPanel.url {
            let path: String = panelURL.path
            print(path)
            return path
        }
    }
    return ""
}

// オーディオファイルを開く
func openAudio() -> String {
    let openPanel = NSOpenPanel()
    openPanel.allowsMultipleSelection = false //複数ファイルの選択
    openPanel.canChooseDirectories = false //ディレクトリの選択
    openPanel.canCreateDirectories = false //ディレクトリの作成
    openPanel.canChooseFiles = true //ファイルの選択
    openPanel.allowedFileTypes = ["wav", "mp3"] //ファイルの種類
    
    let reault = openPanel.runModal()
    if(reault == NSApplication.ModalResponse.OK) {
        if let panelURL = openPanel.url {
            
            let path: String = panelURL.path
            print(path)
            return path
        }
    }
    return ""
}

