//
//  ForumObject.swift
//  Forum
//
//  Created by Ruslan Musagitov on 27/07/16.
//  Copyright © 2016 Konstantin. All rights reserved.
//

import Foundation

enum ForumObjectType : String {
    case MainPage = "MainPage"
    case Forum = "Forum"
    case Subforum = "Subforum"
    case Topic = "Topic"
    
//    func stringValue() -> String {
//        switch self {
//        case .Forum:
//            return "Forum"
//        case .Subforum:
//            return "Subforum"
//        case .Topic:
//            return "Topic"
//        }
//    }
}

class ForumObject : NSObject {
    
    init(url : String, type : ForumObjectType, content : String) {
        //        super.init()
        self.url = url
        self.type = type
        self.content = content
    }
    
    var url : String
    var type : ForumObjectType
    var content : String
}