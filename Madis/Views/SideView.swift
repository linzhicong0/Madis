//
//  SideView.swift
//  Madis
//
//  Created by Jack Lin on 2024/5/6.
//

import SwiftUI

struct SideView: View {
    @Bindable
    var appViewModel: AppViewModel
    
    @Namespace var animation
    
    var body: some View {
        VStack {
            Group {
                TabButton(image: "server.rack", title: "Connection", animation: animation, selected: $appViewModel.selectedTab)
                
                TabButton(image: "cylinder.split.1x2", title: "Database", animation: animation, selected: $appViewModel.selectedTab)
                
                TabButton(image: "gear", title: "Setting", animation: animation, selected: $appViewModel.selectedTab)
                
            }
            Spacer()
        }
        .padding(.top, 10)
        .frame(maxWidth: appViewModel.showTitleForTabBar ? (screen.width / 2) / 8 : 58, maxHeight: .infinity)
    }
}
//
//#Preview {
//    SideView()
//}
