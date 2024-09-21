//
//  HashAddItemsEditor.swift
//  Madis
//
//  Created by Jack Lin on 2024/9/20.
//

import SwiftUI

struct HashAddItemsEditor: View {
    @Binding var items: RedisValue
    @State private var values: [HashElement] = [.init(field: "", value: "")]
    
    var body: some View {
        ScrollViewReader { scrollProxy in
            ScrollView {
                ForEach(0..<values.count, id: \.self) { index in
                    HashItemView(field: $values[index].field, value:$values[index].value, onDelete: {
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
                    values.append(HashElement(field: "", value: ""))
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
       items = .Hash(values)
   }
}

