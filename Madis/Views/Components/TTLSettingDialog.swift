//
//  TTLSettingDialog.swift
//  Madis
//
//  Created by Jack Lin on 2024/9/3.
//

import SwiftUI

struct TTLSettingDialog: View {
    let key: String
    
    @State private var ttl: Int64 = -1
    @State private var timeUnit: TimeUnit = .seconds
    
    let onConfirm: (String, Int64) -> Void
    
    var body: some View {
        CommonDialogView(title: "Update TTL") {
            content
        } onConfirmClicked: {
            onConfirm(key, calculateTTLInSeconds())
        }
    }
    
    private var content: some View {
        VStack(alignment: .leading, spacing: 15) {
            CustomFormInputView(title: "Key", systemImage: "key.horizontal", placeholder: "key", disableTextInput: true, text: .constant(key))
            VStack(alignment: .leading) {
                Section {
                    HStack(alignment: .center) {
                        CustomTextField(systemImage: "clock", placeholder: "TTL", text: Binding(
                            get: { String(ttl) },
                            set: { if let value = Int64($0) { ttl = value } }
                        ))
                        
                        Picker("", selection: $timeUnit) {
                            ForEach(TimeUnit.allCases, id: \.self) { unit in
                                Text(unit.rawValue)
                                    .tag(unit)
                            }
                        }
                        .frame(width: 150)
                    }
                } header: {
                    Text("TTL")
                        .font(.system(size: 14))
                        .foregroundStyle(.white)
                }
            }
            
            VStack(alignment: .leading) {
                Section {
                    HStack {
                        ForEach(["infinity", "10 seconds", "1 minute", "1 hour", "1 day"], id: \.self) { preset in
                            Button(action: {
                                setPresetTTL(preset)
                            }) {
                                Text(preset)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(15)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                } header: {
                    Text("Quick Set")
                        .font(.system(size: 14))
                        .foregroundStyle(.white)
                }
            }
        }
    }
    
    private func setPresetTTL(_ preset: String) {
        switch preset {
        case "infinity":
            ttl = -1
            timeUnit = .seconds
        case "10 seconds":
            ttl = 10
            timeUnit = .seconds
        case "1 minute":
            ttl = 1
            timeUnit = .minutes
        case "1 hour":
            ttl = 1
            timeUnit = .hours
        case "1 day":
            ttl = 1
            timeUnit = .days
        default:
            break
        }
    }
    
    private func calculateTTLInSeconds() -> Int64 {
        switch timeUnit {
        case .seconds:
            return ttl
        case .minutes:
            return ttl * 60
        case .hours:
            return ttl * 3600
        case .days:
            return ttl * 86400
        }
    }
}

#Preview {
    TTLSettingDialog(key: "user:1:name") { key, ttl in
        print("Key: \(key), TTL: \(ttl)")
    }
}
