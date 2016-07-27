//
//  ForumObject.swift
//  Forum
//
//  Created by Ruslan Musagitov on 27/07/16.
//  Copyright © 2016 Konstantin. All rights reserved.
//

import Foundation


class ForumObject : NSObject {
    
    init(url : String, type : String, content : String) {
        super.init()
        self.url = url
        self.type = type
        self.content = content
    }
    
    var url : String!
    var type : String!
    var content : String!
}