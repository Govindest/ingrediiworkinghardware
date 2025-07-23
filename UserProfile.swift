// Models/UserProfile.swift

import Foundation

struct UserProfile: Identifiable {
    let id: String
    let email: String
    var displayName: String
    var friends: [String]

    init(id: String, dict: [String:Any]) {
        self.id          = id
        self.email       = dict["email"]       as? String ?? ""
        self.displayName = dict["displayName"] as? String ?? ""
        self.friends     = dict["friends"]     as? [String] ?? []
    }
}
