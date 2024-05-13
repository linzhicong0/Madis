//
//  ConnectionCardView.swift
//  Madis
//
//  Created by Jack Lin on 2024/5/7.
//

import SwiftUI

struct ConnectionCardView: View {
    
    var connectionName: String
    var host: String
    var port: String
    var lastConnection: String
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 20) {
            
            Text("\(connectionName)")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color("CardTitleFontColor"))
            
            Text("\(host):\(port)")
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(Color("CardTextFontColor"))
            
            Text("\(lastConnection)")
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
                Button(action: {}, label: {
                    Image(systemName: "gear")
                        .contentShape(Rectangle())
                })
                .buttonStyle(PlainButtonStyle())
                
                // Delete Button
                Button(action: {}, label: {
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
    ConnectionCardView(connectionName: "My Local Connection", host: "127.0.0.1", port: "6379", lastConnection: "30 minutes ago")
        .frame(width: 200, height: 180)
}
