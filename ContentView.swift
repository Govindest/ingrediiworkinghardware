import SwiftUI

struct ContentView: View {
  @EnvironmentObject var session: SessionStore
  @EnvironmentObject var pantry: PantryStore

  var body: some View {
    TabView {
      PantryView()
        .tabItem { Label("Pantry",  systemImage: "archivebox.fill") }
      PantryView(section: .fridge)
        .tabItem { Label("Fridge", systemImage: "snow") }
      PantryView(section: .grocery)
        .tabItem { Label("Grocery", systemImage: "cart.fill") }
    }
  }
}
