import Foundation
import SwiftUI

/// オーディオ名を取得
func GetAudioName(episodeNumber: Int) -> String {
    return "xrfm_\(String(format: "%03d", episodeNumber)).mp3"
}

/// Rawオーディオ名を取得
func GetRawAudioName(episodeNumber: Int) -> String {
    return "xrfm_\(String(format: "%03d", episodeNumber))_raw.mp3"
}

/// 動画名を取得
func GetMovieName(episodeNumber: Int) -> String {
    return "xrfm_\(String(format: "%03d", episodeNumber)).mp4"
}

/// ファイルを保存する
func SaveTextFile(filePath: String, message: String, callback: @escaping () -> Void) -> Void {
    // 保存処理
    do {
        try message.write(toFile: filePath, atomically: true, encoding: String.Encoding.utf8)
        callback();
    } catch { }
}

/// 画像を開く
func OpenImage() -> String {
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
