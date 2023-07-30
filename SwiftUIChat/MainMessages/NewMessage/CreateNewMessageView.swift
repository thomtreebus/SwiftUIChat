//
//  CreateNewMessageView.swift
//  SwiftUIChat
//
//  Created by Thom Treebus on 30/07/2023.
//

import SwiftUI

struct CreateNewMessageView: View {
    
    // env var used to get rid of view from full screen cover on MainMessagesView
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                ForEach(0..<10) {num in
                    Text("new user")
                }
                .navigationTitle("New Message")
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        Button {
                            // remove CreateMessageView and show MainMessages again
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Text("Cancel")
                        }
                    }
                }
            }
        }
    }
}

struct CreateNewMessageView_Previews: PreviewProvider {
    static var previews: some View {
//        CreateNewMessageView()
        MainMessagesView()
    }
}
