//
//  StringValueEditor.swift
//  Madis
//
//  Created by Jack Lin on 2024/7/10.
//

import SwiftUI

struct StringValueEditor: View {
    @State var text: String = ""
    
    var body: some View {
        TextEditor(text: $text)
            .textEditorStyle(.plain)
            .foregroundStyle(.white)
            .padding(.leading, 10)
            .padding(.top, 10)
            .scrollDisabled(true)
            .scrollClipDisabled()
            .font(.system(size: 15))
            .background(.black.opacity(0.3))
    }
}

#Preview {
    StringValueEditor()
}
