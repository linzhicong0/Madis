//
//  HomeView.swift
//  Madis
//
//  Created by Jack Lin on 2024/4/22.
//

import SwiftUI


//let screen = NSScreen.main!.frame

struct HomeView: View {
    
    @Environment(\.colorScheme) var colorScheme;
    
    var body: some View {
        VStack(spacing: 0) {
            
            TopBarView()
                .background(colorScheme == .dark ? .black.opacity(0.2) : .white.opacity(0.2))
            
            DatabaseView()
        }
        
    }
}

#Preview {
    HomeView()
}

