//
//  RedisValue.swift
//  Madis
//
//  Created by Jack Lin on 2024/7/23.
//

import Foundation

// typealias ZSetItem = (element: String, score: Double)
// typealias HashElement = [String:String]

enum RedisValue {
    case String(String)
    case List([String])
    case Set([String])
    case ZSet([ZSetItem])
    case Hash([HashElement])
    case Stream([StreamElement])
    case None
}
struct StreamElement {
    let id: String
//    let values: [[String : String]]
    let values: [StreamField]
}


struct ZSetItem: Hashable {
    var element: String
    var score: Double
    
    init(_ element: String, _ score: Double) {
        self.element = element
        self.score = score
    }
}

struct HashElement: Hashable {
    var field: String
    var value: String
    
    init(field: String, value: String) {
        self.field = field
        self.value = value
    }
}




