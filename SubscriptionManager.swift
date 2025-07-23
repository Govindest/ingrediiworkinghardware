import FirebaseFirestore

final class SubscriptionManager {
  static let shared = SubscriptionManager()
  private let db = Firestore.firestore()
  private var listeners: [ListenerRegistration] = []

  private init() {}

  func listen(to store: PantryStore) {
    listeners.forEach { $0.remove() }
    listeners = []

    guard let uid = SessionStore.shared.user?.uid else { return }

    for section in StorageSection.allCases {
      let ref = db.collection("pantries")
                  .document(uid)
                  .collection(section.rawValue)
      let l = ref.addSnapshotListener { snap, _ in
        guard let docs = snap?.documents else { return }
        let items = docs.compactMap { PantryItem(from: $0.data()) }
        Task { @MainActor in
          store.update(items, for: section)
        }
      }
      listeners.append(l)
    }
  }
}
