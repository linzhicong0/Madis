//
//  MockData.swift
//  Madis
//
//  Created by Jack Lin on 2024/4/17.
//

import Foundation

struct MockData {
    static let database = [
        RedisDatabase(name: "school", rows: [
            RedisRow(key: "sample", value: "String", type: .String),
            RedisRow(key: "sample", value: "Hash", type: .Hash),
            RedisRow(key: "sample", value: "List", type: .List),
            RedisRow(key: "sample", value: "Set", type: .Set),
            RedisRow(key: "sample", value: "Stream", type: .Stream),
            RedisRow(key: "sample", value: "ZSet", type: .ZSet)
            
        ]),
        RedisDatabase(name: "user", rows: [
            RedisRow(key: "sample", value: "String", type: .String),
            RedisRow(key: "sample", value: "Hash", type: .Hash),
            RedisRow(key: "sample", value: "List", type: .List),
            RedisRow(key: "sample", value: "Set", type: .Set),
            RedisRow(key: "sample", value: "Stream", type: .Stream),
            RedisRow(key: "sample", value: "ZSet", type: .ZSet)
        ]),
        RedisDatabase(name: "movie", rows: []),
        RedisDatabase(name: "actor", rows: [])
    ]
    
    
    static let redisOutlineItems = [
        
        RedisOutlineItem(name: "user", value: "", type: .Database, children: [
            RedisOutlineItem(name: "sample", value: "string", type: .String, children: nil),
            RedisOutlineItem(name: "sample", value: "set", type: .Set, children: nil),
            RedisOutlineItem(name: "sample", value: "movie", type: .Hash, children: nil),
            RedisOutlineItem(name: "sample", value: "stream", type: .Stream, children: nil),
            RedisOutlineItem(name: "sample", value: "zset", type: .ZSet, children: nil),
            RedisOutlineItem(name: "sample", value: "list", type: .List, children: nil)
            
        ])
    ]
    
    static let redisKeyValueItems = [
        RedisKeyValue(field: "plot", content: "A promising young drummer enrolls at a cut-throat mustest"),
        RedisKeyValue(field: "title", content: "Test Title"),
        RedisKeyValue(field: "rating", content: "8.9")
    ]
    
    static let connectionItems = [
        ConnectionDetail(name: "name1", host: "127.0.0.1", port: "6379", username: "jack", password: "12345"),
        ConnectionDetail(name: "name2", host: "127.0.0.1", port: "6379", username: "jack", password: "12345"),
        ConnectionDetail(name: "name3", host: "127.0.0.1", port: "6379", username: "jack", password: "12345"),
        ConnectionDetail(name: "name4", host: "127.0.0.1", port: "6379", username: "jack", password: "12345"),
        ConnectionDetail(name: "name5", host: "127.0.0.1", port: "6379", username: "jack", password: "12345")
        
    ]
}
