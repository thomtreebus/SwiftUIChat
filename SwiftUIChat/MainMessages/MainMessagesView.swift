//
//  MainMessagesView.swift
//  SwiftUIChat
//
//  Created by Thom Treebus on 25/07/2023.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase

struct RecentMessage: Identifiable {
    var id: String { documentId }
    
    let documentId: String
    let text, fromId, toId: String
    let email, profilImageUrl: String
    let timestamp: Timestamp
    
    init (documentId: String, data: [String: Any]) {
        self.documentId = documentId
        self.text = data[FirebaseConstants.text] as? String ?? ""
        self.fromId = data[FirebaseConstants.fromId] as? String ?? ""
        self.toId = data[FirebaseConstants.toId] as? String ?? ""
        self.email = data[FirebaseConstants.email] as? String ?? ""
        self.profilImageUrl = data[FirebaseConstants.profileImageUrl] as? String ?? ""
        self.timestamp = data[FirebaseConstants.text] as? Timestamp ?? Timestamp(date: .now)
        
    }
    
}

class MainMessagesViewModel: ObservableObject {
    
    @Published var errorMessage = ""
    @Published var chatUser: ChatUser?
    
    init() {
        
        DispatchQueue.main.async { // fixes bug that doesn't show full screen covers
            self.isUserLoggedOut = FirebaseManager.shared.auth.currentUser?.uid == nil
        }
        
        fetchCurrentUser()
        fetchRecentMessages()
    }
    
    @Published var recentMessages = [RecentMessage]()
    
    private func fetchRecentMessages() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        FirebaseManager.shared.firestore.collection(FirebaseConstants.recent_messages)
            .document(uid)
            .collection(FirebaseConstants.messages)
            .order(by: FirebaseConstants.timestamp)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    self.errorMessage = "Failed to listen for recent messages: \(error)"
                    print(error)
                    return
                }
                // add recent message every time change occures
                querySnapshot?.documentChanges.forEach({ change in
                    let docId = change.document.documentID
                    if let index = self.recentMessages.firstIndex(where: { rm in
                        return rm.documentId == docId
                    }) {
                        self.recentMessages.remove(at: index)
                    }
                    self.recentMessages.insert(.init(documentId: docId, data: change.document.data()), at: 0)
//                    self.recentMessages.append()
                })
            }
    }
    
    func fetchCurrentUser() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            self.errorMessage = "Could not find firebase uid"
            return
        }
        
        FirebaseManager.shared.firestore.collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                self.errorMessage = "Failed to fetch current user: \(error)"
                print("Failed to fetch current user:", error)
                return
            }
            
            guard let data = snapshot?.data() else {
                return
            }
            
            self.chatUser = .init(data: data)
        }
    }
    
    @Published var isUserLoggedOut = false
    
    func handleSignOut() {
        isUserLoggedOut.toggle()
        try? FirebaseManager.shared.auth.signOut()
    }
    
}

struct MainMessagesView: View {
    
    @State private var shouldShowLogOutOptions = false
    
    @State private var shouldNavigateToChatLogView = false
    
    @ObservedObject private var vm = MainMessagesViewModel()
    
    var body: some View {
        NavigationView {
            //custom nav bar
            VStack {
                customNavBar
                messagesView
                
                NavigationLink("", isActive: $shouldNavigateToChatLogView) {
                    ChatLogView(chatUser: self.chatUser)
                }
            }
            .overlay(newMessageButton, alignment: .bottom)
            .navigationBarHidden(true)
        }
    }
    
    private var customNavBar: some View {
        HStack(spacing: 16) {
            WebImage(url: URL(string: vm.chatUser?.profileImageUrl ?? ""))
                .resizable()
                .scaledToFill()
                .frame(width: 50, height: 50)
                .clipped()
                .cornerRadius(50)
                .overlay(RoundedRectangle(cornerRadius: 50)
                    .stroke(Color(.label), lineWidth: 1)
                )
                .shadow(radius: 5)
            
            VStack(alignment: .leading, spacing: 4) {
                let emailString = vm.chatUser?.email.replacingOccurrences(of: "@gmail.com", with: "") ?? ""
                Text(emailString)
                    .font(.system(size: 24, weight: .bold))
                
                HStack {
                    Circle()
                        .foregroundColor(.green)
                        .frame(width: 14, height: 14)
                    Text("online")
                        .font(.system(size: 12))
                        .foregroundColor(Color(.lightGray))
                }
            }
            
            Spacer()
            Button {
                shouldShowLogOutOptions.toggle()
            } label : {
                Image(systemName: "gear")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(.label))
            }
        }
        .padding()
        .actionSheet(isPresented: $shouldShowLogOutOptions) {
            .init(title: Text("Settings"), message: Text("What do you want to do?"), buttons: [
                .destructive(Text("Sign Out"), action: {
                    print("handle sign out")
                    vm.handleSignOut()
                }),
                .cancel()
            ])
        }
        .fullScreenCover(isPresented: $vm.isUserLoggedOut, onDismiss: nil) {
            LoginView(didCompleteLoginProcess: {
                self.vm.isUserLoggedOut = false
                self.vm.fetchCurrentUser()
            })
        }
    }
    
    private var messagesView: some View {
        ScrollView {
            ForEach(vm.recentMessages) { recentMessage in
                VStack {
                    NavigationLink {  // navigate to new page
                        Text("Destination")
                    } label: {
                        HStack(spacing: 16) {
                            WebImage(url: URL(string: recentMessage.profilImageUrl))
                                .resizable()
                                .scaledToFill()
                                .frame(width: 48, height: 48)
                                .clipped()
                                .cornerRadius(64)
                                .overlay(RoundedRectangle(cornerRadius: 64).stroke(.black, lineWidth: 2))
                                .shadow(radius: 5)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text(recentMessage.email)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(Color(.label))
                                Text(recentMessage.text)
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(.lightGray))
                                    .multilineTextAlignment(.leading)
                            }
                            Spacer()
                            
                            Text("22d")
                                .font(.system(size: 14, weight: .semibold))
                        }
                    }
                    Divider()
                }.padding(.horizontal)
            }.padding(.bottom, 50)
        }
    }
    
    @State private var shouldShowNewMessageScreen = false
    
    private var newMessageButton: some View {
        Button {
            shouldShowNewMessageScreen.toggle()
        } label: {
            HStack {
                Spacer()
                Text("+ New Message")
                    .font(.system(size: 16, weight: .bold))
                Spacer()
            }
            .foregroundColor(.white)
            .padding(.vertical)
            .background(.blue)
            .cornerRadius(32)
            .padding(.horizontal)
            .shadow(radius: 15)
        }
        .fullScreenCover(isPresented: $shouldShowNewMessageScreen) {
            CreateNewMessageView { user in
                print(user.email)
                self.shouldNavigateToChatLogView.toggle()
                self.chatUser = user
            } // redirect user to new message screen
        }
    }
    @State private var chatUser: ChatUser?
}




struct MainMessagesView_Previews: PreviewProvider {
    static var previews: some View {
        MainMessagesView()
    }
}
