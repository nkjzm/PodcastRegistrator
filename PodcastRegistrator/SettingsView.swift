//
//  SettingsView.swift
//  PodcastRegistrator
//
//  Created by Nakaji Kohki on 2023/04/29.
//  Copyright © 2023 Nakaji Kohki. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    /// タブの列挙型
    private enum Tabs: Hashable {
        case general, advanced
    }
    
    var body: some View {
        TabView {
            // タブ1
            GeneralSettingsView()
                .tabItem {
                    Label("General", systemImage: "gear")
                }
                .tag(Tabs.general)
            
            // タブ2
            AdvancedSettingsView()
                .tabItem {
                    Label("Advanced", systemImage: "star")
                }
                .tag(Tabs.advanced)
        }
        .padding(20)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
