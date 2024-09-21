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
    @State private var values: [ZSetItem] = [ZSetItem("", 0.0)]
    
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
        guard let config = appViewModel.selectedConnectionDetail else { return }
        // Remove items with empty values
        values.removeAll { $0.element.isEmpty }
        
        // Check if there are any items left after removal
        if values.isEmpty {
            Utils.showWarningMessage(appViewModel: appViewModel, message: "Please enter at least one valid item.")
            return
        }
        
        RedisManager.shared.zsetAdd(config: config, key: key, items: values, replace: conflictHandle == .replace) { success in
            if success {
                Utils.showSuccessMessage(appViewModel: appViewModel, message: "Successfully added item\(values.count > 1 ? "s" : "").")
            } else {
                Utils.showErrorMessage(appViewModel: appViewModel, message: "Failed to add item\(values.count > 1 ? "s" : "").")
            }
        }

    }
}

struct ZSetItemView: View {
    @Binding var element: ZSetItem
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            CustomTextField(systemImage: "book.pages", placeholder: "member", text: $element.element)
            CustomTextField(systemImage: "line.3.horizontal.circle", placeholder: "score", text: Binding(
                get: { String(element.score) },
                set: { element.score = Double($0) ?? 0.0 }
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
