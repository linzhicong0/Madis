//
//  ListTableValueEditor.swift
//  Madis
//
//  Created by Jack Lin on 2024/7/30.
//

import SwiftUI

struct ListTableValueEditor: View {
    
    @Environment(\.appViewModel) private var appViewModel
    @State var selection: Set<UUID> = []
    
    var detail: RedisItemDetailViewModel
    var refresh: (() -> Void)?
    
    @State private var openEditDialog = false
    @State private var selectedIndex: Int = -1
    @State private var selectedValue = ""

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
                    print("modify button clicked: \(item.value)")
                    selectedIndex = item.index
                    selectedValue = item.value
                    openEditDialog.toggle()
                } deleteAction: {
                    deleteItem(index: item.index)
                }
            }
            .width(100)
            .alignment(.center)
            
        }
        .sheet(isPresented: $openEditDialog, content: {
            ListModifyItemDialog(value: $selectedValue) {
                print(selectedValue)
                guard let clientName = appViewModel.selectedConnectionDetail?.name else { return }
                RedisManager.shared.listModifyItemAt(clientName: clientName, key: detail.key, index: selectedIndex, to: selectedValue) {
                    refresh?()
                    appViewModel.floatingMessage = "Update item successfully."
                    appViewModel.floatingMessageType = .success
                    withAnimation(.easeInOut(duration: 0.3)) {
                        appViewModel.showFloatingMessage = true
                    }
                }
            }
        })
        
    }
    
    var viewModel: [ViewModel] {
        if case let RedisValue.List(items) = detail.value {
            return items.enumerated().map { index, value in
                ViewModel(index: index, value: value)
            }
        }
        return []
    }
    private func deleteItem(index: Int) {
        guard let clientName = appViewModel.selectedConnectionDetail?.name else { return }
        RedisManager.shared.listRemoveItemAt(clientName: clientName, key: detail.key, index: index) { value in
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
    ListTableValueEditor(detail: .init(key: "key", ttl: "ttl", memory: "memory", type: .List, value: .List(["1", "2"])))
}
