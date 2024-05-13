//
//  ConnectionManagementView.swift
//  Madis
//
//  Created by Jack Lin on 2024/5/7.
//

import SwiftUI

struct ConnectionManagementView: View {
    
    @Environment(\.appViewModel) private var appViewModel
    
    @State private var showDialog = false
    
    
    let columns = [
        GridItem(.adaptive(minimum: 195), spacing: 5),
    ]
    
    var body: some View {
        ScrollView() {
            LazyVGrid(columns: columns, alignment: .leading) {
                ForEach(appViewModel.connections) { conn in
                    ConnectionCardView(connectionName: conn.name, host: conn.host, port: conn.port, lastConnection: conn.username)
                }
                PlusButton {
                    showDialog = true
                }
            }
            .padding()
        }
        .defaultScrollAnchor(UnitPoint.topLeading)
        .sheet(isPresented: $showDialog, content: {
            ConnectionConfigurationView(showDialog: $showDialog)
        })

        
        
    }
}

//#Preview {
//    ConnectionManagementView()
//        .frame(width:800, height: 500)
//}


