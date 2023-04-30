//
//  GeneralSettingsView.swift
//  PodcastRegistrator
//
//  Created by Nakaji Kohki on 2023/04/29.
//  Copyright © 2023 Nakaji Kohki. All rights reserved.
//

import SwiftUI

struct GeneralSettingsView: View {
    
    @AppStorage("repositoryRootPath") var gitRootPath: String = "/Users/nkjzm/Projects/xrfm.github.io"
    @AppStorage("artworkPath") var artworkPath: String = "/Users/nkjzm/Dropbox/xrpodcast.png"
    @AppStorage("bmgPath") var bmgPath: String = ""
    
    var body: some View {
        VStack (spacing: 10) {
            
            HStack(alignment: .center) {
                Text("Gitリポジトリ").frame(width: 150)
                Spacer()
                TextField("Gitリポジトリ", text: $gitRootPath)
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
                    HStack(alignment: .center) {
                        Text(self.artworkPath)
                        Button(action: {
                            self.artworkPath = openImage()
                        }) {
                            Text("アートワーク画像を選択")
                        }.frame(maxWidth: .infinity)
                    }
                }
            }
            HStack(alignment: .center) {
                Text("ファイル") .frame(width: 100)
                Text("\(self.bmgPath)").frame(maxWidth: .infinity)
                Button(action: {
                    self.bmgPath = openAudio()
                }) {
                    Text("オーディオファイルを選択")
                }
            }
            
        }
    }
}

struct GeneralSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        GeneralSettingsView()
    }
}
