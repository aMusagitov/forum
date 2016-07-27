//
//  HeaderObject.swift
//  Forum
//
//  Created by Ruslan Musagitov on 27/07/16.
//  Copyright © 2016 Konstantin. All rights reserved.
//

import Foundation

class HeaderObject: ForumObject {
    
    init(url: String, content: String, children : [ForumObject]) {
        self.children = children
        super.init(url: url, content : content)
    }
    
    var children : [ForumObject]
    
}
