// Views/PhoneLoginView.swift

import SwiftUI
import FirebaseAuth         // ← to use PhoneAuthProvider

struct PhoneLoginView: View {
    @State private var phone = ""
    @State private var code = ""
    @State private var verificationID: String?
    @State private var error: String?

    var body: some View {
        VStack {
            TextField("Phone (+1…)", text: $phone)
                .keyboardType(.phonePad)

            if verificationID != nil {
                TextField("SMS Code", text: $code)
                    .keyboardType(.numberPad)
            }

            if let e = error {
                Text(e).foregroundColor(.red)
            }

            Button(verificationID == nil ? "Send Code" : "Verify Code") {
                // your verify/send logic here
            }
            .disabled(
                (verificationID == nil && phone.isEmpty) ||
                (verificationID != nil && code.isEmpty)
            )
        }
        .padding()
    }
}
