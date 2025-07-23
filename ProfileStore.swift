// Models/ProfileStore.swift

import Foundation
import FirebaseFirestore

@MainActor
class ProfileStore: ObservableObject {
  private let db = Firestore.firestore()

  /// Map email → uid for quick lookup
  @Published var emailToUID: [String:String] = [:]

  /// Call once at app-launch or when users register
  func loadAllUsers() {
    db.collection("users")
      .getDocuments { snap, err in
        guard let docs = snap?.documents else { return }
        var map = [String:String]()
        for d in docs {
          if
            let email = d.data()["email"] as? String,
            !email.isEmpty
          {
            map[email.lowercased()] = d.documentID
          }
        }
        DispatchQueue.main.async {
          self.emailToUID = map
        }
      }
  }
}
