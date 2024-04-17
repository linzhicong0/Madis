//
//  DatabaseRowView.swift
//  Madis
//
//  Created by Jack Lin on 2024/4/17.
//

import SwiftUI

struct DatabaseRowView: View {
    
    var name: String!
     
    var body: some View {
        
        HStack {
            Text(name)
                .font(.headline)
            Spacer()
        }
        .padding(.leading, 5)
            
    }
}

#Preview {
    DatabaseRowView(name: "hello")
        .frame(width: 200, height: 200)
}
