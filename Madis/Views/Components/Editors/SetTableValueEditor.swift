//
//  SetTableValueEditor.swift
//  Madis
//
//  Created by Jack Lin on 2024/7/31.
//

import SwiftUI

struct SetTableValueEditor: View {
    
    @Environment(\.appViewModel) private var appViewModel
    @State var selection: Set<UUID> = []
    @State private var openEditDialog = false
    @State private var selectedIndex = -1
    @State private var updatedValue = ""
    @State private var originalValue = ""
    
    var detail: RedisItemDetailViewModel
    var refresh: (() -> Void)?
    
    struct ViewModel: Identifiable {
        let id: UUID = UUID()
        let index: Int
        let value: String
    }
    
    var body: some View {
        Table(viewModel, selection: $selection) {
            TableColumn("#", value: \.index.description)
                .width(50)
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
                    selectedIndex = item.index
                    originalValue = item.value
                    updatedValue = item.value
                    openEditDialog.toggle()
                } deleteAction: {
                    print(item.value)
                    deleteItem(item: item.value)
                }
            }
            .width(100)
            .alignment(.center)
        }
        .sheet(isPresented: $openEditDialog, content: {
            SetModifyItemDialog(value: $updatedValue) {
                guard let config = appViewModel.selectedConnectionDetail else { return }
                RedisManager.shared.setModifyItem(config: config, key: detail.key, item: originalValue, newItem: updatedValue) {
                    refresh?()
                    appViewModel.floatingMessage = "Value updated successfully."
                    appViewModel.floatingMessageType = .success
                    withAnimation(.easeInOut(duration: 0.3)) {
                        appViewModel.showFloatingMessage = true
                    }
                }
            }
        })
    }
    
    var viewModel: [ViewModel] {
        if case let RedisValue.Set(items) = detail.value {
            return items.enumerated().map { index, value in
                ViewModel(index: index, value: value)
            }
        }
        return []
    }
    private func deleteItem(item: String) {
        guard let config = appViewModel.selectedConnectionDetail else { return }
        RedisManager.shared.setRemoveItem(config: config, key: detail.key, item: item) {
            refresh?()
            Utils.showDeleteItemSuccessMessage(appViewModel: appViewModel)
        }
        
    }
}

#Preview {
    SetTableValueEditor(detail: .init(key: "test", ttl: "ttl", memory: "memory", type: .Set, value: .Set(["1", "2", "3"])))
}
