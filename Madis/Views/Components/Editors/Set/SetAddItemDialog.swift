//
//  SetAddItemDialog.swift
//  Madis
//
//  Created by Jack Lin on 2024/8/25.
//

import SwiftUI

struct SetAddItemDialog: View {
    
    let key: String
    
    @Environment(\.appViewModel) private var appViewModel
    @State private var direction: ListPushDirection = .start
    @State private var values = [""]
    
    
    var body: some View {
        CommonDialogView(title: "Set Add Item(s)") {
            content
        } onConfirmClicked: {
            confirm()
        }
    }
    
    private var content: some View {
        VStack(spacing: 15) {
            CustomFormInputView(title: "Key", systemImage: "key.horizontal", placeholder: "key", disableTextInput: true, text: .constant(key))
            VStack {
                Section {
                    ScrollViewReader { scrollProxy in
                        ScrollView {
                            ForEach(0..<values.count, id: \.self) { index in
                                ItemView(value: $values[index]){
                                    if (values.count > 1) {
                                        values.remove(at: index)
                                    }
                                }
                                .padding(.trailing, 5)
                            }
                            .onChange(of: values.count) { oldValue, newValue in
                                scrollProxy.scrollTo("PlusButton", anchor: .bottom)
                            }
                            Button(action: {
                                values.append("")
                            }, label: {
                                Image(systemName: "plus")
                            })
                            .id("PlusButton")
                        }
                    }
                } header: {
                    HStack {
                        Text("Item(s)")
                            .font(.system(size: 14))
                            .foregroundStyle(.white)
                        Spacer()
                    }
                }
            }
        }
    }
    private func confirm() {
        // Validate the input
        self.values.forEach { value in
            if value.isEmpty {
                // TODO: Show an alert view to tell the user
                // some of the value is empty
                return
            }
        }
        
        guard let clientName = appViewModel.selectedConnectionDetail?.name else { return }
        
        RedisManager.shared.setAddItems(clientName: clientName, key: key, items: values) { result in
            if (result < 0 ) {
                print("error")
            }
        }
    }
    
    
}

#Preview {
    SetAddItemDialog(key: "test")
}
