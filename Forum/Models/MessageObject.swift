//
//  MessageObject.swift
//  Forum
//
//  Created by Bogdan Dikolenko on 03.08.16.
//  Copyright © 2016 Konstantin. All rights reserved.
//

import Foundation

class MessageObject: NSObject {
    
    init(time: String, content: NSAttributedString, author : AuthorObject, order : NSNumber) {
        self.time = time
        self.author = author
        self.content = content
        self.order = order
    }
    
    var content : NSAttributedString
    var author : AuthorObject
    var time : String
    var order : NSNumber
}
