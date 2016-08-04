//
//  HeaderObject.swift
//  Forum
//
//  Created by Ruslan Musagitov on 27/07/16.
//  Copyright © 2016 Konstantin. All rights reserved.
//

import Foundation

class HeaderObject: NSObject {
    
    init(url: String, content: String, children : [ForumObject]) {
        self.children = children
        self.url = url
        self.content = content
    }
    
    var children : [ForumObject]
    var url : String!
    var content : String!
}
