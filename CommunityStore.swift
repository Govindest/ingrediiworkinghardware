// Models/CommunityStore.swift

import Foundation
import FirebaseFirestore

@MainActor
class CommunityStore: ObservableObject {
  private let db = Firestore.firestore()
  private var listeners: [ListenerRegistration] = []

  /// Each member’s UID → their pantry items
  @Published private(set) var memberPantries: [String:[PantryItem]] = [:]

  /// Flattened view of the whole group pantry
  var groupPantry: [PantryItem] {
    memberPantries.values.flatMap { $0 }
  }

  /// Create a new group document with these emails; returns generated groupID
  func createGroup(withEmails emails: [String],
                   completion: @escaping (Result<String,Error>)->Void)
  {
    let groupID = UUID().uuidString
    let doc = db.collection("groups").document(groupID)
    doc.setData(["members": emails]) { err in
      if let e = err { completion(.failure(e)) }
      else          { completion(.success(groupID)) }
    }
  }

  /// Invite a friend by email: looks up their UID and adds it under `groups/{groupID}`.
  func invite(email: String,
              toGroup groupID: String,
              completion: @escaping (Bool)->Void)
  {
    // 1) Find the user record by email
    db.collection("users")
      .whereField("email", isEqualTo: email)
      .getDocuments { snap, err in
        guard let doc = snap?.documents.first, err == nil else {
          return completion(false)
        }
        let uid = doc.documentID
        // 2) Add them to the group’s `members` array
        let groupDoc = self.db.collection("groups").document(groupID)
        groupDoc.updateData([
          "members": FieldValue.arrayUnion([uid])
        ]) { err in
          completion(err == nil)
        }
      }
  }

  /// Start listening to each member’s pantry
  func subscribe(toGroup groupID: String,
                 memberUIDs: [String])
  {
    // tear down previous listeners
    listeners.forEach { $0.remove() }
    listeners.removeAll()

    memberPantries = [:]

    for uid in memberUIDs {
      let listener = db
        .collection("pantries")
        .document(uid)
        .addSnapshotListener { [weak self] snap, _ in
          guard let self = self,
                let data = snap?.data(),
                let raw  = data["items"] as? [[String:Any]]
          else { return }

          let items = raw.compactMap { PantryItem(from: $0) }
          DispatchQueue.main.async {
            self.memberPantries[uid] = items
          }
      }
      listeners.append(listener)
    }
  }
}
