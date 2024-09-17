//
//  RedisItemView.swift
//  Madis
//
//  Created by Jack Lin on 2024/4/23.
//

import SwiftUI

struct RedisItemView: View {
    
    let item: RedisOutlineItem
    let selected: Bool
    let deleteKey: (RedisOutlineItem) -> Void
    
    @State private var deleteButtonColor: Color = .gray
    var body: some View {
        HStack(spacing: 8) {
            Text(item.type.stringValue)
                .font(.caption)
                .padding(.vertical, 3)
                .frame(width: 50)
                .foregroundStyle(.white)
                .background(item.type.colorValue)
                .clipShape(.rect(cornerRadius: 3))
            Text("\(item.label)")
                .font(.system(size: 13))
            Spacer()

        Button(action: {
            deleteKey(item)
        }) {
            Image(systemName: "trash")
                .font(.system(size: 12))
        }
        .buttonStyle(PlainButtonStyle())
        .foregroundColor($deleteButtonColor.wrappedValue)
        .opacity(selected ? 1 : 0) // Only show when item is selected
        .onHover { hovering in
            if hovering {
                withAnimation(.easeInOut(duration: 0.2)) {
                    deleteButtonColor = .red
                }
            } else {
                withAnimation(.easeInOut(duration: 0.2)) {
                    deleteButtonColor = .gray
                }
            }
        }
        }
        .padding(4)
        .background(selected ? .gray.opacity(0.3) : .clear)
        .contentShape(Rectangle())
        .clipShape(.rect(cornerRadius: 5))
    }
}

#Preview {
    RedisItemView(item: RedisOutlineItem(key: "sample",label: "sample", type: .String, children: nil), selected: true, deleteKey: { key in
        print("Delete button tapped for key: \(key)")
    })
        .frame(width: 300, height: 100)
}

