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
