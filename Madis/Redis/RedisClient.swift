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
                    //                    print("Keys: \(keyStrings)")
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
                        let viewModel = RedisItemDetailViewModel(key: key, ttl:try! result[0].get(), memory:try! result[1].get(), type: redisType, value: .None)
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
    func hashSetFields(key: String, fields: [String: String]) -> EventLoopFuture<Bool> {
        
        self.connection.sendCommandsImmediately = false
        let key =  RedisKey(key)
        
        var futures: [EventLoopFuture<Bool>] = []
        
        fields.forEach { (field: String, value: String) in
            futures.append(self.connection.hset(field, to: value, in: key))
        }
        self.connection.sendCommandsImmediately = true
        
        return EventLoopFuture.whenAllComplete(futures, on: self.eventLoop)
            .flatMap { result in
                
                var allSuccess = true
                result.forEach { value in
                    let value = try! value.get()
                    allSuccess = allSuccess && value
                }
                return self.eventLoop.makeSucceededFuture(allSuccess)
            }
    }
    
    func hashRemoveField(key: String, field: String) -> EventLoopFuture<Int> {
        return self.connection.hdel(field, from: .init(key))
        
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
                var elements: [SortedSetElement] = []
                for i in stride(from: 0, to: values.count, by: 2) {
                    elements.append((value: values[i].string!, score: Double(values[i+1].string!)!))
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
                ttl = "\(t.nanoseconds/1_000_000_000) s"
            }
            return self.eventLoop.makeSucceededFuture(ttl)
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
