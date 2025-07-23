import SwiftUI
import FirebaseCore

@main
struct IngrediiApp: App {
  @StateObject private var session = SessionStore()
  @StateObject private var pantry = PantryStore()

  init() {
    FirebaseApp.configure()
  }

  var body: some Scene {
    WindowGroup {
      Group {
        if session.user != nil {
          ContentView()
            .environmentObject(session)
            .environmentObject(pantry)
        } else {
          AuthView()
            .environmentObject(session)
        }
      }
    }
  }
}
