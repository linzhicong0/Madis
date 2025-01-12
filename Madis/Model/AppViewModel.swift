//
//  AppViewModel.swift
//  Madis
//
//  Created by Jack Lin on 2024/5/6.
//

import Foundation


@Observable
class AppViewModel {
    
    var selectedTab: String = "Connection"
    
    var showTitleForTabBar: Bool = true
    
    var selectedConnectionDetail: ConnectionDetail?
    
    var selectedKey: String = ""

    var showFloatingMessage: Bool = false

    var floatingMessage: String = ""

    var floatingMessageType: FloatingMessageType = .success 
}
