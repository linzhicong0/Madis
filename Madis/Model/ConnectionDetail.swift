//
//  ConnectionDetail.swift
//  Madis
//
//  Created by Jack Lin on 2024/6/24.
//

import Foundation
import SwiftData

//@Model
//class ConnectionDetailList: Identifiable, Hashable {
//    @Attribute(.unique)
//    var id = UUID()
//    
//    @Relationship(deleteRule:.cascade)
//    var connections = [ConnectionDetail]()
//    
//    init() {}
//}

@Model
class ConnectionDetail: Identifiable, Hashable {
    
    var id: String
    @Attribute(.unique)
    var name: String
    var host: String
    var port: String
    var username: String
    var password: String
    
    init(name: String, host: String, port: String, username: String, password: String) {
        self.id = UUID().uuidString
        self.name = name
        self.host = host
        self.port = port
        self.username = username
        self.password = password
    }
}
