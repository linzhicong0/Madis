//
//  Utils.swift
//  Madis
//
//  Created by Jack Lin on 2024/7/31.
//

import Foundation
import SwiftUI

class Utils {
    public static func formatStreamValuesToString(values: [StreamField]) -> String {
        var result = "{\n"
        let length = values.count
        for i in 0..<values.count {
            result.append("\t\"\(values[i].name)\": \"\(values[i].value)\"")
            if i != length - 1 {
                result.append(",\n")
            } else {
                result.append("\n")
            }
        }
        result.append("}")
        return result
    }

    public static func showDeleteItemSuccessMessage(appViewModel: AppViewModel) {
        appViewModel.floatingMessage = "Successfully deleted item."
        appViewModel.floatingMessageType = .success
        withAnimation(.easeInOut(duration: 0.3)) {
            appViewModel.showFloatingMessage = true
        }
    }
    public static func showSuccessMessage(appViewModel: AppViewModel, message: String) {
        appViewModel.floatingMessage = message
        appViewModel.floatingMessageType = .success
        withAnimation(.easeInOut(duration: 0.3)) {
            appViewModel.showFloatingMessage = true
        }
    }
    public static func showErrorMessage(appViewModel: AppViewModel, message: String) {
        appViewModel.floatingMessage = message
        appViewModel.floatingMessageType = .error
        withAnimation(.easeInOut(duration: 0.3)) {
            appViewModel.showFloatingMessage = true
        }
    }  
    public static func showWarningMessage(appViewModel: AppViewModel, message: String) {
        appViewModel.floatingMessage = message
        appViewModel.floatingMessageType = .warning
        withAnimation(.easeInOut(duration: 0.3)) {
            appViewModel.showFloatingMessage = true
        }
    }   
}
