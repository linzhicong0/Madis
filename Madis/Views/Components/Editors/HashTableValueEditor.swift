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
    
    @State var openEditDialog: Bool = false
    @State var selectedValue: String = ""
    @State var selectedField: String = ""
    
    @State private var originalField: String = ""
    
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
                    selectedValue = item.value
                    selectedField = item.key
                    originalField = item.key
                    openEditDialog = true
                } deleteAction: {
                    deleteItem(field: item.key)
                }
            }
            .width(100)
            .alignment(.center)
        }
        .sheet(isPresented: $openEditDialog) {
            HashModifyItemDialog(field: $selectedField, value: $selectedValue) {
                if let clientName = appViewModel.selectedConnectionDetail?.name {
                    if originalField != selectedField {
                        // Handle field change
                        RedisManager.shared.hashReplaceField(clientName: clientName, key: detail.key, previousField: originalField, field: selectedField, value: selectedValue) { success in
                            if success {
                                print("Field changed successfully")
                                refresh?()
                            } else {
                                print("Failed to change field")
                            }
                        }
                    } else {
                        // Handle value change
                        RedisManager.shared.hashSetFields(clientName: clientName, key: detail.key, fields: [selectedField: selectedValue]) { success in
                            if success {
                                print("Value updated successfully")
                                refresh?()
                            } else {
                                print("Failed to update value")
                            }
                        }
                    }
                }
            }
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
