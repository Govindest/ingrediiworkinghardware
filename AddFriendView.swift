// Views/AddFriendView.swift

import SwiftUI

struct AddFriendView: View {
  @EnvironmentObject private var communityStore: CommunityStore
  @Binding private var memberEmails: [String]
  @State private var email: String = ""
  @Environment(\.dismiss) private var dismiss

  init(memberEmails: Binding<[String]>) {
    self._memberEmails = memberEmails
  }

  var body: some View {
    NavigationStack {
      Form {
        Section("Friend’s Email") {
          TextField("email@example.com", text: $email)
            .keyboardType(.emailAddress)
            .autocapitalization(.none)
        }

        Section {
          Button("Send Invite", action: sendInvite)
            .disabled(email.isEmpty)
        }
      }
      .navigationTitle("Add Friend")
      .navigationBarTitleDisplayMode(.inline)
    }
  }

  private func sendInvite() {
    guard let gid = communityStore.memberPantries.isEmpty ? nil : communityStore.memberPantries.keys.first else {
      // no groupID yet; but we’ll pick it up on onChange in CommunityView
      memberEmails.append(email)
      dismiss()
      return
    }

    communityStore.invite(email: email, toGroup: gid) { success in
      if success {
        memberEmails.append(email)
        dismiss()
      }
      // else you could show an alert…
    }
  }
}
