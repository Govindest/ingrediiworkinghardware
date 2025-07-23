// Views/CommunityView.swift

import SwiftUI

struct CommunityView: View {
  @EnvironmentObject private var communityStore: CommunityStore
  @State private var memberEmails: [String] = []
  @State private var draftEmail = ""
  @State private var showingAddFriend = false
  @State private var groupID: String?

  var body: some View {
    NavigationStack {
      List(communityStore.groupPantry) { item in
        PantryRowView(item: item)
      }
      .navigationTitle("Group Pantry")
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button("Add Friend") {
            showingAddFriend = true
          }
        }
      }
      .sheet(isPresented: $showingAddFriend) {
        AddFriendView(memberEmails: $memberEmails)
          .environmentObject(communityStore)
      }
      .onChange(of: memberEmails) { emails in
        // 1) If we’ve never created a group yet, do so
        if groupID == nil {
          communityStore.createGroup(withEmails: emails) { result in
            if case .success(let gid) = result {
              groupID = gid
              // Now subscribe & push existing members
              communityStore.subscribe(toGroup: gid, memberUIDs: emails)
            }
          }
        } else if let gid = groupID {
          // 2) Otherwise, add new member via invite
          let newEmails = emails.filter { !communityStore.memberPantries.keys.contains($0) }
          newEmails.forEach { email in
            communityStore.invite(email: email, toGroup: gid) { success in
              if success {
                communityStore.subscribe(toGroup: gid, memberUIDs: emails)
              }
            }
          }
        }
      }
    }
  }
}
