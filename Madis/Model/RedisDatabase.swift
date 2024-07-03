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
    // The key of the redis object
    let key: String?
    // The label to show in the OutlineView
    let label: String
    // The type of the redis object
    let type: RedisType
    // The children of the object, split by the ":"
    var children: [RedisOutlineItem]?
}

