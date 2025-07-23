// Models/Community.swift

import Foundation

struct Community: Identifiable {
    let id: String
    let name: String
    var memberUIDs: [String]

    init?(id: String, dict: [String:Any]) {
        guard
            let name       = dict["name"]       as? String,
            let memberUIDs = dict["memberUIDs"] as? [String]
        else { return nil }
        self.id         = id
        self.name       = name
        self.memberUIDs = memberUIDs
    }

    func toDictionary() -> [String:Any] {
        return [
            "name": name,
            "memberUIDs": memberUIDs
        ]
    }
}
