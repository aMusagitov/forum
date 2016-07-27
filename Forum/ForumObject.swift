//
//  ForumObject.swift
//  Forum
//
//  Created by Ruslan Musagitov on 27/07/16.
//  Copyright © 2016 Konstantin. All rights reserved.
//

import Foundation


class ForumObject : NSObject {
    
    init(url : String, content : String) {
        super.init()
        self.url = url
        self.content = content
    }
    
    var url : String!
    var content : String!
}