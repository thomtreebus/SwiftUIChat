//
//  FirebaseManager.swift
//  SwiftUIChat
//
//  Created by Thom Treebus on 26/07/2023.
//

import Foundation
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
