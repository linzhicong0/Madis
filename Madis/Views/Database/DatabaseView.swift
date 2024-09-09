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
        
        
        if appViewModel.selectedConnectionDetail == nil {
            Text("Please select a connection")
                .font(.title3)
        }
        else {
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
    @State var totalKeys: Int = 0
    
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
                    //                    getAllKeys()
                    getAllKeysWithType()
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
                            selectedItem = item.id
                        }
                    }
                    else {
                        RedisItemView(item: item, selected: selectedItem == item.id)
                            .onTapGesture {
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
                    Text("KEYS (\(totalKeys) SCANNED)")
                        .font(.headline)
                        .foregroundStyle(.gray)
                    Spacer()
                }
            }
            .padding(.leading, 10)
            
        }
        .task {
            getAllKeysWithType()
        }
    }
    
    private func getAllKeysWithType() {
        guard let clientName = appViewModel.selectedConnectionDetail?.name else { return  }
        
        RedisManager.shared.getAllKeysWithType(clientName: clientName) { values in
            totalKeys = values.0
            redisOutlineItems = values.1
        }
        
    }
    
    private func selectKey(key: String) {
        
        guard let clientName = appViewModel.selectedConnectionDetail?.name else { return }
        RedisManager.shared.getKeyMetaData(clientName: clientName, key: key) { viewModel in
            redisDetailViewModel = viewModel
        }
    }
}


struct RightView: View {
    @Environment(\.appViewModel) var appViewModel
    @State var selection: Set<UUID> = []
    @State var fieldText: String = ""
    @State var contentText: String = ""
    @Binding var redisDetailViewModel: RedisItemDetailViewModel?
    
    @State private var openDialog = false
    @State private var openTTLDialog = false

    // Not sure why we need this right now, but if we bind from the viewmodel, it will
    // say can not find the appViewModel in the scope
    private var showFloatingMessageBinding: Binding<Bool> {
        Binding(
            get: { appViewModel.showFloatingMessage },
            set: { appViewModel.showFloatingMessage = $0 }
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            
            if redisDetailViewModel == nil {
                Text("No key selected...")
            }
            else {
                // Top
                HStack {
                    Text("\( redisDetailViewModel?.type.stringValue ?? "")")
                        .padding(.vertical, 3)
                        .frame(width: 60)
                        .foregroundStyle(.white)
                        .background(redisDetailViewModel?.type.colorValue ?? .blue)
                        .clipShape(.rect(cornerRadius: 3))
                    Text("\(redisDetailViewModel!.key)")
                        .font(.system(size: 22))
                    Spacer()
                    
                    if redisDetailViewModel?.type == .String {
                        Button(action: {
                            print("copy button clicked")
                        }, label: {
                            Label("copy", systemImage: "doc.on.doc")
                        })
                        .buttonBorderShape(.roundedRectangle)
                    }
                    
                    // refresh button
                    Button(action: {
                       refresh()
                    }, label: {
                        Image(systemName: "arrow.clockwise")
                    })
                    .help("Refresh")
                    
                    Button(action: {
                       openTTLDialog.toggle() 
                    }, label: {
                        Image(systemName: "clock")
                    })
                    .help("Set TTL")
                    
                    Button {
                        print("save button clicked")
                        
                        guard let clientName = appViewModel.selectedConnectionDetail?.name else { return  }
                        RedisManager.shared.save(clientName: clientName, key: redisDetailViewModel!.key, value: redisDetailViewModel!.value) {
                            print("saved")
                            
                            RedisManager.shared.getKeyMetaData(clientName: clientName, key: redisDetailViewModel!.key) { value in
                                self.redisDetailViewModel = value
                            }
                        }
                    } label: {
                        Label("save", systemImage: "opticaldiscdrive")
                    }
                    .buttonBorderShape(.roundedRectangle)
                   
                    
                    if redisDetailViewModel?.type != . String {
                        Button(action: {
                            print("plus button clicked")
                            openDialog.toggle()
                        }, label: {
                            Image(systemName: "plus")
                        })
                        .help("add new item")
                        
                    }
                }
                .padding(.vertical, 13)
                .padding(.horizontal)
                Divider()
                
                VStack(spacing: 0) {
                    
                    // info
                    HStack {
                        // TTL
                        Text("TTL:")
                        Text("\(redisDetailViewModel!.ttl)")
                            .foregroundStyle(.gray)
                        
                        // Memory
                        Text("Memory:")
                        Text("\(redisDetailViewModel!.memory)")
                            .foregroundStyle(.gray)
                        
                        // Encoding
                        Text("Encoding:")
                        
                        Spacer()
                    }
                    .font(.system(size: 12))
                    .padding(.vertical, 6)
                    .padding(.horizontal, 8)
                    
                    Divider()
                    // table
                    HStack {
                        switch redisDetailViewModel?.value {
                        case .String:
                            StringValueEditor(text: bindingString()!)
                        case .List:
                            ListTableValueEditor(detail: redisDetailViewModel!){
                                refresh()
                            }
                        case .Set:
                            SetTableValueEditor(detail: redisDetailViewModel!) {
                                refresh()
                            }
                        case .ZSet:
                            ZSetTableValueEditor(detail: redisDetailViewModel!) {
                                refresh()
                            }
                        case .Hash:
                            HashTableValueEditor(detail: redisDetailViewModel!) {
                                refresh()
                            }
                        case .Stream(let values):
                            StreamTableValueEditor(items: values)
                        default:
                            TableValueEditor()
                        }
                    }
                    .floatingMessage(isPresented: showFloatingMessageBinding,
                                     message: appViewModel.floatingMessage,
                                     type: appViewModel.floatingMessageType)
                    // bottom
                }
            }
        }
        .sheet(isPresented: $openDialog, onDismiss: {
            refresh()
        }, content: {
            switch redisDetailViewModel?.type {
            case .Hash:
                HashAddItemDialog(key: redisDetailViewModel!.key)
            case .Set:
                SetAddItemDialog(key: redisDetailViewModel!.key)
            case .List:
                ListAddItemView(key: redisDetailViewModel!.key)
            case .ZSet:
                ZSetAddItemDialog(key: redisDetailViewModel!.key)
            case .Stream:
                StreamAddItemDialog(key: redisDetailViewModel!.key)
            default:
                Text("To implement")
            }
        })
        .sheet(isPresented: $openTTLDialog, onDismiss: {
            refresh()
        }, content: {
            TTLSettingDialog(key: redisDetailViewModel!.key) { key, ttl in
            guard let selectedConnectionName = appViewModel.selectedConnectionDetail?.name else {
                return
            }
            
            RedisManager.shared.setTTL(clientName: selectedConnectionName, key: key, ttl: ttl) { success in
                if success {
                    print("TTL set successfully for key: \(key)")
                } else {
                    print("Failed to set TTL for key: \(key)")
                }
            }
            }
        })  
    }
    
    private func bindingString() -> Binding<String>? {
        if case let .String( value) = redisDetailViewModel?.value {
            return Binding<String>(
                get: { value },
                set: { newValue in
                    redisDetailViewModel?.value = .String(newValue)
                }
            )
        }
        return nil
    }
    
    private func refresh() {
        guard let clientName = appViewModel.selectedConnectionDetail?.name else { return }
        RedisManager.shared.getKeyMetaData(clientName: clientName, key: redisDetailViewModel!.key) { value in
            self.redisDetailViewModel = value
        }
    }
}



