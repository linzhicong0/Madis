//
//  ZSetAddItemDialog.swift
//  Madis
//
//  Created by Jack Lin on 2024/8/26.
//

import SwiftUI

struct ZSetAddItemDialog: View {
    let key: String
    
    @Environment(\.appViewModel) private var appViewModel
    
    @State private var conflictHandle: ConflictHandle = .replace
    @State private var values: [ZSetItem] = [("", 0.0)]
    
    var body: some View {
        CommonDialogView(title: "ZSet Add Item(s)") {
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
                                .tag(ConflictHandle.replace)
                            Text("Ignore")
                                .tag(ConflictHandle.ignore)
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
                                ZSetItemView(element: $values[index], onDelete: {
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
                                values.append(ZSetItem("", 0.0))
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
        
        RedisManager.shared.zsetAdd(clientName: clientName, key: key, items: values, replace: conflictHandle == .replace) { success in
            if success {
                print("Successfully added items to ZSet")
            } else {
                print("Failed to add items to ZSet")
            }
        }

    }
}

struct ZSetItemView: View {
    @Binding var element: ZSetItem
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            CustomTextField(systemImage: "book.pages", placeholder: "member", text: Binding(
                get: { element.element },
                set: { element.element = $0 }
            ))
            CustomTextField(systemImage: "line.3.horizontal.circle", placeholder: "score", text: Binding(
                get: { String(element.score) },
                set: { if let value = Double($0) { element.score = value } }
            ))
            Button(action: onDelete) {
                Image(systemName: "trash")
            }
        }
    }
}

#Preview {
    ZSetAddItemDialog(key: "key")
}
