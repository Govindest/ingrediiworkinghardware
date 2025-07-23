import Foundation
import FirebaseFirestore

@MainActor
class CommunityStore: ObservableObject {
  private let db = Firestore.firestore()
  private var listeners: [ListenerRegistration] = []

  /// Maps each member’s UID → their list of PantryItem
  @Published var memberPantries: [String:[PantryItem]] = [:]

  /// Flattened view of every item across all members
  var combinedItems: [PantryItem] {
    memberPantries.values.flatMap { $0 }
  }

  /// Call this when you join/open a group; it will:
  /// 1) listen to the group doc for its `members` array
  /// 2) for each UID, spin up a listener on that user’s pantry doc
  func subscribe(toGroup groupID: String) {
    // tear down any existing listeners
    listeners.forEach { $0.remove() }
    listeners.removeAll()

    // 1) listen to the group’s member list
    let groupRef = db.collection("groups").document(groupID)
    let groupListener = groupRef.addSnapshotListener { [weak self] snap, err in
      guard let self = self,
            let data = snap?.data(),
            let uids = data["members"] as? [String]
      else { return }
      self.listenTo(uids: uids)
    }
    listeners.append(groupListener)
  }

  private func listenTo(uids: [String]) {
    // remove old pantry listeners
    listeners.forEach { $0.remove() }
    listeners.removeAll()

    for uid in uids {
      let pantryDoc = db.collection("pantries").document(uid)
      let panListener = pantryDoc.addSnapshotListener { [weak self] snap, err in
        guard let self = self,
              let data = snap?.data(),
              let raw = data["items"] as? [[String:Any]]
        else { return }
        // decode each dict → PantryItem
        let items = raw.compactMap { dict in
          PantryItem(from: dict)
        }
        DispatchQueue.main.async {
          self.memberPantries[uid] = items
        }
      }
      listeners.append(panListener)
    }
  }

  deinit {
    listeners.forEach { $0.remove() }
  }
}
