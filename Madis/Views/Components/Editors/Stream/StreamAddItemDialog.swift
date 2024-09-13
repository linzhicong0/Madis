//
//  StreamAddItemDialog.swift
//  Madis
//
//  Created by Jack Lin on 2024/9/2.
//

import SwiftUI

struct StreamAddItemDialog: View {

    let key: String
    
    @Environment(\.appViewModel) private var appViewModel
    
    @State private var id: String = "*"
    @State private var fields: [StreamField] = [StreamField(name: "", value: "")]
    
    var body: some View {
        CommonDialogView(title: "Stream Add Item(s)") {
            content
        } onConfirmClicked: {
            confirm()
        }
    }
    
    private var content: some View {
        VStack(spacing: 15) {
            CustomFormInputView(title: "Key", systemImage: "key.horizontal", placeholder: "key", disableTextInput: true, text: .constant(key))
            CustomFormInputView(title: "ID", systemImage: "dot.scope", placeholder: "ID", text: $id)
            VStack {
                Section {
                    ScrollViewReader { scrollProxy in
                        ScrollView {
                            ForEach(0..<fields.count, id: \.self) { index in
                                StreamFieldView(name: $fields[index].name, value: $fields[index].value, onDelete: {
                                    if (fields.count > 1) {
                                        fields.remove(at: index)
                                    }
                                })
                                .padding(.trailing, 5)
                            }
                            .onChange(of: fields.count) { oldValue, newValue in
                                scrollProxy.scrollTo("PlusButton", anchor: .bottom)
                            }
                            Button(action: {
                                fields.append(StreamField(name: "", value: ""))
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
        guard let clientName = appViewModel.selectedConnectionDetail?.name else { return }
        
        let fieldDict = fields.reduce(into: [String: String]()) { dict, field in
            dict[field.name] = field.value
        }
        
        RedisManager.shared.streamAdd(clientName: clientName, key: key, id: id, fields: fieldDict) { success in
            if success {
                Utils.showSuccessMessage(appViewModel: appViewModel, message: "Successfully added entr\(fields.count > 1 ? "ies" : "y") to Stream.")
            } else {
                Utils.showErrorMessage(appViewModel: appViewModel, message: "Failed added entr\(fields.count > 1 ? "ies" : "y") to Stream.")
            }
        }
    }
}

struct StreamFieldView: View {
    @Binding var name: String
    @Binding var value: String
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            CustomTextField(systemImage: "book.pages", placeholder: "field", text: $name)
            CustomTextField(systemImage: "line.3.horizontal.circle", placeholder: "value", text: $value)
            Button(action: onDelete) {
                Image(systemName: "trash")
            }
        }
    }
}

struct StreamField {
    var name: String
    var value: String
}

#Preview {
    StreamAddItemDialog(key: "sss")
}
