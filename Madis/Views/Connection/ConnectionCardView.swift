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
        .frame(width: 200, height: 180)
        .background(Color("ConnectionCardBackground"))
        
    }
}

#Preview {
    ConnectionCardView(connectionName: "My Local Connection", host: "127.0.0.1", port: "6379", lastConnection: "30 minutes ago")
        .frame(width: 200, height: 180)
}
