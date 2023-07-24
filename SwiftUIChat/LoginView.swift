//
//  ContentView.swift
//  SwiftUIChat
//
//  Created by Thom Treebus on 24/01/2023.
//

import SwiftUI

struct LoginView: View {
    
    @State var isLoginMode = false
    @State var email = ""
    @State var password = ""
    
    var body: some View {
        VStack(spacing: 16) {
            NavigationView {
                ScrollView {
                    VStack {
                        Picker(selection: $isLoginMode, label: Text("Picker Here")) {
                            Text("Login")
                                .tag(true)
                            Text("Create Account")
                                .tag(false)
                        }.pickerStyle(SegmentedPickerStyle())
                            .padding()

                        if !isLoginMode {
                            Button {
                                
                            } label: {
                                Image(systemName: "person.fill")
                                    .font(.system(size: 64))
                                    .padding()
                            }
                        }
                        
                        Group {
                            TextField("Email", text: $email)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                            SecureField("Password", text: $password)
                        }
                        .padding(12)
                        .background(.white)
                        
                        Button {
                            handleAction()
                        } label: {
                            HStack {
                                Spacer()
                                Text(isLoginMode ? "Log In" : "Create Account")
                                    .foregroundColor(.white)
                                    .padding(.vertical, 10)
                                    .font(.system(size: 14, weight:
                                            .semibold))
                                Spacer()
                            }.background(Color.blue)
                        }
                        
                    }
                    .padding()
                }
                .navigationTitle(isLoginMode ? "Login" : "Create Account")
                .background(Color(.init(white: 0, alpha: 0.05))
                    .ignoresSafeArea())
            }
        }
    }
    private func handleAction() {
        if isLoginMode {
            print("Should log into Firebase with existing credentials")
        }
        else {
            print("Register a new account inside of Firebase Autha nd then store image in Storage somehow...")
        }
    }
}

struct ContentView_Previews1: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

