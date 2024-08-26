//
//  CustomTextField.swift
//  Madis
//
//  Created by Jack Lin on 2024/8/13.
//

import SwiftUI

struct CustomTextField: View {
    
    var systemImage: String?
    let placeholder: String?
    let verticalPadding: CGFloat = 4
    let horizontalPadding: CGFloat = 5
    
    @Binding var text: String
    
    var body: some View {
        
        HStack {
            if let systemImage = systemImage {
                Image(systemName: systemImage)
                    .font(.system(size: 16))
                    .foregroundStyle(.white)
            }
            
            
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
}

#Preview {
    CustomTextField(systemImage: "plus", placeholder: "placeholder", text: .constant("test"))
}
