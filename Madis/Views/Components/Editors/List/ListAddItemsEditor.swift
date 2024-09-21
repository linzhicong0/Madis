//
//  ListItemsEditor.swift
//  Madis
//
//  Created by Jack Lin on 2024/9/19.
//

import SwiftUI

struct ListAddItemsEditor: View {
    @Binding var items: RedisValue
    @State private var values:[String] = [""]

    var body: some View {
        ScrollViewReader { scrollProxy in
            ScrollView {
                ForEach(0..<values.count, id: \.self) { index in
                    ItemView(value: $values[index]){
                        if (values.count > 1) {
                            values.remove(at: index)
                        }
                    }
                    .padding(.trailing, 5)
                    }
                    .onChange(of: values.count) { oldValue, newValue in
                        scrollProxy.scrollTo("PlusButton", anchor: .bottom)
                    }
                    Button(action: {
                        values.append("")
                    }, label: {
                                Image(systemName: "plus")
                            })
                            .id("PlusButton")
            }
        }
        .onChange(of: values) { oldValue, newValue in
            updateItems()
        }   
    }
    private func updateItems () {
        items = .List(values)
    }
}

//#Preview {
//    ListItemsEditor()
//}
