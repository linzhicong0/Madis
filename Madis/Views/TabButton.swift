//
//  TabButton.swift
//  Madis
//
//  Created by Jack Lin on 2024/5/6.
//

import SwiftUI

struct TabButton: View {
    var image: String
    var title: String
    
    var animation: Namespace.ID
    
    @Binding var selected: String
    
    var body: some View {
        
        Button(action: {
            withAnimation() {
                selected = title
            }
        }, label: {
            
            HStack(spacing: 10) {
                
                ZStack{
                    Capsule()
                        .fill(.clear)
                    // we need to make it the source according to the selected
                    // otherwise will have undefined behaviour
                        .matchedGeometryEffect(id: "Tab", in: animation, isSource: selected == title)
                    
                    if selected == title {
                        Capsule()
                            .fill(.orange)
                            .matchedGeometryEffect(id: "Tab", in: animation)
                    }
                }
                .frame(width: 3, height: 25)
                
                
                Image(systemName: image)
                    .font(.system(size: 24))
                    .foregroundStyle(selected == title ? .orange : .gray)
                    .frame(width: 30)
                
                Text(title)
                    .fontWeight(.semibold)
                    .foregroundStyle(.gray)
                
                Spacer()
                
                
            }
            .padding(.vertical, 5)
            .contentShape(Rectangle())
        })
        .buttonStyle(PlainButtonStyle())
    }
}

//#Preview {
//    TabButton(image: "storefront.fill", title: "Connection", selected: .constant("Connection"))
//}
