//
//  RedisValue.swift
//  Madis
//
//  Created by Jack Lin on 2024/7/23.
//

import Foundation

typealias SortedSetElement = (value: String, score: Double)
typealias HashElement = [String:String]

enum RedisValue {
    case String(String)
    case List([String])
    case Set([String])
    case ZSet([SortedSetElement])
    case Hash(HashElement)
    case Stream
    case None
}
