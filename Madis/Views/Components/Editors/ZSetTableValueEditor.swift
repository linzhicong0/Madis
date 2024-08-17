//
//  ZSetTableValueEditor.swift
//  Madis
//
//  Created by Jack Lin on 2024/7/31.
//

import SwiftUI

struct ZSetTableValueEditor: View {
  @State var selection: Set<UUID> = []
    
    let items: [SortedSetElement]
    
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
            ViewModel(index: index, value: value.value, score: value.score.description)
          }
        
    }
}

#Preview {
    ZSetTableValueEditor(items: [SortedSetElement(value: "a", score: 1.0), SortedSetElement(value: "b", score: 2.0), SortedSetElement(value: "c", score: 3.0)])
}
