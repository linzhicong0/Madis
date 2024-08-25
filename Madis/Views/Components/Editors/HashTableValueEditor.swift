//
//  HashTableValueEditor.swift
//  Madis
//
//  Created by Jack Lin on 2024/7/31.
//

import SwiftUI

struct HashTableValueEditor: View {
    @State var selection: Set<UUID> = []
    
    @Environment(\.appViewModel) private var appViewModel
    //    let items: HashElement
    let detail: RedisItemDetailViewModel
    var refresh: (() -> Void)?

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
                    deleteItem(field: item.key)
                }
            }
            .width(100)
            .alignment(.center)
        }
    }
    
    var viewModel: [ViewModel] {
        if case let RedisValue.Hash(items) = detail.value {
            return items.enumerated().map { index, value in
                ViewModel(index: index, key: value.key, value: value.value)
            }
        }
        return []
    }
    
    private func deleteItem(field: String) {
        
        guard let clientName = appViewModel.selectedConnectionDetail?.name else { return }
        
        RedisManager.shared.hashRemoveField(clientName: clientName, key: detail.key, field: field) { value in
            if (value < 0) {
                print("error")
            } else {
                refresh?()
            }
        }
    }
}

#Preview {
    HashTableValueEditor(detail: .init(key: "key", ttl: "ttl", memory: "memory", type: .Hash, value: .Hash(["a": "1", "b": "2"])))
}
