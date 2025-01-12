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
                if let config = appViewModel.selectedConnectionDetail {
                    if originalField != selectedField {
                        // Handle field change
                        RedisManager.shared.hashReplaceField(config: config, key: detail.key, previousField: originalField, field: selectedField, value: selectedValue) { success in
                            if success {
                                refresh?()
                                appViewModel.floatingMessage = "Field changed successfully"
                                appViewModel.floatingMessageType = .success
                            } else {
                                appViewModel.floatingMessage = "Failed to change field"
                                appViewModel.floatingMessageType = .error
                            }
                            withAnimation(.easeInOut(duration: 0.3)) {
                                appViewModel.showFloatingMessage = true
                            }   
                        }
                    } else {
                        // Handle value change
                        RedisManager.shared.hashSetFields(config: config, key: detail.key, fields: [selectedField: selectedValue]) { success in
                            if success {
                                refresh?()
                                appViewModel.floatingMessage = "Value updated successfully."
                                appViewModel.floatingMessageType = .success
                            } else {
                                appViewModel.floatingMessage = "Failed to update value."
                                appViewModel.floatingMessageType = .error
                            }
                            withAnimation(.easeInOut(duration: 0.3)) {
                                appViewModel.showFloatingMessage = true
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
                ViewModel(index: index, key: value.field, value: value.value)
            }
        }
        return []
    }
    
    private func deleteItem(field: String) {
        
        guard let config = appViewModel.selectedConnectionDetail else { return }
        
        RedisManager.shared.hashRemoveField(config: config, key: detail.key, field: field) { value in
            if (value < 0) {
                print("error")
            } else {
                refresh?()
                Utils.showDeleteItemSuccessMessage(appViewModel: appViewModel)
            }
        }
    }
}

#Preview {
    HashTableValueEditor(detail: .init(key: "key", ttl: "ttl", memory: "memory", type: .Hash, value: .Hash([HashElement(field: "a", value: "1"), HashElement(field: "b", value: "2")])))
}
