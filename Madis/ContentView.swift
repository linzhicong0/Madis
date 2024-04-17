//
//  ContentView.swift
//  Madis
//
//  Created by Jack Lin on 2024/4/3.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationSplitView {
            DatabaseNavigationViewRepresentable()
        } detail: {
            
        }

    }
}

#Preview {
    ContentView()
}
