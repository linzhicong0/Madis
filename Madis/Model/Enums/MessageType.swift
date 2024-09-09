//
//  MessageType.swift
//  Madis
//
//  Created by Jack Lin on 2024/9/9.
//

import SwiftUI

enum FloatingMessageType {
    case success, warning, info, error
    
    var backgroundColor: Color {
        switch self {
        case .success: return .green
        case .warning: return .orange
        case .info: return .blue
        case .error: return .red
        }
    }
    
    var iconName: String {
        switch self {
        case .success: return "checkmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .info: return "info.circle.fill"
        case .error: return "xmark.circle.fill"
        }
    }
}
