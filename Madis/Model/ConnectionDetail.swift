//
//  ConnectionDetail.swift
//  Madis
//
//  Created by Jack Lin on 2024/6/24.
//

import Foundation
import SwiftData

@Model
class ConnectionDetail: Identifiable, Hashable {
    
    var id: String
    @Attribute(.unique)
    var name: String = ""
    var host: String = "127.0.0.1"
    var port: String = "6379"
    var username: String?
    var password: String?
    
    init() {
        self.id = UUID().uuidString
    }
    
    init(name: String, host: String, port: String, username: String?, password: String?) {
        self.id = UUID().uuidString
        self.name = name
        self.host = host
        self.port = port
        self.username = username
        self.password = password
    }
}
