//
//  ConnectionSettingView.swift
//  Madis
//
//  Created by Jack Lin on 2024/4/29.
//

import SwiftUI


struct ConnectionSettingView: View {
    
    @State private var selectedItem: Connection?
    
    var body: some View {
        NavigationSplitView {
            List(MockData.connectionItems, selection: $selectedItem) { conn in
                NavigationLink(conn.name, value: conn)
            }
            .listStyle(.sidebar)
        } detail: {
            if let item = selectedItem {
                ConnectionDetailView(connection: item)
            } else {
                Text("Please select a connection")
            }
        }
    }
}


struct ConnectionDetailView: View {
    
    var connection: Connection!
    @State private var host: String = ""
    
    var body: some View {
        
        CustomeTextField(title: "Name", prompt: "Name of your connection", text: $host)
        CustomeTextField(title: "Host", prompt: "Connection Host", text: $host)
        CustomeTextField(title: "Port", prompt: "Connection Port", text: $host)
        CustomeTextField(title: "Username", prompt: "User name", text: $host)
        CustomeTextField(title: "Password", prompt: "Password", text: $host)
        CustomeTextField(title: "Timeout", prompt: "Timeout", text: $host)

    }
}


struct CustomeTextField: View {
    
    let title: String
    let prompt: String?
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("\(title)")
                .font(.headline)
                .padding(.leading,8)
            
            TextField("\(prompt ?? "")", text: $text)
                .textFieldStyle(.plain)
                .padding(.vertical, 6)
                .padding(.horizontal,8)
                .background(Capsule().strokeBorder(.gray))
        }
        .padding(.horizontal, 8)
        
    }
}

#Preview {
    ConnectionSettingView()
        .frame(width: 640, height: 320)
}



struct Connection: Identifiable, Hashable{
    let id = UUID()
    let name: String
    let host: String
    let port: String
    let username: String
    let password: String
}
