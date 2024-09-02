//
//  HASHValueEditor.swift
//  Madis
//
//  Created by Jack Lin on 2024/7/10.
//

import SwiftUI



// This view can use for the LIST, SET, HASH, ZSET
struct TableValueEditor: View {
    
    @State var selection: Set<UUID> = []
    
    
    var body: some View {
        @State var items = MockData.redisKeyValueItems
        
        Table(items, selection: $selection) {
            
            TableColumn("Field", value: \.field)
            TableColumn("Value", value: \.content)
            TableColumn("Operations") { item in
                OperationColumn {
                    print("copy button clicked")
                } modifyAction: {
                    print("modify button clicked")
                } deleteAction: {
                    print(item)
                    let optionId =  items.firstIndex { value in
                        return value.id == item.id
                    }
                    
                    guard let id = optionId else { return }
                    print(id)
                    items.remove(at: id)
                    print(items)
                }

                
            }
        }
        
    }
}

#Preview {
    TableValueEditor()
}
