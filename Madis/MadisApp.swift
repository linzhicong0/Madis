//
//  MadisApp.swift
//  Madis
//
//  Created by Jack Lin on 2024/4/3.
//

import SwiftUI
import RediStack

@main
struct MadisApp: App {
    
    @Environment(\.colorScheme) var colorScheme
    
    @State private var appViewModel = AppViewModel()

    var body: some Scene {
        
        WindowGroup {
            
            MainView()
                .environment(\.appViewModel, appViewModel)

        }
        .windowStyle(.hiddenTitleBar)
    }
}

extension EnvironmentValues {
    var appViewModel: AppViewModel {
        get { self[AppViewModelKey.self]}
        set { self[AppViewModelKey.self] = newValue}
        
    }
    
}
private struct AppViewModelKey: EnvironmentKey {
    static var defaultValue: AppViewModel = AppViewModel()
}
