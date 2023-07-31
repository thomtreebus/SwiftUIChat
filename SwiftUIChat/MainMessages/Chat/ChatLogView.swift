//
//  ChatLogView.swift
//  SwiftUIChat
//
//  Created by Thom Treebus on 31/07/2023.
//

import SwiftUI

struct ChatLogView: View {
        
    let chatUser: ChatUser?
    
    @State private var chatText = ""
    
    var body: some View {
        ZStack {
            messagesView
            
            VStack {
                Spacer()
                chatBottomBar
                    .background(.white)
            }
        }
        .navigationTitle(chatUser?.email ?? "")
            .navigationBarTitleDisplayMode(.inline)
    }
    
    private var messagesView: some View {
        ScrollView {
            ForEach(0..<20) { num in
                HStack {
                    Spacer()
                    HStack {
                        Text("Fake message")
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(.blue)
                    .cornerRadius(8)
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
            HStack { Spacer() }
        }
        .clipped() // fixes transparency issue of messages appearing behind nav title
        .background(Color(.init(white: 0.95, alpha: 1)))
        .padding(.bottom, 65)
    }
    
    private var chatBottomBar: some View {
        HStack(spacing: 16) {
            Image(systemName: "photo.on.rectangle")
                .font(.system(size: 24))
                .foregroundColor(Color(.darkGray))
            ZStack {
                DescriptionPlaceholder()
                TextEditor(text: $chatText)
                    .opacity(chatText.isEmpty ? 0.5 : 1)
            }
            .frame(height: 40)
            Button {
                
            } label: {
                Image(systemName: "paperplane.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 18))
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(.blue)
            .cornerRadius(20)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

private struct DescriptionPlaceholder: View {
    var body: some View {
        HStack {
            Text("Description")
                .foregroundColor(Color(.gray))
                .font(.system(size: 18))
                .padding(.leading, 5)
                .padding(.top, -4)
            Spacer()
        }
    }
}
struct ChatLogView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChatLogView(chatUser: .init(data: ["uid": "jbesN1ZWkscNIqISunUPGGIJk4s1", "email": "water@gmail.com"]))
        }
    }
}
