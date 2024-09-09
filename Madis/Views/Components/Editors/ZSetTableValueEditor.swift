//
//  ZSetTableValueEditor.swift
//  Madis
//
//  Created by Jack Lin on 2024/7/31.
//

import SwiftUI

struct ZSetTableValueEditor: View {
    @State var selection: Set<UUID> = []
    @Environment(\.appViewModel) private var appViewModel
    @State private var openEditDialog: Bool = false
    @State private var selectedValue: String = ""
    @State private var selectedScore: Double = 0.0
    @State private var originalValue: String = ""
    @State private var modifyMessage: String = ""
    @State private var messageType: FloatingMessageType = .success
    
    let detail: RedisItemDetailViewModel
    let refresh: (() -> Void)?
    
    struct ViewModel: Identifiable {
        let id: UUID = UUID()
        let index: Int
        let value: String
        let score: String
    }
    
    var body: some View {
        Table(viewModel, selection: $selection) {
            TableColumn("#", value: \.index.description)
                .width(50)
                .alignment(.center)
            TableColumn("Value", value: \.value)
                .alignment(.center)
            TableColumn("Score", value: \.score)
                .alignment(.center)
            TableColumn("Operations") { item in
                OperationColumn {
                    let pasteboard = NSPasteboard.general
                    pasteboard.clearContents()
                    pasteboard.setString(item.value, forType: .string)
                } modifyAction: {
                    selectedValue = item.value
                    selectedScore = Double(item.score) ?? 0.0
                    originalValue = item.value
                    openEditDialog = true
                } deleteAction: {
                    deleteItem(item: item)
                }
            }
            .width(100)
            .alignment(.center)
        }
        .sheet(isPresented: $openEditDialog) {
            ZSetModifyItemDialog(score: $selectedScore, member: $selectedValue) {
                if let clientName = appViewModel.selectedConnectionDetail?.name {
                    RedisManager.shared.zsetAdd(clientName: clientName, key: detail.key, items: [(element: selectedValue, score: selectedScore)], replace: true) { success in
                        if success {
                            refresh?()
                            appViewModel.floatingMessage = "Item updated successfully"
                            appViewModel.floatingMessageType = .success
                        } else {
                            appViewModel.floatingMessage = "Failed to update item"
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

    var viewModel: [ViewModel] {
        if case let RedisValue.ZSet(items) = detail.value {
            return items.enumerated().map { index, value in
                ViewModel(index: index, value: value.0, score: value.1.description)
            }
        }
        return []
        
    }

    private func deleteItem(item: ViewModel) {
        if let clientName = appViewModel.selectedConnectionDetail?.name {
            RedisManager.shared.zsetRemoveItem(clientName: clientName, key: detail.key, item: item.value) { count in
                if count > 0 {
                    refresh?()
                }
            }
        }
    }
}

