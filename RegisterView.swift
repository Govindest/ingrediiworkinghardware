// Models/RegisterView.swift

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct RegisterView: View {
    @EnvironmentObject var session: SessionStore

    @State private var email    = ""
    @State private var password = ""
    @State private var error: String?

    var body: some View {
        Form {
            Section(header: Text("Create account")) {
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                SecureField("Password", text: $password)
            }

            if let err = error {
                Section {
                    Text(err)
                        .foregroundColor(.red)
                }
            }

            Section {
                Button("Register") {
                    register()
                }
                .disabled(email.isEmpty || password.isEmpty)
            }
        }
        .navigationTitle("Register")
    }

    private func register() {
        Auth.auth().createUser(withEmail: email, password: password) { result, err in
            if let err = err as NSError? {
                print("❌ FirebaseAuth createUser error:")
                print("   Code:    \(err.code)")
                print("   Message: \(err.localizedDescription)")
                self.error = err.localizedDescription
            } else {
                // Write initial profile document
                guard let uid = result?.user.uid else { return }
                let data: [String:Any] = [
                    "email": email,
                    "displayName": email,
                    "friends": [String]()
                ]
                Firestore.firestore()
                    .collection("users")
                    .document(uid)
                    .setData(data) { firestoreError in
                        if let fe = firestoreError {
                            print("Error writing profile:", fe.localizedDescription)
                        }
                    }
            }
        }
    }
}
