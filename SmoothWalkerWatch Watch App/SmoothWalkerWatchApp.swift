//
//  SmoothWalkerWatchApp.swift
//  SmoothWalkerWatch Watch App
//
//  Created by Ruotsing on 2024/6/21.
//  Copyright © 2024 Apple. All rights reserved.
//

import SwiftUI

@main
struct SmoothWalkerWatch_Watch_App: App {
    var body: some Scene {
            WindowGroup {
                TabView {
                    HeartRateView()
                        .tabItem {
                            Label("心率", systemImage: "heart.fill")
                        }
                }
            }
        }
}



