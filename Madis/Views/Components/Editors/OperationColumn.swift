//
//  OperationColumn.swift
//  Madis
//
//  Created by Jack Lin on 2024/9/2.
//

import SwiftUI

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
                handleHovering(hovering)
            })
            .help("Copy the content")
            
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
                    handleHovering(hovering)
                })
                .help("Modify the row")
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
                handleHovering(hovering)
            })
            .help("Delete the row")
        }
    }

    private func handleHovering(_ hovering: Bool) {
        if hovering {
            NSCursor.pointingHand.push()
        } else {
            NSCursor.pop()
        }
    }
}

