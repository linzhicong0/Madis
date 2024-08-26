//
//  HashModifyItemDialog.swift
//  Madis
//
//  Created by Jack Lin on 2024/8/25.
//

import SwiftUI

struct HashModifyItemDialog: View {
    @Binding var field: String
    @Binding var value: String
    var onConfirmClicked: (() -> Void)?
    
    var body: some View {
        CommonDialogView(title: "Edit Hash Item") {
                VStack(alignment: .leading) {
                    Section {
                        CustomTextField(placeholder: "Field", text: $field)
                    } header: {
                        Text("Field")
                            .font(.headline)
                            .foregroundStyle(.white)
                    }
                    Section {
                        TextEditor(text: $value)
                            .textEditorStyle(.plain)
                            .foregroundStyle(.white)
                            .padding(.top, 10)
                            .font(.system(size: 15))
                            .background(.black.opacity(0.3))
                    } header: {
                        Text("Value")
                            .font(.headline)
                            .foregroundStyle(.white)
                    }
                }
        } onConfirmClicked: {
            onConfirmClicked?()
        }
    }
}

#Preview {
    HashModifyItemDialog(field:.constant(""), value: .constant(""))
}
