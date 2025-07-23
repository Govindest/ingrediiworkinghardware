// Views/LoginView.swift

import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @EnvironmentObject var session: SessionStore

    @State private var email    = ""
    @State private var password = ""
    @State private var error: String?

    var body: some View {
        Form {
            Section(header: Text("Log in")) {
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                SecureField("Password", text: $password)
            }

            if let err = error {
                Section { Text(err).foregroundColor(.red) }
            }

            Section {
                Button("Log In") {
                    login()
                }
                .disabled(email.isEmpty || password.isEmpty)
            }
        }
        .navigationTitle("Login")
    }

    private func login() {
        Auth.auth().signIn(withEmail: email, password: password) { _, err in
            if let err = err {
                self.error = err.localizedDescription
            }
            // On success: SessionStore.user is auto‐updated and UI switches
        }
    }
}
