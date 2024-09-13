//
//  RedisClient.swift
//  Madis
//
//  Created by Jack Lin on 2024/6/17.
//

import Foundation
import RediStack
import NIOCore
import NIOPosix

public class RedisClient {
    
    private let connection: RedisConnection
    private let eventLoop: EventLoop
    private let cursor: Int = 0
    private let database: Int = 0
    
    public init(host: String, port: Int = 6379, password: String?, initDatabase: Int?, eventLoop: EventLoop) throws {
        self.eventLoop = eventLoop
        self.connection = try RedisConnection.make(
            configuration: try .init(hostname: host, port: port, password: password, initialDatabase: initDatabase),
            boundEventLoop: eventLoop
        ).wait()
    }
    
    public init(host: String, port: Int, username: String?, password: String?, initDatabase: Int?, eventLoop: EventLoop) throws {
        self.eventLoop = eventLoop
        let address = try SocketAddress.init(ipAddress: host, port: port)
        self.connection = try RedisConnection.make(
            configuration: try .init(address: address, username: username, password: password, initialDatabase:  initDatabase),
            boundEventLoop: eventLoop
        ).wait()
    }
    
    deinit {
        if(self.connection.isConnected) {
            self.connection.close()
        }
    }
    
    public func closeConnection() {
        self.connection.close()
    }
    
    public static func testConnection(host: String, port: Int, password: String?, initDatabase: Int?, eventLoop: EventLoop) ->  Bool {
        
        let testConnection = try? RedisConnection.make(
            configuration: try .init(hostname: host, port: port, password: password, initialDatabase: initDatabase),
            boundEventLoop: eventLoop
        ).wait()
        
        // TODO: Do I need to check if connection.isConnected?
        if (testConnection == nil) {
            return false
        }
        testConnection!.close()
        return true
    }
    public static func testConnection(host: String, port: Int, username: String?, password: String?, initDatabase: Int?, eventLoop: EventLoop) -> Bool {
        
        let address = try! SocketAddress.init(ipAddress: host, port: port)
        let testConnection = try? RedisConnection.make(
            configuration: try .init(address: address, username: username, password: password, initialDatabase:  initDatabase),
            boundEventLoop: eventLoop
        ).wait()
        
        
        // TODO: Do I need to check if connection.isConnected?
        if (testConnection == nil) {
            return false
        }
        testConnection!.close()
        
        return true
        
    }
    public static func testConnection(host: String, port: Int, username: String?, password: String?, initDatabase: Int?, eventLoop: EventLoop) -> EventLoopFuture<Bool> {
        
        //        let promise = eventLoop.next().makePromise(of: Bool.self)
        
        let address = try! SocketAddress.init(ipAddress: host, port: port)
        //        let testConnection = try? RedisConnection.make(
        //            configuration: try .init(address: address, username: username, password: password, initialDatabase:  initDatabase),
        //            boundEventLoop: eventLoop
        //        ).whenComplete({ result in
        //            switch result {
        //            case .success(let conn):
        //                conn.close()
        //                promise.succeed(true)
        //            case .failure(let err):
        //                promise.fail(err)
        //            }
        //        })
        //        return promise.futureResult
        
        let testConnection = try? RedisConnection.make(
            configuration: try .init(address: address, username: username, password: password, initialDatabase:  initDatabase),
            boundEventLoop: eventLoop
        ).map({ conn in
            return conn.isConnected
        })
        return testConnection!
        
    }
    
    // Get all the keys from redis server
    public func getAllKeys() -> EventLoopFuture<[String]> {
        
        let promise = eventLoop.next().makePromise(of: [String].self)
        
        let keysFuture = self.connection.send(command: "KEYS", with: [.bulkString(stringToByteBuffer("*"))])
        keysFuture.whenComplete { result in
            switch result {
            case .success(let keys):
                // keys should be an array of RESPValue, convert each to string and print
                if let keysArray = keys.array {
                    let keyStrings = keysArray.compactMap { $0.string }
                    promise.succeed(keyStrings)
                } else {
                    print("No keys found")
                }
            case .failure(let error):
                print("Error fetching keys: \(error)")
                promise.fail(error)
            }
        }
        
        return promise.futureResult
        
    }
    /// Get a list of tuple, consit of (redisKey, redisType)
    /// - returns: a tuple of (redisKey, redisType)
    public func getAllKeysWithType() -> EventLoopFuture<[(String, String)]> {
        
        // Get all the keys
        let keysFuture = self.connection.send(command: "KEYS", with: [.bulkString(self.stringToByteBuffer("*"))])
        
        // Loop all the keys and get the type of each key
        return keysFuture.flatMap { resp in
            if let keysArray = resp.array {
                let keyStrings = keysArray.compactMap { $0.string }
                self.connection.sendCommandsImmediately = false
                let keyTypeFutures = keyStrings.map { key in
                    self.connection.send(command: "TYPE", with: [.bulkString(self.stringToByteBuffer(key))])
                        .map { type in
                            return (key, type.string ?? "")
                        }
                }
                self.connection.sendCommandsImmediately = true
                return EventLoopFuture.whenAllSucceed(keyTypeFutures, on: self.eventLoop)
            } else {
                print("No keys found")
                return self.eventLoop.makeSucceededFuture([])
            }
        }
    }
    
