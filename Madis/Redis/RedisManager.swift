//
//  RedisManager.swift
//  Madis
//
//  Created by Jack Lin on 2024/5/21.
//

import NIOCore
import NIOPosix
import RediStack

public class RedisManager {
    //    static let eventLoop: EventLoop = NIOSingletons.posixEventLoopGroup.any()
    static let shared = RedisManager()
    
    private var redisClients: [String:RedisClient] = [:]
    private let eventLoop: EventLoop = NIOSingletons.posixEventLoopGroup.any()
    
    private init() {
    }
    
    func addRedisClient(name: String, config: ConnectionDetail) throws {
        // return if the name exist
        if redisClients.keys.contains(name) {
            return
        }
        
        let newClient = try RedisClient(host: config.host, port: Int(config.port)!, password: config.password == "" ? nil : config.password, initDatabase: 0, eventLoop: eventLoop  )
        redisClients[name] = newClient
        
    }
    
    // TODO: test the connection with the given config
    func testConnection(config: RedisConnectionDetail) -> Bool {
        return false
    }
    
    func testConnection(host: String, port: Int = 6379, username: String?, password: String?) -> Bool {
        return RedisClient.testConnection(host: host, port: port, username: username, password: password, initDatabase: 0, eventLoop: eventLoop)
    }
    func testConnection(host: String, port: Int = 6379, username: String?, password: String?) -> EventLoopFuture<Bool> {
        return RedisClient.testConnection(host: host, port: port, username: username, password: password, initDatabase: 0, eventLoop: eventLoop)
    }
    
    func getAllKeysWithType(clientName: String, callback: @escaping ([RedisOutlineItem]) -> Void) -> Void {
        guard let client = redisClients[clientName] else {
            callback([])
            return
        }
        
        var outlineItems = [RedisOutlineItem]()
        client.getAllKeysWithType().whenSuccess { result in
            outlineItems = self.convertKeysToRedisOutlineItem(keysWithType: result)
            // sort by the children first, then the key
            outlineItems.sort { item1, item2 in
                if item1.children != nil && item2.children == nil {
                    return true
                } else {
                    return item1.key ?? "" < item2.key ?? ""
                }
            }
            
            callback(outlineItems)
        }
        
    }
    
    func getKeyMetaData(clientName: String, key: String, callback: @escaping (RedisItemDetailViewModel) -> Void) -> Void {
        guard let client = redisClients[clientName] else {
            callback(RedisItemDetailViewModel(key: "empty", ttl: "test", memory: "test", type: .None, value: .String("none")))
            return
        }
        client.getKeyMetaData(key:key).whenSuccess { value in
            callback(value)
        }
    }
    
    func save(clientName: String, key: String, value: RedisValue, callback: @escaping () -> Void) -> Void {
        guard let client = redisClients[clientName] else {
            callback()
            return
        }
        
        client.save(key: key, redisValue: value).whenSuccess { _ in
            callback()
        }
        
    }
    
    func listAddItem(clientName: String, key: String, items: [String], direction: ListPushDirection, callback: @escaping (Int) -> Void) -> Void {
        
        guard let client = redisClients[clientName] else {
            callback(-1)
            return
        }
        client.listAddItem(key: key, items: items, direction: direction).whenSuccess { value in
            callback(value)
        }
    }
    
    private func convertKeysToRedisOutlineItem(keysWithType: [(String, String)], isRawKey: Bool = false) -> [RedisOutlineItem] {
        
        var items = [RedisOutlineItem]()
        if (isRawKey) {
            // TODO: add the item as the raw key, so all the children will be nil
            for keyTypes in keysWithType {
                let item = RedisOutlineItem(key: keyTypes.0, label: keyTypes.0, type: .fromString(keyTypes.1), children: nil)
                items.append(item)
            }
            return items
        }
        items = createOutlineItems(from: keysWithType)
        return items
    }
    
    
    private func createOutlineItems(from inputs: [(String, String)]) -> [RedisOutlineItem] {
        var rootItems: [RedisOutlineItem] = []
        for input in inputs {
            let key = input.0
            let keyType = input.1
            let parts = key.split(separator: ":").map { String($0) }
            addParts(parts, to: &rootItems, fullKey: key, keyType: keyType)
        }
        
        return rootItems
    }
    
    private func addParts(_ parts: [String], to items: inout [RedisOutlineItem], fullKey: String, keyType: String) {
        guard !parts.isEmpty else { return }
        
        let label = parts[0]
        let remainingParts = Array(parts.dropFirst())
        
        if let existingItemIndex = items.firstIndex(where: { $0.label == label && $0.key == nil}) {
            if !remainingParts.isEmpty {
                var existingItem = items[existingItemIndex]
                var newChildren = existingItem.children ?? []
                addParts(remainingParts, to: &newChildren, fullKey: fullKey, keyType: keyType)
                existingItem.children = newChildren
                items[existingItemIndex] = existingItem
            } else {
                let newItem = RedisOutlineItem(key: fullKey, label: label, type: .fromString(keyType), children: nil)
                items.append(newItem)
            }
        } else {
            let newItem: RedisOutlineItem
            if remainingParts.isEmpty {
                newItem = RedisOutlineItem(key: fullKey, label: label, type: .fromString(keyType), children: nil)
            } else {
                var children: [RedisOutlineItem] = []
                addParts(remainingParts, to: &children, fullKey: fullKey, keyType: keyType)
                newItem = RedisOutlineItem(key: nil, label: label, type: .fromString(keyType), children: children)
            }
            items.append(newItem)
        }
    }
    
}
