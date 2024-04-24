//
//  RedisDatabase.swift
//  Madis
//
//  Created by Jack Lin on 2024/4/17.
//

import Foundation

struct RedisDatabase: Identifiable {
    
    let id: String = UUID().uuidString
    let name: String
    let rows: [RedisRow]
    
    var numOfKeys: Int {
        return rows.count
    }
    
}


struct RedisOutlineItem: Identifiable {
    
    let id: String = UUID().uuidString
    let name: String
    let value: String
    let type: RedisType
    let children: [RedisOutlineItem]?
}
