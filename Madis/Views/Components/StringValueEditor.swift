//
//  StringValueEditor.swift
//  Madis
//
//  Created by Jack Lin on 2024/7/10.
//

import SwiftUI

struct StringValueEditor: View {
    @State private var text: String = ""
    
    var body: some View {
        HStack(spacing: 0) {
            // Line numbers
            VStack(alignment: .trailing) {
                ForEach(text.components(separatedBy: "\n"), id: \.self) { line in
                    Text(String(format: "%2d", line.count + 1))
                        .foregroundColor(.red)
                        .padding(.trailing, 5)
                }
                Spacer()
            }
            
            // Text field with line numbers
            ZStack(alignment: .topLeading) {
                TextEditor(text: $text)
                    .textEditorStyle(.plain)
                    .foregroundStyle(.black)
                    .padding(.leading, 10)
                    .scrollDisabled(true)
                    .scrollClipDisabled()
                
                
            }
            .padding(15)
        }
        .font(.body)
        .background(Color.white)
        .cornerRadius(8)
        .padding()
    }
}

#Preview {
    StringValueEditor()
}
