//
//  TopBarView.swift
//  Madis
//
//  Created by Jack Lin on 2024/4/22.
//

import SwiftUI

struct TopBarView: View {
    
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        
        HStack(alignment: .center) {
            Button(action: {
                
                print(colorScheme)
            }, label: {
                Text("Button")
            })
            .buttonStyle(PlainButtonStyle())
            
            Button(action: {}, label: {
                Text("Button1")
            })
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
        }
        .padding(.leading, 70)
        .frame(maxWidth: .infinity)
        .frame(height: 5)
        .offset(y: -16)
        
        
        
        
    }
}

#Preview {
    TopBarView()
}
