//
//  RedisValue.swift
//  Madis
//
//  Created by Jack Lin on 2024/7/23.
//

import Foundation

typealias ZSetItem = (element: String, score: Double)
typealias HashElement = [String:String]


enum RedisValue {
    case String(String)
    case List([String])
    case Set([String])
    case ZSet([ZSetItem])
    case Hash(HashElement)
    case Stream([StreamElement])
    case None
}



struct StreamElement {
    let id: String
//    let values: [[String : String]]
    let values: [(key: String, value: String)]
}
