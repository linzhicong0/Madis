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
            
            ZStack {
                
                Color.white.background(BlurView())
                    .blendMode(.difference)
                
                TopBarView()
                    .padding(.vertical, 5)

            }
            .frame(height: 30)
            
            Divider()
            
            DatabaseView()
        }
        .ignoresSafeArea()
        
    }
}

#Preview {
    HomeView()
}

