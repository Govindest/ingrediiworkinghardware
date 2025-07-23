// Views/CreateGroupView.swift

import SwiftUI

struct CreateGroupView: View {
  @Environment(\.dismiss) private var dismiss
  @EnvironmentObject private var communityStore: CommunityStore

  @State private var groupName    = ""
  @State private var memberEmails = ""  // comma-separated

  var body: some View {
    NavigationStack {
      Form {
        Section("Group Name") {
          TextField("e.g. Weekend BBQ", text: $groupName)
        }
        Section("Members (comma-separated emails)") {
          TextField("alice@example.com, bob@…", text: $memberEmails)
            .autocapitalization(.none)
            .keyboardType(.emailAddress)
        }
      }
      .navigationTitle("New Group")
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel") { dismiss() }
        }
        ToolbarItem(placement: .confirmationAction) {
          Button("Create") {
            // split, trim, **you’ll need to resolve email→UID separately**
            let emails = memberEmails
              .split(separator: ",")
              .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            communityStore.createGroup(name: groupName,
                                       memberUIDs: emails)
            dismiss()
          }
          .disabled(groupName.isEmpty || memberEmails.isEmpty)
        }
      }
    }
  }
}
