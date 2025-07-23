// Models/SessionStore.swift

import Foundation
import FirebaseAuth

@MainActor
class SessionStore: ObservableObject {
  @Published var user: User?

  private var handle: AuthStateDidChangeListenerHandle?

  init() {
    handle = Auth.auth().addStateDidChangeListener { _, user in
      self.user = user
    }
  }

  func signOut() {
    try? Auth.auth().signOut()
    user = nil
  }
}
