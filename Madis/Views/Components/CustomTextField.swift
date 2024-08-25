//
//  CustomTextField.swift
//  Madis
//
//  Created by Jack Lin on 2024/8/13.
//

import SwiftUI

struct CustomTextField: View {
    
    let systemImage: String
    let placeholder: String?
    let verticalPadding: CGFloat = 4
    let horizontalPadding: CGFloat = 5
    
    @Binding var text: String
    
    var body: some View {
        
        HStack {
            Image(systemName: systemImage)
                .font(.system(size: 16))
                .foregroundStyle(.white)
            
            
            TextField("\(placeholder?.description ?? "")", text: $text)
                .textFieldStyle(.plain)
                .frame(height: 22)
                .font(.system(size: 16))
        }
        .padding(.vertical, verticalPadding)
        .padding(.horizontal, horizontalPadding)
        .background(.primary.opacity(0.15))
        .clipShape(.rect(cornerRadius: 10))
    }
    
    //        TextField(key, text: $text)
    //            .textFieldStyle(.plain)
    //            .font(.system(size: 16))
    //            .padding(.vertical, 4)
    //            .padding(.horizontal, 5)
    //            .background(.primary.opacity(0.15))
    //            .clipShape(.rect(cornerRadius: 10))
}

#Preview {
    CustomTextField(systemImage: "plus", placeholder: "placeholder", text: .constant("test"))
}
