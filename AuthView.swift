// Views/AuthView.swift

import SwiftUI
import FirebaseAuth

struct AuthView: View {
    @EnvironmentObject var session: SessionStore

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                NavigationLink("Log In", destination: LoginView())
                NavigationLink("Register", destination: RegisterView())

                Divider().padding(.vertical)

                Button("Skip to App") {
                    Auth.auth().signInAnonymously { result, err in
                        if let err = err as NSError? {
                            print("❌ Anonymous sign-in error:")
                            print("   Code:    \(err.code)")
                            print("   Domain:  \(err.domain)")
                            print("   Message: \(err.localizedDescription)")
                            print("   Info:    \(err.userInfo)")
                        }
                    }
                }
                .foregroundColor(.blue)
            }
            .navigationTitle("Welcome to Ingredii")
        }
    }
}
