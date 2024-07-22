//
//  RedisType.swift
//  Madis
//
//  Created by Jack Lin on 2024/4/17.
//

import SwiftUI

enum RedisType {
    
    case String
    case Hash
    case Set
    case List
    case ZSet
    case Stream
    case None
    
    
    var stringValue: String {
        switch self {
        case .String: return "string".uppercased()
        case .Hash: return "hash".uppercased()
        case .Set: return "set".uppercased()
        case .List: return "list".uppercased()
        case .ZSet: return "zset".uppercased()
        case .Stream: return "stream".uppercased()
        case .None: return "none".uppercased()
        }
    }
    
    var colorValue: Color {
        switch self {
        case .String: return .green
        case .Hash: return .purple
        case .Set: return .blue
        case .List: return .orange
        case .ZSet: return .red
        case .Stream: return .pink
        case .None: return .white
        }

        
    }
    static func fromString(_ rawValue: String) -> RedisType {
        switch rawValue.uppercased() {
        case "STRING":
            return .String
        case "HASH":
            return .Hash
        case "SET":
            return .Set
        case "LIST":
            return .List
        case "ZSET":
            return .ZSet
        case "STREAM":
            return .Stream
        case "NONE":
            return .None
        default:
            return .None
        }
    }
}
