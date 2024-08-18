//
//  ListAddItemView.swift
//  Madis
//
//  Created by Jack Lin on 2024/8/13.
//

import SwiftUI

struct ListAddItemView: View {
    
    let key: String
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.appViewModel) private var appViewModel
    @State private var direction: ListPushDirection = .start
    @State private var values = [""]
    
    var body: some View {
        
        CommonDialogView(title: "Add Item(s)") {
            content
        } onConfirmClicked: {
            confirm()
        }
    }
    
    private var content: some View {
        VStack(spacing: 15) {
            CustomFormInputView(title: "Connection Name", systemImage: "key.horizontal", placeholder: "connection name", disableTextInput: true, text: .constant(key))
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
        self.values.forEach { value in
            if value.isEmpty {
                // TODO: Show an alert view to tell the user
                // some of the value is empty
                return
            }
        }
        
        guard let clientName = appViewModel.selectedConnectionDetail?.name else { return  }
        
        RedisManager.shared.listAddItem(clientName: clientName, key: key, items: values, direction: direction) { result in
            if (result < 0 ) {
                print("error")
            } else {
                dismiss()
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
