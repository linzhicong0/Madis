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
    
    var body: some View {
        HStack(spacing: 3) {
            Text(item.type.stringValue)
                .font(.caption)
                .padding(.vertical, 3)
                .frame(width: 50)
                .foregroundStyle(.white)
                .background(item.type.colorValue)
                .clipShape(.rect(cornerRadius: 3))
            Text("\(item.name):\(item.value)")
            Spacer()
        }
        .padding(4)
        .padding(.leading, 5)
        .background(selected ? .gray.opacity(0.3) : .clear)
        .contentShape(Rectangle())
        .clipShape(.rect(cornerRadius: 5))
    }
}

#Preview {
    RedisItemView(item: RedisOutlineItem(name: "sample", value: "string", type: .String, children: nil), selected: true)
        .frame(width: 300, height: 100)
}

