//
//  ContentView.swift
//  SwiftUIChat
//
//  Created by Thom Treebus on 24/01/2023.
//

import SwiftUI
import Firebase
import FirebaseStorage
import FirebaseFirestore

// Singleton for managing instance of FirebaseApp
class FirebaseManager: NSObject {
    
    let auth: Auth
    let storage: Storage
    let firestore: Firestore
    
    static let shared = FirebaseManager()
    
    override init() {
        FirebaseApp.configure()
        
        self.auth = Auth.auth()
        self.storage = Storage.storage()
        self.firestore = Firestore.firestore()
        
        super.init()
    }
    
}

struct LoginView: View {
    
    @State var isLoginMode = false
    @State var email = ""
    @State var password = ""
    @State private var loginStatusMessage = ""
    @State private var shouldShowImagePicker = false
    
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
                                shouldShowImagePicker.toggle()
                            } label: {
                                
                                VStack {
                                    if let image = self.image {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 128, height: 128)
                                            .cornerRadius(64)
                                    } else {
                                        Image(systemName: "person.fill")
                                            .font(.system(size: 64))
                                            .padding()
                                            .foregroundColor(Color(.label))
                                    }
                                }
                                .overlay(RoundedRectangle(cornerRadius: 64)
                                    .stroke(.black, lineWidth: 3))
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
                        Text(self.loginStatusMessage)
                            .foregroundColor(.red)
                    }
                    .padding()
                }
                .navigationTitle(isLoginMode ? "Login" : "Create Account")
                .background(Color(.init(white: 0, alpha: 0.05))
                    .ignoresSafeArea())
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .fullScreenCover(isPresented: $shouldShowImagePicker, onDismiss: nil) {
            ImagePicker(image: $image)
        }
    }
    
    @State private var image: UIImage?
    
    private func handleAction() {
        if isLoginMode {
            loginUser()
        }
        else {
            createNewAccount()
        }
    }
    
    private func loginUser() {
        FirebaseManager.shared.auth.signIn(withEmail: email, password: password) {result, err in
            if let err = err {
                print("Failed to login user:", err)
                self.loginStatusMessage = "Failed to login user: \(err)"
                return
            }
            
            print("Successfully logged in user: \(result?.user.uid ?? "")")
            self.loginStatusMessage = "Successfully logged in user: \(result?.user.uid ?? "")"
        }
    }
    
    private func createNewAccount() {
        FirebaseManager.shared.auth.createUser(withEmail: email, password: password) { result, err in
            if let err = err {
                print("Failed to create user:", err)
                self.loginStatusMessage = "Failed to create user: \(err)"
                return
            }
            
            print("Successfully created user: \(result?.user.uid ?? "")")
            self.loginStatusMessage = "Successfully created user: \(result?.user.uid ?? "")"
            
            self.persistImageToStorage()
        }
    }
    
    private func persistImageToStorage() {
//        let filename = UUID().uuidString
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid
            else{return}
        
        let ref = FirebaseManager.shared.storage.reference(withPath: uid)
        guard let imageData = self.image?.jpegData(compressionQuality: 0.5)
        else { return}
                
        ref.putData(imageData, metadata: nil) { metadata, err in
            if let err = err {
                self.loginStatusMessage = "Failed to push image to Storage: \(err)"
                return
            }
            
            ref.downloadURL { url, err in
                if let err = err {
                    self.loginStatusMessage = "Failed to retrieve downloadURL: \(err)"
                    return
                }
                
                self.loginStatusMessage = "Successfully stored image with url: \(url?.absoluteString ?? "")"
                print(url?.absoluteString)
                
                guard let url = url else { return }
                self.storeUserInformation(imageProfileURL: url)
            }
        }
    }
    
    private func storeUserInformation(imageProfileURL: URL) {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            return }
        
        let userData = ["email": self.email, "uid": uid, "profileImageURL": imageProfileURL.absoluteString]
        
        FirebaseManager.shared.firestore.collection("users")
            .document(uid).setData(userData) { err in
                if let err = err {
                    print(err)
                    self.loginStatusMessage = "\(err)"
                    return
                }
                print("Successfully uploaded user data")
            }
    }
    
}

struct ContentView_Previews1: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

