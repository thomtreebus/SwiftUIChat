//
//  ChatUser.swift
//  SwiftUIChat
//
//  Created by Thom Treebus on 26/07/2023.
//

import Foundation

struct ChatUser: Identifiable {
    
    var id: String { uid } // hashable identifier for ChatUser
    
    let uid, email, profileImageUrl: String
    
    init(data: [String: Any]) {
        self.uid = data["uid"] as? String ?? "" // cast as optional string
        self.email = data["email"] as? String ?? ""
        self.profileImageUrl = data["profileImageUrl"] as? String ?? ""
    }
}
