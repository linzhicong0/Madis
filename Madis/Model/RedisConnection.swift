//
//  RedisConnection.swift
//  Madis
//
//  Created by Jack Lin on 2024/4/29.
//

import Foundation


class RedisConnection: ObservableObject, Identifiable, Hashable {
    static func == (lhs: RedisConnection, rhs: RedisConnection) -> Bool {
        return lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    let id = UUID()
    @Published var name: String
    @Published var host: String
    @Published var port: String
    @Published var userName: String
    @Published var password: String
    @Published var timeout: String
    
    init(name: String, host: String, port: String, userName: String, password: String, timeout: String) {
        self.name = name
        self.host = host
        self.port = port
        self.userName = userName
        self.password = password
        self.timeout = timeout
    }
    
    
}
