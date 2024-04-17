//
//  DatabaseNavigationView.swift
//  Madis
//
//  Created by Jack Lin on 2024/4/17.
//

import SwiftUI

struct DatabaseNavigationViewRepresentable: NSViewControllerRepresentable {
    typealias NSViewControllerType = DatabaseNavigationController
    
    func makeNSViewController(context: Context) ->  DatabaseNavigationController {
        let controller = DatabaseNavigationController()
        return controller
    }
    
    func updateNSViewController(_ nsViewController: NSViewControllerType, context: Context) {
        
    }
    
}
