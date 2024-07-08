//
//  DatabaseView.swift
//  Madis
//
//  Created by Jack Lin on 2024/4/22.
//

import SwiftUI

struct DatabaseView: View {
    
    @Environment(\.appViewModel) private var appViewModel
    @State var redisDetailViewModel: RedisItemDetailViewModel?
    
    
    var body: some View {
        
        HSplitView {
            // TODO: change the init width
            LeftView(redisDetailViewModel: $redisDetailViewModel)
                .frame(minWidth: 200, maxWidth: 400, maxHeight: .infinity)
            RightView(redisDetailViewModel: $redisDetailViewModel)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(BlurView())
        
    }
}

#Preview {
    DatabaseView()
}


struct LeftView: View {
    
    @Environment(\.appViewModel) private var appViewModel
    @State var searchString: String = ""
    @State var selectedItem: String = ""
    @State var redisOutlineItems: [RedisOutlineItem] = []
    @Binding var redisDetailViewModel: RedisItemDetailViewModel?
    
    var body: some View {
        VStack {
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
                
                Button(action: {
                    print("refresh button clicked")
                    getAllKeys()
                }, label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.caption)
                        .frame(width: 30, height: 30)
                        .contentShape(Rectangle())
                })
                .buttonStyle(PlainButtonStyle())
                .background(.gray.opacity(0.4))
                .clipShape(.rect(cornerRadius: 8))
                
                Button(action: {
                    print("plus button clicked")
                }, label: {
                    Image(systemName: "plus")
                        .font(.caption)
                        .frame(width: 30, height: 30)
                        .contentShape(Rectangle())
                })
                .buttonStyle(PlainButtonStyle())
                .background(.gray.opacity(0.4))
                .clipShape(.rect(cornerRadius: 8))
            }
            .padding(.top, 10)
            .padding(.horizontal, 5)
            
            Divider()
            
            Section {
                List(redisOutlineItems, children: \.children) { item in
                    if item.children != nil {
                        HStack(spacing:5) {
                            Image(systemName: "folder")
                            Text(item.label)
                            Text("(\(item.children!.count))")
                        }
                        .onTapGesture {
                            print("click")
                            selectedItem = item.id
                        }
                    }
                    else {
                        RedisItemView(item: item, selected: selectedItem == item.id)
                            .onTapGesture {
                                print("click")
                                withAnimation(.linear(duration: 0.1)) {
                                    selectedItem = item.id
                                    selectKey(key: item.key!)
                                }
                            }
                    }
                }
                .listStyle(.sidebar)
            } header: {
                HStack{
                    // TODO: Update it to dynamic fetch the result
                    Text("KEYS (8409 SCANNED)")
                        .font(.headline)
                        .foregroundStyle(.gray)
                    Spacer()
                }
            }
            .padding(.leading, 10)
            
        }
        .onAppear() {
            getAllKeys()
        }
    }
    
    private func getAllKeys() {
        print("DatabaseView left view onAppear")
        RedisManager.shared.getAllKeys(clientName: appViewModel.selectedRedisCLientName) { values in
            redisOutlineItems = values
        }
        print("Finished getting keys from redis")
    }
    
    private func selectKey(key: String) {
        RedisManager.shared.getKeyMetaData(clientName: appViewModel.selectedRedisCLientName, key: key) { viewModel in
            redisDetailViewModel = viewModel
        }
    }
}


struct RightView: View {
    @State var selection: Set<UUID> = []
    @State var fieldText: String = ""
    @State var contentText: String = ""
    @Binding var redisDetailViewModel: RedisItemDetailViewModel?
    
    
    var body: some View {
        VStack {
            
            if redisDetailViewModel == nil {
                Text("No key selected...")
            }
            else {
                // Top
                HStack {
                    Text("\(redisDetailViewModel!.key)")
                    Spacer()
                    
                    Button(action: {}, label: {
                        Image(systemName:  "heart" )
                    })
                    .buttonStyle(BorderedButtonStyle())
                    
                    Button(action: {}, label: {
                        
                        HStack(spacing:1) {
                            Image(systemName: "gear")
                            Image(systemName: "chevron.down")
                            
                        }
                    })
                    .buttonBorderShape(.roundedRectangle)
                    
                    
                }
                .padding(.vertical, 13)
                .padding(.horizontal)
                .background(BlurView())
                
                VStack {
                    
                    // info
                    HStack {
                        // TTL
                        Text("TTL:")
                            .font(.caption)
                        Text("\(redisDetailViewModel!.ttl)")
                            .font(.caption2)
                            .foregroundStyle(.gray)
                        
                        // Memory
                        Text("Memory:")
                            .font(.caption)
                        Text("\(redisDetailViewModel!.memory)")
                            .font(.caption2)
                            .foregroundStyle(.gray)
                        
                        // Encoding
                        Text("Encoding:")
                            .font(.caption)
                        
//                        Text("\(redisDetailViewModel!.encoding)")
//                            .font(.caption2)
//                            .foregroundStyle(.gray)
//                        
                        Spacer()
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, 4)
                    .background(.black.secondary)
                    
                    // table
                    HStack {
                        
                        Table(MockData.redisKeyValueItems, selection: $selection) {
                            
                            TableColumn("Field", value: \.field)
                            TableColumn("Content", value: \.content)
                        }
                        
                        Divider()
                        
                        VStack {
                            
                            Form {
                                Section {
                                    TextEditor(text: $fieldText)
                                        .font(.headline)
                                        .frame(height: 100)
                                } header: {
                                    Text("Field")
                                        .font(.caption)
                                        .foregroundStyle(.gray)
                                    
                                }
                                
                                Section {
                                    TextEditor(text: $contentText)
                                        .frame(height: 100)
                                } header: {
                                    Text("Content")
                                        .font(.caption)
                                        .foregroundStyle(.gray)
                                }
                                
                            }
                            
                            Spacer()
                        }
                        .padding(.trailing, 8)
                        .frame(maxWidth: 200, maxHeight: .infinity)
                        
                    }
                    
                    // bottom
                }
            }
        }
    }
}



