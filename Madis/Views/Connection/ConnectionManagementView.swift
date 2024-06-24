//
//  ConnectionManagementView.swift
//  Madis
//
//  Created by Jack Lin on 2024/5/7.
//

import SwiftUI
import SwiftData

struct ConnectionManagementView: View {
    
    @Environment(\.appViewModel) private var appViewModel
    
    @State private var showDialog = false
    
    @Query private var connections: [ConnectionDetail]
    
    @State private var selectdConnection: ConnectionDetail?
    
    
    let columns = [
        GridItem(.adaptive(minimum: 195), spacing: 5),
    ]
    
    var body: some View {
        ScrollView() {
            LazyVGrid(columns: columns, alignment: .leading) {
                ForEach(connections) { conn in
                    ConnectionCardView(connectionDetail: conn)
                }
                PlusButton {
                    showDialog = true
                }
            }
            .padding()
        }
        .defaultScrollAnchor(UnitPoint.topLeading)
        .sheet(isPresented: $showDialog, content: {
            ConnectionConfigurationView(showDialog: $showDialog, connection: $selectdConnection)
        })

        
        
    }
}

//#Preview {
//    ConnectionManagementView()
//        .frame(width:800, height: 500)
//}


