//
//  AddItemDialog.swift
//  Madis
//
//  Created by Jack Lin on 2024/9/17.
//

import SwiftUI

struct AddItemDialog: View {
    @State private var key: String = ""
    @State private var databaseIndex: Int = 0
    @State private var dataType: RedisType = .String
    @State private var ttl: Int = -1
    @State private var value: String = ""

    @State private var redisValue: RedisValue = .String("")
    
    @Environment(\.appViewModel) private var appViewModel
    
    var body: some View {
        CommonDialogView(title: "Add Item") {
            content
        } onConfirmClicked: {
            confirm()
        }
        .frame(width: 600, height: 550)
    }
    
    private var content: some View {
        ScrollView {
            VStack(spacing: 15) {
                CustomFormInputView(title: "Key", systemImage: "key", placeholder: "Enter key", text: $key)
                
                Section {
                    Picker("", selection: $databaseIndex) {
                        ForEach(0..<16) { index in
                            Text("\(index)").tag(index)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .labelsHidden()
                } header: {
                    HStack {
                        Text("Database Index")
                            .font(.system(size: 14))
                            .foregroundStyle(.white)
                        Spacer()
                    }
                }
                
                Section {
                    Picker("", selection: $dataType) {
                        ForEach(RedisType.allCases, id: \.self) { type in
                            Text(type.stringValue).tag(type)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .labelsHidden()
                    .onChange(of: dataType) { _, newType in
                        updateRedisValue(for: newType)
                    }
                } header: {
                    HStack {
                        Text("Data Type")
                            .font(.system(size: 14))
                            .foregroundStyle(.white)
                        Spacer()
                    }
                }
                
                Section {
                    HStack {
                        CustomTextField(systemImage: "clock", placeholder: "TTL", text: Binding(
                            get: { String(ttl) },
                            set: { if let value = Int($0) { ttl = value } }
                        ))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                } header: {
                    HStack {
                        Text("TTL (seconds)")
                            .font(.system(size: 14))
                            .foregroundStyle(.white)
                        Spacer()
                    }
                }
                
                Section {
                    switch dataType {   
                    case .String:
                        stringValueEditor
                            .frame(height: 100)
                    case .List:
                        ListAddItemsEditor(items: $redisValue)
                            .frame(height: 100)
                    case .ZSet:
                        ZSetAddItemsEditor(items: $redisValue)
                            .frame(height: 100) 
                    case .Set:  
                        SetAddItemEditor(items: $redisValue)
                            .frame(height: 100)
                    case .Hash: 
                        HashAddItemsEditor(items: $redisValue)
                            .frame(height: 100)
                    case .Stream:
                        StreamAddItemEditor(items: $redisValue)
                            .frame(height: 200)
                    case .None:
                        Text("Not implemented yet")
                            .foregroundColor(.gray)
                            .frame(height: 100)
                    }
                } header: {
                    if dataType != .Stream {
                    HStack {
                        Text("Value")
                            .font(.system(size: 14))
                            .foregroundStyle(.white)
                        Spacer()
                    }
                    }
                }
            }
            .padding()
        }
        .frame(height: 400)
    }
    private var stringValueEditor: some View {
        StringValueEditor(text: Binding(
            get: { 
                if case let .String(str) = redisValue {
                    return str
                }
                return ""
            },
            set: { redisValue = .String($0) }
        ))
    }

    private func updateRedisValue(for type: RedisType) {
        switch type {
        case .String:
            redisValue = .String("")
        case .List:
            redisValue = .List([""])
        case .Hash:
            redisValue = .Hash([])
        case .Set:
            redisValue = .Set([""])
        case .ZSet:
            redisValue = .ZSet([ZSetItem("", 0.0)])
        case .Stream:
            redisValue = .Stream([StreamElement(id: "", values: [])])
        case .None:
            redisValue = .None
        }
    }

    private func confirm() {
        print(redisValue)
    }
}

#Preview {
    AddItemDialog()
}
