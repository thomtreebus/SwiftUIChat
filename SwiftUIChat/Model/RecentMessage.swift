//
//  RecentMessage.swift
//  SwiftUIChat
//
//  Created by Thom Treebus on 03/08/2023.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct RecentMessage: Codable, Identifiable {
    @DocumentID var id: String?
    let text, fromId, toId, email, profileImageUrl: String
    let timestamp: Date
}

