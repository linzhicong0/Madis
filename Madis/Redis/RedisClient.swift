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
    
    public func getAllKeys() -> EventLoopFuture<[String]> {
        
        let promise = eventLoop.next().makePromise(of: [String].self)
        
        let keysFuture = self.connection.send(command: "KEYS", with: [.bulkString(stringToByteBuffer("*"))])
        keysFuture.whenComplete { result in
            switch result {
            case .success(let keys):
                // keys should be an array of RESPValue, convert each to string and print
                if let keysArray = keys.array {
                    let keyStrings = keysArray.compactMap { $0.string }
                    print("Keys: \(keyStrings)")
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
    
    func getKeyMetaData(key: String) -> EventLoopFuture<RedisItemDetailViewModel> {
        let promise = eventLoop.next().makePromise(of: RedisItemDetailViewModel.self)
        // set the sendCommandsImmediately to false to make it as the pipeline
        // not sure if this is the pipeline handle using the RediStack
        self.connection.sendCommandsImmediately = false
        let ttlFuture = self.connection.ttl(RedisKey(key)).flatMap { value in
            var ttl = "INFINITY"
            if let t = value.timeAmount {
                ttl = "\(t.nanoseconds/1_000_000_000) s"
            }
            return self.eventLoop.next().makeSucceededFuture(ttl)
        }
        let memoryUsageFuture = self.connection.send(command: "MEMORY", with: [.bulkString(stringToByteBuffer("USAGE")),.bulkString(stringToByteBuffer(key))]).flatMap { value in
            var memory = "0"
            if let m = value.int {
                memory = "\(m) bytes"
            }
            return self.eventLoop.next().makeSucceededFuture(memory)
        }
        
        self.connection.sendCommandsImmediately = true
        
        EventLoopFuture.whenAllComplete([ttlFuture, memoryUsageFuture], on: eventLoop.next()).whenComplete { result in
            switch result {
            case .success(let values):
                print(values)
                promise.succeed(RedisItemDetailViewModel(key: key, ttl: try! values[0].get(), memory: try! values[1].get()))
            case .failure(let error):
                print("Error fetching key: \(error)")
                promise.fail(error)
            }
            
        }
        
        return promise.futureResult
        
    }
    public func getString(_ key: String) -> EventLoopFuture<String> {
        
        let promise = eventLoop.next().makePromise(of: String.self)
        
        let future = self.connection.get(RedisKey(key))
        future.whenComplete { result in
            switch result {
            case .success(let value):
                if let value = value.string {
                    promise.succeed(value)
                } else {
                    print("key not found!")
                }
            case .failure(let error):
                print("Error fetching key: \(error)")
                promise.fail(error)
            }
        }
        return promise.futureResult
    }
    
    private func stringToByteBuffer(_ string: String) -> ByteBuffer {
        return ByteBufferAllocator().buffer(string: string)
    }
}
