//
//  RecentMessage.swift
//  SwiftUIChat
//
//  Created by Thom Treebus on 03/08/2023.
//

import Foundation
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

