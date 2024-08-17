//
//  CommonDialogView.swift
//  Madis
//
//  Created by Jack Lin on 2024/8/17.
//

import SwiftUI

struct CommonDialogView<Content: View>: View {
    let title: String
    let content: Content
    let onConfirmClicked: (() -> Void)?
    let onCancelClicked: (() -> Void)?
    
    @Environment(\.dismiss) var dismiss
   
    init(title: String, @ViewBuilder content: () -> Content, onConfirmClicked: ( () -> Void)? = nil, onCancelClicked: (() -> Void)? = nil) {
        self.title = title
        self.content = content()
        self.onConfirmClicked = onConfirmClicked
        self.onCancelClicked = onCancelClicked
    }
    
    var body: some View {
        VStack(spacing: 15) {
            Text(title)
                .font(.title)
            content
            
            Spacer()
            
            HStack {
                
                Spacer()
                
                Button(action: {
                    if let cancelAction = onCancelClicked {
                        cancelAction()
                    } else {
                        dismiss()
                    }
                }, label: {
                    Text("Cancel")
                        .padding(5)
                        .foregroundStyle(.white)
                })
                .buttonStyle(.borderedProminent)
                
                Button(action: {
                    onConfirmClicked?()
                }, label: {
                    Text("Confirm")
                        .padding(5)
                        .foregroundStyle(.white)
                })
                .buttonStyle(.borderedProminent)
                
            }
        }
        .padding(15)
        .frame(width: 600, height: 420)
    }
}

#Preview {
    CommonDialogView(title: "Test") {
        Text("text")
    }
}
