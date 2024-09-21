//
//  StreamAddItemEditor.swift
//  Madis
//
//  Created by Jack Lin on 2024/9/20.
//

import SwiftUI

struct StreamAddItemEditor: View {
    @Binding var items: RedisValue
    @State private var id: String = "*"
    @State private var fields: [StreamField] = [StreamField(name: "", value: "")]
    var body: some View {
        VStack {
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
        .onChange(of: fields) { oldValue, newValue in
            updateItems()
        }
        .onChange(of: id) { oldValue, newValue in
            updateItems()
        }
    }
    private func updateItems() {
        items = .Stream([StreamElement(id: id, values: fields)])
    }
}
