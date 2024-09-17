//
//  TopBarView.swift
//  Madis
//
//  Created by Jack Lin on 2024/4/22.
//

import SwiftUI

struct TopBarView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.appViewModel) private var appViewModel
    
    var body: some View {
        @Bindable var appViewModel = appViewModel
        HStack(alignment: .center, spacing: 20) {
            
            // back
            Button(action: {
                print(colorScheme)
            }, label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14))
            })
            .buttonStyle(PlainButtonStyle())
            
            // forward
            Button(action: {}, label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
            })
            .buttonStyle(PlainButtonStyle())
            
            // sidebar
            Button(action: {
                withAnimation {
                    appViewModel.showTitleForTabBar.toggle()
                }
            }, label: {
                Image(systemName: "sidebar.left")
                    .font(.system(size: 14))
            })
            .buttonStyle(PlainButtonStyle())
            
            
            // setting
            Button(action: {}, label: {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 14))
            })
            .buttonStyle(PlainButtonStyle())
            
            // lock
            Button(action: {}, label: {
                Image(systemName: "lock.open.fill")
                    .font(.system(size: 14))
            })
            .buttonStyle(PlainButtonStyle())
            
            
            HStack(alignment: .center) {
                Picker("Select Connection", selection: $appViewModel.selectedConnectionDetail) {
//                    ForEach(Array(RedisManager.shared.redisClients.keys), id: \.self) { key in
//                        Text(key)
////                            .tag(RedisManager.shared.redisClients[key]?.connectionDetail)
//                    }
                }
                .onChange(of: appViewModel.selectedConnectionDetail) { oldValue, newValue in
                    if let newValue = newValue {
                        appViewModel.selectedConnectionDetail = newValue
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .frame(maxWidth: 200)
                .font(.caption)
                .padding(.leading, 5)
                
                Spacer()
                Text("Redis 7.2.0")
                    .font(.caption)
                    .padding(.trailing, 10)
            }
            .frame(height: 20)
            .background(.gray.opacity(0.2))
            .clipShape(.rect(cornerRadius: 5))
            
            
            // history
            Button(action: {}, label: {
                Image(systemName: "clock.fill")
                    .font(.system(size: 14))
            })
            .buttonStyle(PlainButtonStyle())
            // wifi?
            Button(action: {}, label: {
                Image(systemName: "dot.radiowaves.left.and.right")
                    .font(.system(size: 14))
            })
            .buttonStyle(PlainButtonStyle())
            // right side bar
            Button(action: {}, label: {
                Image(systemName: "sidebar.right")
                    .font(.system(size: 14))
            })
            .buttonStyle(PlainButtonStyle())
            
            
        }
        .padding(.leading, 75)
        
        
        
    }
    
    var selectHostAndPort: String {
        guard let connectionDetail = appViewModel.selectedConnectionDetail else {
            return "No Connection"
        }
        return "\(connectionDetail.host):\(connectionDetail.port) (\(connectionDetail.name))"
        
        
    }
}

#Preview {
    TopBarView()
}
