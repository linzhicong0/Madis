//
//  MadisApp.swift
//  Madis
//
//  Created by Jack Lin on 2024/4/3.
//

import SwiftUI

@main
struct MadisApp: App {
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some Scene {
        
        WindowGroup {
            HomeView()
                .preferredColorScheme(.light)
//                .toolbar(content: {
//                    TopBarView()
//                })
//                .toolbarTitleDisplayMode(.inline)
////                .presentedWindowToolbarStyle(.expanded)
//                .toolbarBackground(colorScheme == .dark ? .white.opacity(0.5) : .black.opacity(0.2), for: .windowToolbar)
            
        }
        .windowStyle(.hiddenTitleBar)
    }
}
