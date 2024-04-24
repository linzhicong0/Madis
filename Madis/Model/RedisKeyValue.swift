//
//  RedisKeyValue.swift
//  Madis
//
//  Created by Jack Lin on 2024/4/24.
//

import Foundation


struct RedisKeyValue: Identifiable {
    let id = UUID()
    let field: String
    let content: String
}


