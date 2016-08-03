//
//  AuthorObject.swift
//  Forum
//
//  Created by Bogdan Dikolenko on 03.08.16.
//  Copyright © 2016 Konstantin. All rights reserved.
//

import Foundation

class AuthorObject: NSObject {
    init(name: String, profileUrl: String, avatar : String) {
        self.name = name
        self.profileUrl = profileUrl
        self.avatar = avatar
    }
    
    var name : String
    var profileUrl : String
    var avatar : String
}
