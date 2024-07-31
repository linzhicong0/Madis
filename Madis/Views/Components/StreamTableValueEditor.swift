//
//  StreamTableValueEditor.swift
//  Madis
//
//  Created by Jack Lin on 2024/7/31.
//

import SwiftUI

struct StreamTableValueEditor: View {
    
    @State var selection: Set<UUID> = []
    let items: [StreamElement]
    
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
            ViewModel(index: index, key: value.id, value: Uitls.formatStreamValuesToString(values: value.values))
        }
    }
}

#Preview {
    StreamTableValueEditor(items: [StreamElement(id: "a", values: [(key: "1", value: "2")])])
}
