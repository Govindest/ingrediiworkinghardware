import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var session: SessionStore

    var body: some View {
        NavigationStack {
            Form {
                // ── Your account info ──
                Section(header: Text("Your Info")) {
                    Text(session.user?.email ?? "Not signed in")
                }

                // ── Account actions ──
                Section {
                    Button("Sign Out") {
                        session.signOut()
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Profile")
        }
    }
}
