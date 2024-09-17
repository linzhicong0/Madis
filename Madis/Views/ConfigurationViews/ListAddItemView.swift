//
//  ListAddItemView.swift
//  Madis
//
//  Created by Jack Lin on 2024/8/13.
//

import SwiftUI

struct ListAddItemView: View {
    
    let key: String
    
    @Environment(\.appViewModel) private var appViewModel
    @State private var direction: ListPushDirection = .start
    @State private var values = [""]
    
    var body: some View {
        
        CommonDialogView(title: "List Add Item(s)") {
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
                        Picker("", selection: $direction) {
                            Text("Start")
                                .tag(ListPushDirection.start)
                            Text("End")
                                .tag(ListPushDirection.end)
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
        self.values.removeAll { $0.isEmpty }
        if self.values.isEmpty {
            Utils.showErrorMessage(appViewModel: appViewModel, message: "Please enter at least one item.")
            return
        }
        
        guard let config = appViewModel.selectedConnectionDetail else { return }
        
        RedisManager.shared.listAddItem(config: config, key: key, items: values, direction: direction) { result in
            if (result < 0 ) {
                Utils.showErrorMessage(appViewModel: appViewModel, message: "Failed to add item\(values.count > 1 ? "s" : "").")
            } else {
                Utils.showSuccessMessage(appViewModel: appViewModel, message: "Add item\(values.count > 1 ? "s" : "") successfully.")
            }
        }
    }
}

#Preview {
    ListAddItemView(key: "key")
        .frame(width: 600, height: 380)
}

struct ItemView: View{
    
    @Binding var value: String
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            CustomTextField( systemImage: "line.3.horizontal.circle", placeholder: "new item", text: $value)
            Button(action: {
                onDelete()
            }, label: {
                Image(systemName: "trash")
            })
        }
        
    }
}


#Preview {
    ItemView(value: .constant("")) {
        
    }
}
