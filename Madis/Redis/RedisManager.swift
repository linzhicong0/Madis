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
    
    var redisClients: [ConnectionDetail:RedisClient] = [:]
    private let eventLoop: EventLoop = NIOSingletons.posixEventLoopGroup.any()
    
    private init() {
    }
    
    func addRedisClient(config: ConnectionDetail) throws {
        // return if the name exist
        if redisClients.keys.contains(config) {
            return
        }
        
        let newClient = try RedisClient(host: config.host, port: Int(config.port)!, password: config.password == "" ? nil : config.password, initDatabase: 0, eventLoop: eventLoop  )
        redisClients[config] = newClient
        
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
    
    func getAllKeysWithType(config: ConnectionDetail, callback: @escaping ((Int, [RedisOutlineItem])) -> Void) -> Void {
        guard let client = redisClients[config] else {
            callback((0, []))
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
            
            callback((result.count, outlineItems))
        }
        
    }
    
    func getKeyMetaData(config: ConnectionDetail, key: String, callback: @escaping (RedisItemDetailViewModel) -> Void) -> Void {
        guard let client = redisClients[config] else {
            callback(RedisItemDetailViewModel(key: "empty", ttl: "test", memory: "test", type: .None, value: .String("none")))
            return
        }
        client.getKeyMetaData(key:key).whenSuccess { value in
            callback(value)
        }
    }
    
    func save(config: ConnectionDetail, key: String, value: RedisValue, callback: @escaping () -> Void) -> Void {
        guard let client = redisClients[config] else {
            callback()
            return
        }
        
        client.save(key: key, redisValue: value).whenSuccess { _ in
            callback()
        }
        
    }
    
    func listAddItem(config: ConnectionDetail, key: String, items: [String], direction: ListPushDirection, callback: @escaping (Int) -> Void) -> Void {
        
        guard let client = redisClients[config] else {
            callback(-1)
            return
        }
        client.listAddItem(key: key, items: items, direction: direction).whenSuccess { value in
            callback(value)
        }
    }
    
    func listRemoveItemAt(config: ConnectionDetail, key: String, index: Int, callback: @escaping (Int) -> Void) {
        guard let client = redisClients[config] else {
            callback(-1)
            return
        }
        client.listRemoveItemAt(key: key, index: index).whenSuccess { value in
            callback(value)
        }
    }
    
    func listModifyItemAt(config: ConnectionDetail, key: String, index: Int, to: String, callback: @escaping () -> Void) {
        guard let client = redisClients[config] else {
            callback()
            return
        }
        client.listModifyItemAt(key: key, index: index, to: to).whenSuccess {
            callback()
        }
    }
    
    func setAddItems(config: ConnectionDetail, key: String, items: [String], callback: @escaping (Int)-> Void) {
        guard let client = redisClients[config] else {
            callback(-1)
            return
        }
        
        client.setAddItems(key: key, items: items).whenSuccess { value in
            callback(value)
        }
        
    }
    
    func setRemoveItem(config: ConnectionDetail, key: String, item: String, callback: @escaping () -> Void) {
        guard let client = redisClients[config] else {
            callback()
            return
        }
        
        client.setRemoveItem(key: key, item: item).whenSuccess { _ in
            callback()
        }
    }
    
    func setModifyItem(config: ConnectionDetail, key: String, item: String, newItem: String, callback: @escaping ()-> Void) {
        
        guard let client = redisClients[config] else {
            callback()
            return
        }
        
        client.setModifyItem(key: key, item: item, newItem: newItem).whenSuccess { _ in
            callback()
        }
    }
    
    func hashSetFields(config: ConnectionDetail, key: String, fields: [String: String], callback: @escaping (Bool) -> Void) {
        
        guard let client = redisClients[config] else {
            callback(false)
            return
        }
        
        client.hashSetFields(key: key, fields: fields).whenComplete { result in
            switch result {
            case .success:
                callback(true)
            case .failure:
                callback(false)
            }
        }
        
    }

    func hashSetFieldsIfNotExist(config: ConnectionDetail, key: String, fields: [String: String], callback: @escaping (Bool) -> Void) {
        guard let client = redisClients[config] else {
            callback(false)
            return
        }
        
        client.hashSetFieldsIfNotExist(key: key, fields: fields).whenComplete { result in
            switch result {
            case .success(let value):
                callback(value)
            case .failure(_):
                callback(false)
            }
        }
    }
    
    func hashRemoveField(config: ConnectionDetail, key: String, field: String, callback: @escaping (Int) -> Void){
        guard let client = redisClients[config] else {
            callback(-1)
            return
        }
        
        client.hashRemoveField(key: key, field: field).whenSuccess { value in
            callback(value)
        }
    }

    func hashReplaceField(config: ConnectionDetail, key: String, previousField: String, field: String, value: String, callback: @escaping (Bool) -> Void) {
        guard let client = redisClients[config] else {
            callback(false)
            return
        }
        
        client.hashReplaceField(key: key, previousField: previousField, field: field, value: value).whenComplete { result in
            switch result {
            case .success(_):
                callback(true)
            case .failure(_):
                callback(false)
            }
        }
    }
    func zsetAdd(config: ConnectionDetail, key: String, items: [ZSetItem], replace: Bool, callback: @escaping (Bool) -> Void) {
        guard let client = redisClients[config] else {
            callback(false)
            return
        }
        // Convert ZSetItem list to list of tuples
        let itemTuples = items.map { ($0.element, $0.score) }
        
        client.zsetAddItems(key: key, items: itemTuples, replace: replace).whenComplete { result in
            switch result {
            case .success(_):
                callback(true)
            case .failure(_):
                callback(false)
            }
        }
    }
    func zsetRemoveItem(config: ConnectionDetail, key: String, item: String, callback: @escaping (Int) -> Void) {
        guard let client = redisClients[config] else {
            callback(0)
            return
        }
        
        client.zsetRemoveItem(key: key, item: item).whenComplete { result in
            switch result {
            case .success(let value):
                callback(value)
            case .failure(_):
                callback(-1)
            }
        }
    }
    

    func streamAdd(config: ConnectionDetail, key: String, id: String, fields: [String: String], callback: @escaping (Bool) -> Void) {
        guard let client = redisClients[config] else {
            callback(false)
            return
        }
        
        client.streamAddItem(key: key, id: id, fields: fields).whenComplete { result in
            switch result {
            case .success(_):
                callback(true)
            case .failure(_):
                callback(false)
            }
        }
    }

    /// Removes an item from a Redis stream.
    /// - Parameters:
    ///   - clientName: The name of the Redis client to use.
    ///   - key: The key of the stream in Redis.
    ///   - id: The ID of the stream entry to remove.
    ///   - callback: A closure that is called with a boolean indicating success (true) or failure (false).
    func streamRemoveItem(config: ConnectionDetail, key: String, id: String, callback: @escaping (Bool) -> Void) {
        guard let client = redisClients[config] else {
            callback(false)
            return
        }
        
        client.streamRemoveItem(key: key, id: id).whenComplete { result in
            switch result { 
            case .success(let value):
                callback(value)
            case .failure(_):
                callback(false)
            }
        }
    }   
    
    /// Sets the Time To Live (TTL) for a specified key in Redis.
    /// - Parameters:
    ///   - clientName: The name of the Redis client to use.
    ///   - key: The key for which to set the TTL.
    ///   - ttl: The TTL value in seconds.
    ///   - callback: A closure that is called with a boolean indicating success (true) or failure (false).
    func setTTL(config: ConnectionDetail, key: String, ttl: Int64, callback: @escaping (Bool) -> Void) {
        guard let client = redisClients[config] else {
            callback(false)
            return
        }
        
        client.setTTL(key: key, ttl: ttl).whenComplete { result in
            switch result {
            case .success(let success):
                callback(success)
            case .failure(_):
                callback(false)
            }
        }
    }

    func deleteKey(config: ConnectionDetail, key: String, callback: @escaping (Bool) -> Void) {
        guard let client = redisClients[config] else {
            callback(false)
            return
        }
        
        client.deleteKey(key: key).whenComplete { result in
            switch result { 
            case .success(let success):
                callback(success)
            case .failure(_):
                callback(false)
            }
        }
    }
    
    func setKey(config: ConnectionDetail, key: String, value: RedisValue, callback: @escaping (Bool) -> Void) {
        guard let client = redisClients[config] else {
            callback(false)
            return
        }

        switch value {
        case .String(let stringValue):
            client.save(key: key, redisValue: .String(stringValue)).whenComplete { _ in
                callback(true)
            }
        case .List(let listItems):
            client.listAddItem(key: key, items: listItems, direction: .end).whenComplete { _ in
                callback(true)
            }
        case .Set(let setItems):
            client.setAddItems(key: key, items: setItems).whenComplete { _ in
                callback(true)
            }
        case .Hash(let hashItems):
            let fields = Dictionary(uniqueKeysWithValues: hashItems.map { ($0.field, $0.value) })
            client.hashSet(key: key, fields: fields).whenComplete { _ in
                callback(true)
            }
        case .ZSet(let zsetItems):
            client.zsetAddItems(key: key, items: zsetItems.map { ($0.element, $0.score) }, replace: true).whenComplete { _ in
                callback(true)
            }
        case .Stream(let streamElements):
            // Assuming we're adding the first element of the stream
            if let firstElement = streamElements.first {
                let fields = Dictionary(uniqueKeysWithValues: firstElement.values.map { ($0.name, $0.value) })
                client.streamAddItem(key: key, id: "*", fields: fields).whenComplete { _ in
                    callback(true)
                }
            } else {
                callback(false)
            }
        case .None:
            callback(false)
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
