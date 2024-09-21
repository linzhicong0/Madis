//
//  ZSetItemsEditor.swift
//  Madis
//
//  Created by Jack Lin on 2024/9/19.
//

import SwiftUI

struct ZSetAddItemsEditor: View {
    @Binding var items: RedisValue
    @State private var values: [ZSetItem] = [ZSetItem("", 0.0)]
    
    var body: some View {
        ScrollViewReader { scrollProxy in
            ScrollView {
                ForEach(0..<values.count, id: \.self) { index in
                    ZSetItemView(element: $values[index], onDelete: {
                        if (values.count > 1) {
                            values.remove(at: index)
                        }
                    })
                    .padding(.trailing, 5)
                }
                .onChange(of: values.count) { oldValue, newValue in
                    scrollProxy.scrollTo("PlusButton", anchor: .bottom)
                }
                Button(action: {
                    values.append(ZSetItem("", 0.0))
                }, label: {
                    Image(systemName: "plus")
                })
                .id("PlusButton")
            }
        }
        .onChange(of: values) { _, _ in
            updateItems()
        }
    }
    
    
    private func updateItems() {
        items = .ZSet(values)
    }
}
