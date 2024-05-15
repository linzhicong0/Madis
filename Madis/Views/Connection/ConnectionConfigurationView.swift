//
//  ConnectionConfigurationView.swift
//  Madis
//
//  Created by Jack Lin on 2024/5/9.
//

import SwiftUI

struct ConnectionConfigurationView: View {
    
    @Environment(\.appViewModel) private var appViewModel
    
    @Binding var showDialog: Bool
    @State private var connectionName: String = ""
    @State private var connectionHost: String = "127.0.0.1"
    @State private var connectionPort: String = "6379"
    @State private var username: String = ""
    @State private var password: String = ""
    
    @State private var closeButtonHovering = false
    
    var body: some View {
        
        ZStack(alignment: .topLeading) {
            VStack(spacing: 20) {
                
                Text("New Connection")
                    .font(.title)
                
                // Connection Name
                CustomFormInputView(title: "Connection Name", systemImage: "list.bullet.circle", placeholder: "connection name", text: $connectionName)
                
                // Connection host and port
                HStack() {
                    CustomFormInputView(title: "Host", systemImage: "house.circle",placeholder: "host" , text: $connectionHost)
                    Text(":")
                        .font(.title)
                        .offset(y: 10)
                    CustomFormInputView(title: "Port", systemImage: "door.left.hand.closed", placeholder: "port", text: $connectionPort)
                }
                HStack {
                    CustomFormInputView(title: "Username", systemImage: "person.crop.circle", placeholder: "username", text: $username)
                    CustomFormInputView(title: "Password", systemImage: "key.horizontal.fill", isSecured: true, placeholder: "password", text: $password)
                }
                
                Spacer()
                
                HStack {
                    Spacer()
                    Button(action: {}, label: {
                        Text("Test Connection")
                            .padding(5)
                            .foregroundStyle(.white)
                            .buttonStyle(.borderedProminent)
                    })
                    
                    Button(action: {
                        showDialog = false
                    }, label: {
                        Text("Cancel")
                            .padding(5)
                            .foregroundStyle(.white)
                        
                    })
                    .buttonStyle(.borderedProminent)
                    
                    Button( action: {
                        
                        let newConnection = Connection(name: self.connectionName, host: self.connectionHost, port: self.connectionPort, username: self.username, password: self.password)
                        
                        appViewModel.connections.append(newConnection)
                        
                        close()
                        
                    }, label: {
                        Text("Create")
                            .padding(5)
                            .foregroundStyle(.white)
                    })
                    .buttonStyle(.borderedProminent)
                }
                
                
            }
            .padding(15)
            .frame(width: 400, height:400)
            .background(BlurView())
            
            // close button
            Button(action: {
                close()
            }, label: {
                ZStack {
                    Circle()
                        .foregroundStyle(.red)
                        .frame(width:14, height: 14)
                    
                    if(closeButtonHovering) {
                        Image(systemName: "xmark")
                            .font(.system(size: 8))
                            .bold()
                            .foregroundStyle(.black)
                    }
                }
            })
            .offset(x: 10, y: 10)
            .buttonStyle(PlainButtonStyle())
            .onHover(perform: { hovering in
                closeButtonHovering = hovering
            })
        }
    }
    
    private func close() {
        showDialog = false
    }
}

#Preview {
    ConnectionConfigurationView(showDialog: .constant(true))
}

struct CustomFormInputView: View {
    
    var title: String
    var systemImage: String
    var isSecured: Bool = false
    var horizontalPadding: CGFloat = 4
    var verticalPadding: CGFloat = 5
    var placeholder: String?
    
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("\(title)")
                .font(.system(size: 14))
                .foregroundStyle(.white)
                .offset(x: 4)
            HStack {
                Image(systemName: systemImage)
                    .font(.system(size: 16))
                    .foregroundStyle(.white)
                
                if isSecured {
                    SecureField("\(placeholder?.description ?? "")", text: $text)
                        .textFieldStyle(.plain)
                        .font(.system(size: 16))
                }
                else {
                    TextField("\(placeholder?.description ?? "")", text: $text)
                        .textFieldStyle(.plain)
                        .font(.system(size: 16))
                }
            }
            .padding(.vertical, verticalPadding)
            .padding(.horizontal, horizontalPadding)
            .background(.primary.opacity(0.15))
            .clipShape(.rect(cornerRadius: 10))
            
            
        }
    }
    
}
