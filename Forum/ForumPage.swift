//
//  ForumPage.swift
//  Forum
//
//  Created by Bogdan Dikolenko on 26.07.16.
//  Copyright © 2016 Konstantin. All rights reserved.

import UIKit

class ForumPage: NSObject {
    
    var links = [String]()
    var pathUrl = "http://forum.awd.ru/"
    var lastPathUrl = "http://forum.awd.ru/"
    var content = ""
    
    func switchContent() ->() {
        print(self.pathUrl)
        if self.pathUrl.containsString("t="){
            self.content = "content"
        } else if self.lastPathUrl != "http://forum.awd.ru/"{
            self.content = "topictitle"
        } else {
            self.content = "forumtitle"
        }
    }

}
