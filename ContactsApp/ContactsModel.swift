//
//  ContactsModel.swift
//  ContactsApp
//
//  Created by deepali on 06/09/19 at 11:44 PM.
//  Copyright © 2019 meditab. All rights reserved.
//

import Foundation

class ContactsModel: NSObject, Codable {
    
    var firstName, lastName, profilePic, url, createdAt, updatedAt, email, phoneNumber: String?
    var favorite: Bool?
    var id: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case profilePic = "profile_pic"
        case favorite
        case url
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case email
        case phoneNumber = "phone_numbers"
    }
}
