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
    
    func addRedisClient(name: String, config: RedisConnectionDetail) throws {
        // return if the name exist
        if redisClients.keys.contains(name) {
            return
        }
        
        let newClient = try RedisClient(host: config.host, port: config.port, password: config.password, initDatabase: 0, eventLoop: eventLoop  )
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
//    func getAllKeys(name: String) -> [String] {
//        
//        guard let client = redisClients[name] else {
//            return []
//        }
//        
//
//    }
}
