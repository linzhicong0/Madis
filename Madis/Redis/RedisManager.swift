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
        
        let newClient = try RedisClient(host: config.host, port: Int(config.port)!, password: config.password, initDatabase: 0, eventLoop: eventLoop  )
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
    func getAllKeys(clientName: String, callback: @escaping ([RedisOutlineItem]) -> Void) -> Void {
        guard let client = redisClients[clientName] else {
            callback([])
            return
        }
        
        var outlineItems = [RedisOutlineItem]()
        client.getAllKeys().whenSuccess { keys in
            outlineItems = self.convertKeysToRedisOutlineItem(keys: keys)
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
            callback(RedisItemDetailViewModel(key: "empty", ttl: "test", memory: "test"))
            return
        }
        client.getKeyMetaData(key:key).whenSuccess { value in
            callback(value)
        }
    }

    private func convertKeysToRedisOutlineItem(keys: [String], isRawKey: Bool = false) -> [RedisOutlineItem] {
        
        var items = [RedisOutlineItem]()
        if (isRawKey) {
            // TODO: add the item as the raw key, so all the children will be nil
            for key in keys {
                let item = RedisOutlineItem(key: key, label: key, type: .String, children: nil)
                items.append(item)
            }
            return items
        }
        items = createOutlineItems(from: keys)
        return items
    }
    
    
    private func createOutlineItems(from inputs: [String]) -> [RedisOutlineItem] {
        var rootItems: [RedisOutlineItem] = []
        for input in inputs {
            let parts = input.split(separator: ":").map { String($0) }
            addParts(parts, to: &rootItems, fullKey: input)
        }
        
        return rootItems
    }
    
    private func addParts(_ parts: [String], to items: inout [RedisOutlineItem], fullKey: String) {
        guard !parts.isEmpty else { return }
        
        let label = parts[0]
        let remainingParts = Array(parts.dropFirst())
        
        if let existingItemIndex = items.firstIndex(where: { $0.label == label && $0.key == nil}) {
            if !remainingParts.isEmpty {
                var existingItem = items[existingItemIndex]
                var newChildren = existingItem.children ?? []
                addParts(remainingParts, to: &newChildren, fullKey: fullKey)
                existingItem.children = newChildren
                items[existingItemIndex] = existingItem
            } else {
                let newItem = RedisOutlineItem(key: fullKey, label: label, type: .String, children: nil)
                items.append(newItem)
            }
        } else {
            let newItem: RedisOutlineItem
            if remainingParts.isEmpty {
                newItem = RedisOutlineItem(key: fullKey, label: label, type: .String, children: nil)
            } else {
                var children: [RedisOutlineItem] = []
                addParts(remainingParts, to: &children, fullKey: fullKey)
                newItem = RedisOutlineItem(key: nil, label: label, type: .String, children: children)
            }
            items.append(newItem)
        }
    }
    
}
