//
//  AppViewModel.swift
//  Madis
//
//  Created by Jack Lin on 2024/5/6.
//

import Foundation


@Observable
class AppViewModel {
    var selectedTab: String = "connection"
    
    var connections: [Connection] = 
    [
        Connection(name: "My Local Connection", host: "127.0.0.1", port: "6379", username: "jack", password: "test"),
        Connection(name: "My Local Connection1", host: "127.0.0.2", port: "6379", username: "jack1", password: "test1"),
        Connection(name: "My Local Connection1", host: "127.0.0.2", port: "6379", username: "jack1", password: "test1"),
        Connection(name: "My Local Connection1", host: "127.0.0.2", port: "6379", username: "jack1", password: "test1"),
        Connection(name: "My Local Connection1", host: "127.0.0.2", port: "6379", username: "jack1", password: "test1"),
        Connection(name: "My Local Connection1", host: "127.0.0.2", port: "6379", username: "jack1", password: "test1"),
        Connection(name: "My Local Connection1", host: "127.0.0.2", port: "6379", username: "jack1", password: "test1"),
        Connection(name: "My Local Connection1", host: "127.0.0.2", port: "6379", username: "jack1", password: "test1"),
    ]
    
}
