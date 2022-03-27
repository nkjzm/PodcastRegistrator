//
//  Utils.swift
//  PodcastRegistrator
//
//  Created by Nakaji Kohki on 2022/03/05.
//  Copyright © 2022 Nakaji Kohki. All rights reserved.
//

import Foundation

func GetAudioName(episodeNumber : Int) -> String {
    return "xrfm_\(String(format: "%03d", episodeNumber)).mp3"
}

func GetRawAudioName(episodeNumber : Int) -> String {
    return "xrfm_\(String(format: "%03d", episodeNumber))_raw.mp3"
}

func GetMovieName(episodeNumber : Int) -> String {
    return "xrfm_\(String(format: "%03d", episodeNumber)).mp4"
}

func SaveFile(filePath : String, message : String, callback: @escaping () -> Void) -> Void {
    // 保存処理
    do {
        try message.write(toFile: filePath, atomically: true, encoding: String.Encoding.utf8)
        callback();
    } catch { }
}

