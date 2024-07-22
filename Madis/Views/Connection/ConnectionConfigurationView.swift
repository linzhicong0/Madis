//
//  ConnectionConfigurationView.swift
//  Madis
//
//  Created by Jack Lin on 2024/5/9.
//

import SwiftUI
import NIOPosix
import NIOCore
import RediStack
import SwiftData

struct ConnectionConfigurationView: View {
    
    @Environment(\.appViewModel) private var appViewModel
    @Environment(\.modelContext) private var context
    
    @Binding var showDialog: Bool
    
    var isUpdate: Bool = false
    
    @State var connectionDetail: ConnectionDetail
    @State private var closeButtonHovering = false
    @State private var showConnectionResultDiaglog = false
    @State private var testConnectionPassed: Bool = false
    @State private var isTesting: Bool = false

    private let width: CGFloat = 400
    private let height: CGFloat = 400
    var body: some View {
        
        ZStack(alignment: .topLeading) {
            VStack(spacing: 20) {
                Text("\(isUpdate ? "Update" : "Create") Connection")
                    .font(.title)
                
                // Connection Name
                CustomFormInputView(title: "Connection Name", systemImage: "list.bullet.circle", placeholder: "connection name", text: $connectionDetail.name)
                
                // Connection host and port
                HStack() {
                    CustomFormInputView(title: "Host", systemImage: "house.circle",placeholder: "host" , text: $connectionDetail.host)
                    Text(":")
                        .font(.title)
                        .offset(y: 10)
                    CustomFormInputView(title: "Port", systemImage: "door.left.hand.closed", placeholder: "port", text: $connectionDetail.port)
                }
                HStack {
                    CustomFormInputView(title: "Username", systemImage: "person.crop.circle", placeholder: "username", text: $connectionDetail.username)
                    CustomFormInputView(title: "Password", systemImage: "key.horizontal.fill", isSecured: true, placeholder: "password", text: $connectionDetail.password)
                }
                
                Spacer()
                
                HStack {
                    Spacer()
                    Button(action: {
                        onTestConnectionButtonClicked()
                    }, label: {
                        Text("Test Connection")
                            .padding(5)
                            .foregroundStyle(.white)
                            .buttonStyle(.borderedProminent)
                    })
                    
                    Button(action: {
                        
                        showDialog = false
                    }, label: {
                        Text("Cancel")
                            .padding(5)
                            .foregroundStyle(.white)
                    })
                    .buttonStyle(.borderedProminent)
                    
                    Button( action: {
                        onCreateButtonClicked()
                    }, label: {
                        Text(isUpdate ? "Update" : "Create")
                            .padding(5)
                            .foregroundStyle(.white)
                    })
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding(15)
            .frame(width: width, height: height)
            .background(BlurView())
            .blur(radius: isTesting ? 3.0 : 0.0)
            
            if isTesting {
                Color.black
                    .opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                    }
                
                ProgressView {
                }
                .progressViewStyle(.circular)
                .frame(width: width, height: height)
                .backgroundStyle(.black )
                
            }
            // close button
            Button(action: {
                close()
            }, label: {
                ZStack {
                    Circle()
                        .foregroundStyle(.red)
                        .frame(width:14, height: 14)
                    
                    if(closeButtonHovering) {
                        Image(systemName: "xmark")
                            .font(.system(size: 8))
                            .bold()
                            .foregroundStyle(.black)
                    }
                }
            })
            .offset(x: 10, y: 10)
            .buttonStyle(PlainButtonStyle())
            .onHover(perform: { hovering in
                closeButtonHovering = hovering
            })
        }
        .sheet(isPresented: $showConnectionResultDiaglog, content: {
            TestConnectionSheetView(testConnectionPassed: $testConnectionPassed, showConnectionResultDiaglog: $showConnectionResultDiaglog)
        })
    }
    
    var testResultSheet: some View {
        print("sheet: \(testConnectionPassed)")
        return VStack(spacing: 30, content: {
            Image(systemName: testConnectionPassed ? "checkmark" : "xmark")
                .resizable()
                .foregroundStyle(testConnectionPassed ? .green : .red)
                .frame(width: 40, height: 40)
            Text(testConnectionPassed ? "Test passed!": "Test failed!")
                .font(.title2)
            Button(action: {
                showConnectionResultDiaglog.toggle()
            }, label: {
                Text("OK")
                    .foregroundStyle(.white)
                    .frame(width: 40)
            })
        })
        .frame(width: 300, height: 200)
    }
    
    private func close() {
        showDialog = false
    }
    
    private func onCreateButtonClicked() {
        if(isUpdate){
            try? context.save()
        } else {
            
            // check if the connection name already exist?
            // if exist then show an alert
            // else create it
            let name = connectionDetail.name
            var descriptor = FetchDescriptor<ConnectionDetail>(
                predicate: #Predicate { $0.name == name },
                sortBy: [
                    .init(\.id)]
            )
            descriptor.fetchLimit = 1
            let fetchResult = try! context.fetch(descriptor)
            
            if fetchResult.count != 0 {
                print("exist")
            } else {
                context.insert(connectionDetail)
            }
            
        }
        
        close()
        
    }
    
    private func onTestConnectionButtonClicked() {
        isTesting = true
        RedisManager.shared.testConnection(host: connectionDetail.host, port: Int(connectionDetail.port) ?? 6379, username: connectionDetail.username == "" ? nil : connectionDetail.username, password: connectionDetail.password == "" ? nil : connectionDetail.password).whenComplete { result in
            switch result{
            case .success(let result):
                testConnectionPassed = result
            case .failure(_):
                testConnectionPassed = false
            }
            showConnectionResultDiaglog = true
            isTesting = false
        }
    }
}

struct TestConnectionSheetView: View  {
    
    @Binding var testConnectionPassed: Bool
    @Binding var showConnectionResultDiaglog: Bool
    
    var body: some View{
        return VStack(spacing: 30, content: {
            Image(systemName: testConnectionPassed ? "checkmark" : "xmark")
                .resizable()
                .foregroundStyle(testConnectionPassed ? .green : .red)
                .frame(width: 40, height: 40)
            Text(testConnectionPassed ? "Test passed!": "Test failed!")
                .font(.title2)
            Button(action: {
                showConnectionResultDiaglog.toggle()
            }, label: {
                Text("OK")
                    .foregroundStyle(.white)
                    .frame(width: 40)
            })
        })
        .frame(width: 300, height: 200)
    }
}

#Preview {
    ConnectionConfigurationView(showDialog: .constant(true), connectionDetail: ConnectionDetail())
}

struct CustomFormInputView: View {
    
    var title: String
    var systemImage: String
    var isSecured: Bool = false
    var horizontalPadding: CGFloat = 4
    var verticalPadding: CGFloat = 5
    var placeholder: String?
    
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("\(title)")
                .font(.system(size: 14))
                .foregroundStyle(.white)
                .offset(x: 4)
            HStack {
                Image(systemName: systemImage)
                    .font(.system(size: 16))
                    .foregroundStyle(.white)
                
                if isSecured {
                    SecureField("\(placeholder?.description ?? "")", text: $text)
                        .textFieldStyle(.plain)
                        .font(.system(size: 16))
                }
                else {
                    TextField("\(placeholder?.description ?? "")", text: $text)
                        .textFieldStyle(.plain)
                        .font(.system(size: 16))
                }
            }
            .padding(.vertical, verticalPadding)
            .padding(.horizontal, horizontalPadding)
            .background(.primary.opacity(0.15))
            .clipShape(.rect(cornerRadius: 10))
            
            
        }
    }
    
}
