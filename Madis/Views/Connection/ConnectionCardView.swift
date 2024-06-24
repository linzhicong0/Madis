//
//  ConnectionCardView.swift
//  Madis
//
//  Created by Jack Lin on 2024/5/7.
//

import SwiftUI

struct ConnectionCardView: View {
    
    @Environment(\.modelContext) private var context
    
    @State private var showDialog: Bool = false
    
    @State var connectionDetail: ConnectionDetail
    
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 20) {
            
            Text("\(connectionDetail.name)")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color("CardTitleFontColor"))
            
            Text("\(connectionDetail.host):\(connectionDetail.port)")
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(Color("CardTextFontColor"))
            
            Text("TODO")
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(Color("CardTextFontColor"))
            
            Spacer()
            
            HStack {
                Spacer()
                // Open Connection Button
                Button(action: {}, label: {
                    Image(systemName: "play.fill")
                        .contentShape(Rectangle())
                })
                .buttonStyle(PlainButtonStyle())
                // Setting Button
                Button(action: {
                    showDialog = true
                }, label: {
                    Image(systemName: "gear")
                        .contentShape(Rectangle())
                })
                .buttonStyle(PlainButtonStyle())
                
                // Delete Button
                Button(action: {
                    delete()
                }, label: {
                    Image(systemName: "trash")
                        .contentShape(Rectangle())
                })
                .buttonStyle(PlainButtonStyle())
            }
            
        }
        .padding()
        .frame(width: 200, height: 180)
        .background(Color("ConnectionCardBackground"))
        .clipShape(.rect(cornerRadius: 12))
        .sheet(isPresented: $showDialog, content: {
            ConnectionConfigurationView(showDialog: $showDialog, connection: connectionDetail, isUpdate: true)
        })
        
    }
    
    private func delete() {
        context.delete(connectionDetail)
        print("deleted: \(connectionDetail.name)")
        
    }
}

struct PlusButton: View {
    let action:  () -> Void
    
    
    init(action: @escaping () -> Void ) {
        self.action = action
    }
    
    var body: some View {
        
        Button(action: {
            action()
        }, label: {
            ZStack {
                Color("ConnectionCardBackground")
                Image(systemName: "plus")
                    .resizable()
                    .padding()
                    .frame(width: 70, height: 70)
            }
            .frame(width: 200, height: 180)
            .clipShape(.rect(cornerRadius: 12))

        })
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview{
    PlusButton(action: {})
    
}

#Preview {
    ConnectionCardView( connectionDetail:  ConnectionDetail(name: "test", host: "127.0.0.1", port: "6379", username: "test", password: "1234"))
        .frame(width: 200, height: 180)
}
