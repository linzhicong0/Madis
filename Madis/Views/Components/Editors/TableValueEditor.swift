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

struct OperationColumn: View {
    
    @State private var isModifyButtonHovering = false
    @State private var isDeleteButtonHovering = false
    @State private var isCopyButtonHovering = false
    
    var showModifyButton: Bool = true
    var copyAction: ()-> Void
    var modifyAction: ()-> Void
    var deleteAction: () -> Void
    
    var body: some View {
        
        HStack(alignment: .center) {
            Button(action: {
                copyAction()
            }, label: {
                Image(systemName: "doc.on.doc")
                    .foregroundStyle(isCopyButtonHovering ? .yellow : .white)
                    .contentShape(Rectangle())
            })
            .onHover(perform: { hovering in
                isCopyButtonHovering = hovering
            })
            
            if showModifyButton {
                Button(action: {
                    modifyAction()
                }, label: {
                    Image(systemName: "square.and.pencil")
                        .resizable()
                        .frame(width: 15, height: 15)
                        .foregroundStyle(isModifyButtonHovering ? .blue : .white)
                        .contentShape(Rectangle())
                })
                .onHover(perform: { hovering in
                    isModifyButtonHovering = hovering
                })
            }
            
            Button(action: {
                deleteAction()
            }, label: {
                Image(systemName: "trash")
                    .foregroundStyle(isDeleteButtonHovering ? .pink : .white)
                    .contentShape(Rectangle())
            })
            .onHover(perform: { hovering in
                isDeleteButtonHovering = hovering
            })
            
        }
    }
}

#Preview {
    TableValueEditor()
}
