//
//  ListTableValueEditor.swift
//  Madis
//
//  Created by Jack Lin on 2024/7/30.
//

import SwiftUI

struct ListTableValueEditor: View {
    
    @State var selection: Set<UUID> = []
    
    let items: [String]
    
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
              ViewModel(index: index, value: value)
          }
        
    }
}

#Preview {
    ListTableValueEditor(items: ["a", "b", "c"])
}
