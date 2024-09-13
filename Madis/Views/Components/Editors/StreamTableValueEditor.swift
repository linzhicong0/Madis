//
//  StreamTableValueEditor.swift
//  Madis
//
//  Created by Jack Lin on 2024/7/31.
//

import SwiftUI

struct StreamTableValueEditor: View {
    
    @Environment(\.appViewModel) private var appViewModel
    @State var selection: Set<UUID> = []
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
            TableColumn("ID", value: \.key)
                .alignment(.center)
            TableColumn("Value") { item in
                Text("\(item.value)")
                    .font(.system(size: 14))
                    .lineLimit(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            TableColumn("Operations") { item in
                OperationColumn(showModifyButton: false) {
                    print("copy button clicked: \(item.value)")
                    let pasteboard = NSPasteboard.general
                    pasteboard.clearContents()
                    pasteboard.setString(item.value, forType: .string)
                    
                } modifyAction: {
                    print("modify button clicked: \(item.value)")
                } deleteAction: {
                    removeItem(id: item.key)
                }
            }
            .width(100)
            .alignment(.center)
        }
    }
    
    var viewModel: [ViewModel] {
        if case let RedisValue.Stream(items) = detail.value {
            return items.enumerated().map { index, value in
                ViewModel(index: index, key: value.id, value: Utils.formatStreamValuesToString(values: value.values))
            }
        }
        return []
    }

    func removeItem(id: String) {
        RedisManager.shared.streamRemoveItem(clientName: appViewModel.selectedConnectionDetail?.name ?? "", key: detail.key, id: id) { result in
            if result {
                refresh?()
                Utils.showDeleteItemSuccessMessage(appViewModel: appViewModel)
            }
        }
    }
}

#Preview {
    StreamTableValueEditor(detail: RedisItemDetailViewModel(key: "key", ttl: "0", memory: "0", type: .Stream, value: .Stream([StreamElement(id: "a", values: [(key: "1", value: "2")])])))
}