    // Get the details of the given key
    // Including the type, ttl, memory and the value
    func getKeyMetaData(key: String) -> EventLoopFuture<RedisItemDetailViewModel> {
        return getType(key: key)
            .flatMap { redisType in
                self.connection.sendCommandsImmediately = false
                let ttlFuture = self.getTTL(key: key)
                let memoryUsageFuture = self.getMemoryUsage(key: key)
                self.connection.sendCommandsImmediately = true
                return EventLoopFuture.whenAllComplete([ttlFuture, memoryUsageFuture], on: self.eventLoop)
                    .flatMap { result in
                        let viewModel = RedisItemDetailViewModel(key: key, ttl: try! result[0].get(), memory:try! result[1].get(), type: redisType, value: .None)
                        return self.eventLoop.makeSucceededFuture(viewModel)
                    }
            }
            .flatMap { value in
                return self.getRedisValue(key: key, type: value.type)
                    .map { redisValue in
                        var viewModel = value
                        viewModel.value = redisValue
                        return viewModel
                    }
            }.flatMapError { error in
                return self.eventLoop.makeFailedFuture(error)
            }
    }
    
    func save(key: String, redisValue: RedisValue) -> EventLoopFuture<Void> {
        switch redisValue {
        case .String(let value):
            return self.connection.set(RedisKey(key), to: value)
        default:
            return self.eventLoop.makeSucceededVoidFuture()
        }
    }
    
    func listAddItem(key: String, items: [String], direction: ListPushDirection) -> EventLoopFuture<Int> {
        switch direction {
        case .start:
            return self.connection.lpush(items, into: .init(key))
        case .end:
            return self.connection.rpush(items, into: .init(key))
        }
    }
    
    func listRemoveItemAt(key: String, index: Int) -> EventLoopFuture<Int>{
        return self.connection.lset(index: index, to: MADIS_DELETE_PLACEHOLDER, in: .init(key))
            .flatMap { _ in
                return self.connection.lrem(MADIS_DELETE_PLACEHOLDER, from: .init(key))
            }
    }
    
    func listModifyItemAt(key: String, index: Int, to: String) -> EventLoopFuture<Void> {
        return self.connection.lset(index: index, to: to, in: .init(key))
    }
    
    func setAddItems(key: String, items: [String]) -> EventLoopFuture<Int> {
        return self.connection.sadd(items, to: .init(key))
    }
    
    func setRemoveItem(key: String, item: String) -> EventLoopFuture<Int> {
        return self.connection.srem(item, from: .init(key))
    }
    
    // Modify an item
    // Since the set does not support modify an item directly
    // So we need to remove the given item, and add the new item into the Set
    func setModifyItem(key: String, item: String, newItem: String) -> EventLoopFuture<Int> {
        let key: RedisKey = .init(key)
        return self.connection.srem(item, from: key)
            .flatMap { _ in
                return self.connection.sadd(newItem, to: key)
            }
    }
    
    // This function can set or update a field
    func hashSetFields(key: String, fields: [String: String]) -> EventLoopFuture<Void> {
        self.connection.sendCommandsImmediately = false
        let key = RedisKey(key)
        
        let futures = fields.map { (field, value) in
            self.connection.hset(field, to: value, in: key)
        }
        
        self.connection.sendCommandsImmediately = true
        
        return EventLoopFuture.whenAllComplete(futures, on: self.eventLoop)
            .flatMap { _ in
                return self.eventLoop.makeSucceededVoidFuture()
            }
    }
    
