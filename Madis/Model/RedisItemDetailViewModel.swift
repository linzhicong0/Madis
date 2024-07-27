//
//  RedisItemDetail.swift
//  Madis
//
//  Created by Jack Lin on 2024/7/3.
//

import Foundation

struct RedisItemDetailViewModel {
    
    var key: String
    var ttl: String
    var memory: String
    var type: RedisType
    var value: RedisValue
}
