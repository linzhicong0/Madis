//
//  DatabaseView.swift
//  Madis
//
//  Created by Jack Lin on 2024/4/22.
//

import SwiftUI

struct DatabaseView: View {
    var body: some View {
        
        HSplitView {
            LeftView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            RightView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.blue)
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(BlurView())
        
        
    }
}

#Preview {
    DatabaseView()
}


struct LeftView: View {
    
    @State var searchString: String = ""
    @State var selectedItem: String = ""
    
    var body: some View {
        VStack() {
            HStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.gray)
                    TextField("search", text: $searchString)
                        .textFieldStyle(.plain)
                    
                    
                }
                .padding(.vertical, 8)
                .padding(.horizontal)
                .background(.primary.opacity(0.15))
                .clipShape(.rect(cornerRadius: 10))
                
                
                Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.caption)
                })
                .frame(width: 30, height: 30)
                .background(.gray.opacity(0.4))
                .clipShape(.rect(cornerRadius: 8))
                .buttonStyle(PlainButtonStyle())
                
                Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                    Image(systemName: "plus")
                        .font(.caption)
                })
                .frame(width: 30, height: 30)
                .background(.gray.opacity(0.4))
                .clipShape(.rect(cornerRadius: 8))
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.top, 10)
            .padding(.horizontal, 5)
            
            Divider()
            
            
            ScrollView {
                
                
                Section {
                    
                    //                    Group {
                    //
                    OutlineGroup(MockData.redisOutlineItems, children: \.children) { item in
                        if (item.type == .Database) {
                            
                            HStack {
                                Text(item.name)
                                Text("\(item.children!.count) keys")
                            }
                            
                        }
                        else {
                            RedisItemView(item: item, selected: selectedItem == item.id)
                                .padding(.horizontal, 10)
                                .onTapGesture {
                                    selectedItem = item.id
                                }
                            
                        }
                        
                    }
                    
                    //                        List(MockData.redisOutlineItems, children: \.children) { item in
                    //                            Text(item.name)
                    //                        }
                    //                        .frame(maxWidth: .infinity)
                    
                    
                    //                        DisclosureGroup(
                    //                            content: { Text("Content") },
                    //                            label: { Text("label") }
                    //                        )
                    //                    }
                    
                } header: {
                    
                    HStack{
                        // TODO: Update it to dynamic fetch the result
                        Text("KEYS (8409 SCANNED)")
                            .font(.headline)
                            .foregroundStyle(.gray)
                        Spacer()
                    }
                }
            }
            .padding(.leading, 10)
            
            
        }
    }
}


struct RightView: View {
    var body: some View {
        Text("right")
    }
}