    /// Sets multiple fields in a Redis hash, but only if they don't already exist.
    /// - Parameters:
    ///   - key: The key of the hash in Redis.
    ///   - fields: A dictionary where the keys are field names and the values are the corresponding values to set.
    /// - Returns: An `EventLoopFuture` that resolves to a dictionary. The keys are the field names, and the values are booleans indicating whether each field was set (true) or already existed (false).
    func hashSetFieldsIfNotExist(key: String, fields: [String: String]) -> EventLoopFuture<Bool> {
        let redisKey = RedisKey(key)
        self.connection.sendCommandsImmediately = false
        let futures = fields.map { field, value in
            self.connection.hsetnx(field, to: value, in: redisKey)
        }
        self.connection.sendCommandsImmediately = true
        return EventLoopFuture.whenAllComplete(futures, on: self.eventLoop)
            .flatMap { results in
                self.eventLoop.makeSucceededFuture(results.allSatisfy { result in
                    (try? result.get()) ?? false
                })
            }
    }
    /// Removes a field from a Redis hash and replaces it with a new field.
    /// - Parameters:
    ///   - key: The key of the hash in Redis.
    ///   - previousField: The field to remove from the hash.
    ///   - field: The new field to add to the hash.
    ///   - value: The value to associate with the new field.
    /// - Returns: An `EventLoopFuture` that resolves to a boolean indicating success (true) or failure (false).
    func hashReplaceField(key: String, previousField: String, field: String, value: String) -> EventLoopFuture<Bool> {
        let redisKey = RedisKey(key)
        return self.connection.hdel(previousField, from: redisKey)
            .flatMap { _ in
                return self.connection.hset(field, to: value, in: redisKey)
            }
    }
    /// Removes a field from a Redis hash.
    /// - Parameters:
    ///   - key: The key of the hash in Redis.
    ///   - field: The field to remove from the hash.
    /// - Returns: An `EventLoopFuture` that resolves to an `Int` representing the number of fields that were removed (0 if the field did not exist, 1 if it was removed successfully).
    func hashRemoveField(key: String, field: String) -> EventLoopFuture<Int> {
        return self.connection.hdel(field, from: .init(key))
        
    }
    
    func zsetAddItems(key: String, items: [(element: String, score: Double)], replace: Bool) -> EventLoopFuture<Int> {
        return self.connection.zadd(items, to: RedisKey(key), inserting: replace ? .allElements : .onlyNewElements)
    }
    func zsetRemoveItem(key: String, item: String) -> EventLoopFuture<Int> {
        return self.connection.zrem(item, from: RedisKey(key))
    }
    /// Adds a new item to a Redis stream.
    /// - Parameters:
    ///   - key: The key of the stream in Redis.
    ///   - id: The ID of the new stream entry. Use "*" to let Redis generate an ID.
    ///   - fields: A dictionary where the keys are field names and the values are the corresponding values to set.
    /// - Returns: An `EventLoopFuture` that resolves to the ID of the added stream entry.
    func streamAddItem(key: String, id: String, fields: [String: String]) -> EventLoopFuture<String> {
        let fieldValues = fields.flatMap { [$0.key, $0.value] }
        return self.connection.send(command: "XADD", with: [.bulkString(self.stringToByteBuffer(key)), .bulkString(self.stringToByteBuffer(id))] + fieldValues.map { .bulkString(self.stringToByteBuffer($0)) })
            .map { response in
                return response.string ?? ""
            }
    }
    
    /// Removes an item from a Redis stream.
    /// - Parameters:
    ///   - key: The key of the stream in Redis.
    ///   - id: The ID of the stream entry to remove.
    /// - Returns: An `EventLoopFuture` that resolves to a boolean indicating success (true) or failure (false).
    func streamRemoveItem(key: String, id: String) -> EventLoopFuture<Bool> {
        return self.connection.send(command: "XDEL", with: [.bulkString(self.stringToByteBuffer(key)), .bulkString(self.stringToByteBuffer(id))])
            .map { response in
                return response.int == 1
            }
    }


    func setTTL(key: String, ttl: Int64) -> EventLoopFuture<Bool> {
        if ttl < 0 {
            return self.connection.send(command: "PERSIST", with: [.bulkString(self.stringToByteBuffer(key))])
                .map { response in
                    return response.int == 1
                }
        } else {
            return self.connection.expire(RedisKey(key), after: .seconds(ttl))
        }
    }
    
    private func stringToByteBuffer(_ string: String) -> ByteBuffer {
        return ByteBufferAllocator().buffer(string: string)
    }
    
