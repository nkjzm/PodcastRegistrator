//
//  GeneralSettingsView.swift
//  PodcastRegistrator
//
//  Created by Nakaji Kohki on 2023/04/29.
//  Copyright © 2023 Nakaji Kohki. All rights reserved.
//

import SwiftUI

struct GeneralSettingsView: View {
    
    @AppStorage("title") private var title: String = ""

    var body: some View {
        Form {
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            TextField("エピソードのタイトルを入力", text: $title)
        }
    }
}

struct GeneralSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        GeneralSettingsView()
    }
}
