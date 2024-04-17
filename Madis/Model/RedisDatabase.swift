//
//  RedisDatabase.swift
//  Madis
//
//  Created by Jack Lin on 2024/4/17.
//

import Foundation

struct RedisDatabase {
    
    let name: String
    let rows: [RedisRow]
    
    var numOfKeys: Int {
        return rows.count
    }
    
}
