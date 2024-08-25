//
//  HashAddItemDialog.swift
//  Madis
//
//  Created by Jack Lin on 2024/8/25.
//

import SwiftUI

struct HashAddItemDialog: View {
    
    let key: String
    
    @Environment(\.appViewModel) private var appViewModel
    
    @State private var conflictHandle: HashConflictHandle = .replace
    @State private var values: [HashItem] = [.init(field: "", value: "")]
    
    var body: some View {
        
        CommonDialogView(title: "Hash Add Item(s)") {
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
                    HStack {
                        Picker("", selection: $conflictHandle) {
                            Text("Replace")
                                .tag(HashConflictHandle.replace)
                            Text("Ignore")
                                .tag(HashConflictHandle.ignore)
                        }
                        .frame(width: 200)
                        .pickerStyle(.segmented)
                        .labelsHidden()
                        Spacer()
                    }
                } header: {
                    HStack {
                        Text("Type")
                            .font(.system(size: 14))
                            .foregroundStyle(.white)
                        Spacer()
                    }
                }
            }
            VStack {
                Section {
                    ScrollViewReader { scrollProxy in
                        ScrollView {
                            ForEach(0..<values.count, id: \.self) { index in
                                HashItemView(field: $values[index].field, value:$values[index].value, onDelete: {
                                    if (values.count > 1) {
                                        values.remove(at: index)
                                    }
                                })
                                .padding(.trailing, 5)
                            }
                            .onChange(of: values.count) { oldValue, newValue in
                                scrollProxy.scrollTo("PlusButton", anchor: .bottom)
                            }
                            Button(action: {
                                values.append(HashItem(field: "", value: ""))
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
        
        var fields: [String: String] = [:]
        
        values.forEach { hashItem in
            fields[hashItem.field] = hashItem.value
        }
        
        guard let clientName = appViewModel.selectedConnectionDetail?.name else { return }
        
        RedisManager.shared.hashSetFields(clientName: clientName, key: key, fields: fields) { value in
            // TODO: error handle
            if !value {
                print("error")
            }
        }
    }
}

struct HashItemView: View {
    
    @Binding var field: String
    @Binding var value: String
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            CustomTextField( systemImage: "book.pages", placeholder: "field", text: $field)
            CustomTextField( systemImage: "line.3.horizontal.circle", placeholder: "value", text: $value)
            Button(action: {
                onDelete()
            }, label: {
                Image(systemName: "trash")
            })
        }
        
    }
}

struct HashItem {
    var field: String
    var value: String
    
}

#Preview {
    HashAddItemDialog(key: "key")
}
