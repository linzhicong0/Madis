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
                TabButton(image: "rectangle.3.group", title: "connection", animation: animation, selected: $appViewModel.selectedTab)
                
                TabButton(image: "rectangle.3.group", title: "database", animation: animation, selected: $appViewModel.selectedTab)
                
                TabButton(image: "rectangle.3.group", title: "setting", animation: animation, selected: $appViewModel.selectedTab)
                
//                TabButton(image: "rectangle.3.group", title: "connection3", animation: animation, selected: $appViewModel.selectedTab)
            }
            Spacer()
        }
        .frame(maxWidth: (screen.width / 2) / 4 , maxHeight: .infinity)
    }
}
//
//#Preview {
//    SideView()
//}
