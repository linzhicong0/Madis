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
    @State private var selection: String = "Start"
    @State private var strings = [""]
    
    var body: some View {
        
        CommonDialogView(title: "Add Item(s)") {
            content
        } onConfirmClicked: {
        }
    }
    
    private var content: some View {
        VStack(spacing: 15) {
            CustomFormInputView(title: "Connection Name", systemImage: "key.horizontal", placeholder: "connection name", disableTextInput: true, text: .constant(key))
            VStack {
                Section {
                    HStack {
                        Picker("", selection: $selection) {
                            Text("Start")
                                .tag("Start")
                            Text("End")
                                .tag("End")
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
                            ForEach(0..<strings.count, id: \.self) { index in
                                ItemView(value: $strings[index]){
                                    if (strings.count > 1) {
                                        strings.remove(at: index)
                                    }
                                }
                                .padding(.trailing, 5)
                            }
                            .onChange(of: strings.count) { oldValue, newValue in
                                scrollProxy.scrollTo("PlusButton", anchor: .bottom)
                            }
                            Button(action: {
                                strings.append("")
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
        self.strings.forEach { value in
            if value.isEmpty {
                // TODO: Show an alert view to tell the user
                // some of the value is empty
               return
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
