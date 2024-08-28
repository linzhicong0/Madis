//
//  ZSetModifyItemDialog.swift
//  Madis
//
//  Created by Jack Lin on 2024/8/26.
//

import SwiftUI

struct ZSetModifyItemDialog: View {
    @Binding var score: Double
    @Binding var member: String
    var onConfirmClicked: (() -> Void)?
    
    var body: some View {
        CommonDialogView(title: "Edit ZSet Item") {
            VStack(alignment: .leading) {
                Section {
                    CustomTextField(placeholder: "Score", text: Binding(
                        get: { String(score) },
                        set: { if let value = Double($0) { score = value } }
                    ))
                } header: {
                    Text("Score")
                        .font(.headline)
                        .foregroundStyle(.white)
                }
                Section {
                    TextEditor(text: $member)
                        .textEditorStyle(.plain)
                        .foregroundStyle(.white)
                        .padding(.top, 10)
                        .font(.system(size: 15))
                        .background(.black.opacity(0.3))
                } header: {
                    Text("Member")
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
    ZSetModifyItemDialog(score: .constant(1.0), member: .constant("example"), onConfirmClicked: {})
}
