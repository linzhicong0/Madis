//
//  MainView.swift
//  Madis
//
//  Created by Jack Lin on 2024/5/6.
//

import SwiftUI


var screen = NSScreen.main!.visibleFrame


struct MainView: View {
    
    @Environment(\.appViewModel) private var appViewModel
    
    @Namespace var animation
    var body: some View {
        VStack(spacing:2) {
            
            TopBarView()
                .padding(.vertical, 5)
            
            Divider()
            
            HStack {
                
                SideView(appViewModel: appViewModel)
                Divider()
                
                ZStack {
                    switch appViewModel.selectedTab{
                    case "Connection":
                        ConnectionManagementView()
                    case "Database":
                        DatabaseView()
                    case "Setting":
                        SettingView()
                    default:
                        ConnectionManagementView()
                    }
                    
                    
                }
                .frame(maxWidth: .infinity)
                
            }
        }
        .background(BlurView())
        .ignoresSafeArea(.all, edges: .all)
    }
}

#Preview {
    MainView()
}
