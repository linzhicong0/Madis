//
//  RedisType.swift
//  Madis
//
//  Created by Jack Lin on 2024/4/17.
//

import SwiftUI

enum RedisType {
    
    case Database
    case String
    case Hash
    case Set
    case List
    case ZSet
    case Stream
    
    
    var stringValue: String {
        switch self {
        case .Database: return "database".uppercased()
        case .String: return "string".uppercased()
        case .Hash: return "hash".uppercased()
        case .Set: return "set".uppercased()
        case .List: return "list".uppercased()
        case .ZSet: return "zset".uppercased()
        case .Stream: return "stream".uppercased()
        }
    }
    
    var colorValue: Color {
        switch self {
        case .Database: return .white
        case .String: return .green
        case .Hash: return .purple
        case .Set: return .blue
        case .List: return .orange
        case .ZSet: return .red
        case .Stream: return .pink
        }

        
    }
}
