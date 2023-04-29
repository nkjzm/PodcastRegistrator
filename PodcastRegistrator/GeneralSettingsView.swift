//
//  GeneralSettingsView.swift
//  PodcastRegistrator
//
//  Created by Nakaji Kohki on 2023/04/29.
//  Copyright © 2023 Nakaji Kohki. All rights reserved.
//

import SwiftUI

struct GeneralSettingsView: View {
    
    @AppStorage("gitRootPath") private var gitRootPath: String = "/Users/nkjzm/Projects/xrfm.github.io/docs"
    @AppStorage("audioRootPath") private var audioRootPath: String = "/Users/nkjzm/Projects/xrfm.github.io/docs/audio"
    @AppStorage("mdRootPath") private var mdRootPath: String = "/Users/nkjzm/Projects/xrfm.github.io/docs/_posts"
    @AppStorage("artworkPath") private var artworkPath: String = "/Users/nkjzm/Dropbox/xrpodcast.png"
    
    var body: some View {
        VStack (spacing: 10) {
            
            HStack(alignment: .center) {
                Text("Gitリポジトリ").frame(width: 150)
                Spacer()
                TextField("Gitリポジトリ", text: $gitRootPath)
            }
            HStack(alignment: .center) {
                Text("オーディオフォルダ").frame(width: 150)
                Spacer()
                TextField("オーディオフォルダ", text: $audioRootPath)
            }
            HStack(alignment: .center) {
                Text("Markdownフォルダ").frame(width: 150)
                TextField("Markdownフォルダ", text: $mdRootPath)
            }
            HStack(alignment: .center) {
                Text("ファイル").frame(width: 150)
                VStack{
                    if let image = loadImage(from: artworkPath) {
                        Image(nsImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                    } else {
                        Text("画像が見つかりません")
                    }
                    Button(action: {
                        self.artworkPath = OpenImage()
                    }) {
                        Text("アートワーク画像を選択")
                    }.frame(maxWidth: .infinity)
                }
            }
            
        }
    }
    
    // ファイルパスから画像をロードする関数
    func loadImage(from path: String) -> NSImage? {
        let url = URL(fileURLWithPath: path)
        guard let image = NSImage(contentsOf: url) else { return nil }
        return image
    }
}

struct GeneralSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        GeneralSettingsView()
    }
}
