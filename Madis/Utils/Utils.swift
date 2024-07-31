//
//  Utils.swift
//  Madis
//
//  Created by Jack Lin on 2024/7/31.
//

import Foundation

class Uitls{
    public static func formatStreamValuesToString(values: [(key: String, value: String)]) -> String {
        var result = "{\n"
        let length = values.count
        for i in 0..<values.count {
            result.append("\t\"\(values[i].key)\": \"\(values[i].value)\"")
            if i != length - 1 {
                result.append(",\n")
            } else {
                result.append("\n")
            }
        }
        result.append("}")
        return result
    }
}
