//
//  ChatMessage.swift
//  SwiftUIChat
//
//  Created by Thom Treebus on 03/08/2023.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct ChatMessage: Codable, Identifiable {
    @DocumentID var id: String?
    let fromId, toId, text: String
    let timestamp: Date
}
