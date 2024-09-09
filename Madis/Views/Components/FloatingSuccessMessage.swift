//
//  FloatingSuccessMessage.swift
//  Madis
//
//  Created by Jack Lin on 2024/9/9.
//

import SwiftUI

struct FloatingMessage: ViewModifier {
    @Binding var isPresented: Bool
    let message: String
    let type: FloatingMessageType
    var duration: Double = 2.0

    func body(content: Content) -> some View {
        ZStack {
            content

            VStack {
                Spacer()
                if isPresented {
                    HStack {
                        Image(systemName: type.iconName)
                        Text(message)
                    }
                    .padding()
                    .background(type.backgroundColor.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .padding(.bottom, 30)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(1)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isPresented = false
                            }
                        }
                    }
                }
            }
        }
    }
}

extension View {
    func floatingMessage(isPresented: Binding<Bool>, message: String, type: FloatingMessageType, duration: Double = 3.0) -> some View {
        self.modifier(FloatingMessage(isPresented: isPresented, message: message, type: type, duration: duration))
    }
}
