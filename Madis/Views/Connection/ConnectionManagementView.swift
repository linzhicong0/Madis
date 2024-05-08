//
//  ConnectionManagementView.swift
//  Madis
//
//  Created by Jack Lin on 2024/5/7.
//

import SwiftUI

struct ConnectionManagementView: View {
    
    @Environment(\.appViewModel) private var appViewModel
    
    let columns = [
        GridItem(.adaptive(minimum: 195), spacing: 10)
    ]
    
    var body: some View {
        ScrollView() {
            LazyVGrid(columns: columns, alignment: .leading) {
                ForEach(appViewModel.connections) { conn in
                    ConnectionCardView(connectionName: conn.name, host: conn.host, port: conn.port, lastConnection: conn.username)
                }
                PlusButton()
            }
            .padding()
        }
    }
}

#Preview {
    ConnectionManagementView()
        .frame(width:800, height: 500)
}
