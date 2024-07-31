//
//  HashTableValueEditor.swift
//  Madis
//
//  Created by Jack Lin on 2024/7/31.
//

import SwiftUI

struct HashTableValueEditor: View {
 @State var selection: Set<UUID> = []
    
    let items: HashElement
    
    struct ViewModel: Identifiable {
        let id: UUID = UUID()
        let index: Int
        let key: String
        let value: String
    }
    
    var body: some View {
        Table(viewModel, selection: $selection) {
            TableColumn("#", value: \.index.description)
                .width(50)
                .alignment(.center)
            TableColumn("Field", value: \.key)
                .alignment(.center)
            TableColumn("Value", value: \.value)
                .alignment(.center)
            TableColumn("Operations") { item in
                OperationColumn {
                    print("copy button clicked: \(item.value)")
                    let pasteboard = NSPasteboard.general
                    pasteboard.clearContents()
                    pasteboard.setString(item.value, forType: .string)
                    
                } modifyAction: {
                    print("modify button clicked: \(item.value)")
                } deleteAction: {
                    print(item)
                }
            }
            .width(100)
            .alignment(.center)
        }
    }
    
    var viewModel: [ViewModel] {
        items.enumerated().map { index, value in
            ViewModel(index: index, key: value.key, value: value.value)
          }
    }
}

#Preview {
    HashTableValueEditor(items: ["a":"1", "b": "2"])
}