    private func getRedisValue(key: String, type: RedisType) -> EventLoopFuture<RedisValue> {
        switch type {
        case .String:
            return self.connection.get(RedisKey(key)).map { value in
                if let value = value.string {
                    return .String(value)
                } else {
                    return .String("")
                }
            }
            .flatMapError { error in
                self.eventLoop.makeFailedFuture(error)
            }
        case .List:
            return self.connection.lrange(from: RedisKey(key), upToIndex: 2999).map { value in
                return .List(value.map { $0.string ?? "" })
            }.flatMapError { error in
                self.eventLoop.makeFailedFuture(error)
            }
        case .Set:
            return self.connection.sscan(RedisKey(key), startingFrom: 0, count: 3000).map { (cursor, value) in
                return .Set(value.map { $0.string ?? "" })
            }.flatMapError { error in
                self.eventLoop.makeFailedFuture(error)
            }
        case .Hash:
            return self.connection.hscan(RedisKey(key), startingFrom: 0, matching: "*").map { (cursor, value) in
                return .Hash(value.mapValues{ $0.string ?? ""})
            }
        case .ZSet:
            return self.connection.zrange(from: RedisKey(key), indices: 0..<2999, includeScoresInResponse: true).map { values in
                var elements: [ZSetItem] = []
                for i in stride(from: 0, to: values.count, by: 2) {
                    elements.append((element: values[i].string!, score: Double(values[i+1].string!)!))
                }
                return .ZSet(elements)
            }
        case .Stream:
            return self.connection.send(command: "XREVRANGE", with: [.bulkString(self.stringToByteBuffer(key)),
                                                                     .bulkString(self.stringToByteBuffer("+")),
                                                                     .bulkString(self.stringToByteBuffer("-")),
                                                                     .bulkString(self.stringToByteBuffer("count")),
                                                                     .bulkString(self.stringToByteBuffer("2999")),
            ]).map { value in
                return self.parseStreamFromRESPValue(respValue: value)
            }
            // case .None:
        default:
            return self.eventLoop.makeSucceededFuture(.String(""))
        }
    }
    
    // Get the type of the given key
    private func getType(key: String) -> EventLoopFuture<RedisType> {
        return self.connection.send(command: "TYPE", with: [.bulkString(self.stringToByteBuffer(key))]).flatMap { value in
            if let typeString = value.string {
                return self.eventLoop.makeSucceededFuture(.fromString(typeString))
            } else {
                return self.eventLoop.makeFailedFuture(RedisError.init(reason: "Unknown key type:\(String(describing: value.string))"))
            }
        }
    }
    
    // Get the TTL of the given key
    private func getTTL(key: String) -> EventLoopFuture<String> {
        return self.connection.ttl(RedisKey(key)).flatMap { value in
            var ttl = "INFINITY"
            if let t = value.timeAmount {
                ttl = self.formatTTL(Int64(t.nanoseconds/1_000_000_000))
            }
            return self.eventLoop.makeSucceededFuture(ttl)
        }
    }
    
    private func formatTTL(_ ttl: Int64) -> String {
        if ttl <= 0 {
            return "Infinite"
        }
        
        let day = ttl / 86400
        let hour = (ttl % 86400) / 3600
        let minute = (ttl % 3600) / 60
        let second = ttl % 60
        
        if day > 0 {
            return String(format: "%dd %02dh %02dm %02ds", day, hour, minute, second)
        } else if hour > 0 {
            return String(format: "%dh %02dm %02ds", hour, minute, second)
        } else if minute > 0 {
            return String(format: "%dm %02ds", minute, second)
        } else {
            return String(format: "%ds", second)
        }
    }
    
    // Get the memory usage of the given key
    private func getMemoryUsage(key: String) -> EventLoopFuture<String> {
        return self.connection.send(command: "MEMORY", with: [.bulkString(self.stringToByteBuffer("USAGE")),.bulkString(self.stringToByteBuffer(key))]).flatMap { value in
            var memory = "0"
            if let m = value.int {
                memory = "\(m) bytes"
            }
            return self.eventLoop.makeSucceededFuture(memory)
        }
    }
    
    private func parseStreamFromRESPValue(respValue: RESPValue) -> RedisValue {
        // example: [[1722128454840-0,[e,f,g,h]],[1722127845727-0,[c,d]],[1722126902273-0,[a,b]]]
        var streamElements: [StreamElement] = []
        if let array = respValue.array {
            for value in array {
                // [1722128454840-0,[e,f,g,h]]
                //                var elements: [[String: String]] = []
                var elements: [(key:String, value: String)] = []
                let id = value.array![0].string!
                let values = value.array![1].array
                for i in stride(from: 0, to: values!.count, by: 2) {
                    let key = values![i].string!
                    let value = values![i+1].string!
                    //                    elements.append([key : value])
                    elements.append((key: key, value: value))
                }
                streamElements.append(StreamElement(id: id, values: elements))
            }
        }
        return .Stream(streamElements)
        
    }
}
