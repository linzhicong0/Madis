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
                } deleteAction: {
//                    onDeleteAt?(item.index)
                    deleteItem(index: item.index)
                }
            }
            .width(100)
            .alignment(.center)
        }
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
            }
        }

    }
}

#Preview {
    ListTableValueEditor(detail: .init(key: "key", ttl: "ttl", memory: "memory", type: .List, value: .List(["1", "2"])))
}
