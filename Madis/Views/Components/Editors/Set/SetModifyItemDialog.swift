//
//  SetModifyItemDialog.swift
//  Madis
//
//  Created by Jack Lin on 2024/8/25.
//

import SwiftUI

struct SetModifyItemDialog: View {
    @Binding var value: String
    var onConfirmClicked: (() -> Void)?
    
    var body: some View {
        CommonDialogView(title: "Edit Item") {
            TextEditor(text: $value)
                .textEditorStyle(.plain)
                .foregroundStyle(.white)
                .padding(.leading, 10)
                .padding(.top, 10)
                .font(.system(size: 15))
                .background(.black.opacity(0.3))
        } onConfirmClicked: {
            onConfirmClicked?()
        }
    }
}

#Preview {
    SetModifyItemDialog(value: .constant("test"))
}
