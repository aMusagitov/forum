//
//  ForumParser.swift
//  Forum
//
//  Created by Bogdan Dikolenko on 27.07.16.
//  Copyright © 2016 Konstantin. All rights reserved.
//
import Ji
import Foundation
class ForumParser: NSObject {
    
    var objects = [AnyObject]()
    var messages = [ForumObject]()
    var headers = [HeaderObject]()
    var pathUrl = "http://forum.awd.ru/"
    var typeForum = ForumObjectType.MainPage

    
    func parseSections(completion:((completed : Bool) -> Void)) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
        
            let jiDoc = Ji(htmlURL: NSURL(string: self.pathUrl)!)
            print(self.pathUrl)
            var objects = [HeaderObject]()
            var attrBg = [String]()
            var attrRow = [String]()
            
            if self.typeForum == .MainPage {
                guard let array = jiDoc?.rootNode?.descendantsWithAttributeName("class", attributeValue: "forabg") else { return }
                for section in array {
                    guard let header = section.firstDescendantWithAttributeName("class", attributeValue: "header") else { continue }
                    guard let icons = header.firstDescendantWithAttributeName("class", attributeValue: "icon") else { continue }
                    guard let dt = icons.firstChildWithName("dt") else { continue }
                    //                guard let urlString = dt.children.first?.attributes["href"] else { continue }
                    guard let content = dt.content else { continue }
                    let rows = section.descendantsWithAttributeName("class", attributeValue: "row")
                    //                let link = urlString.stringByReplacingOccurrencesOfString("./", withString: "http://forum.awd.ru/")
                    objects.append(HeaderObject(url: "", content: content, children: self.parseRows(rows)))
                }
                dispatch_async(dispatch_get_main_queue(), {
                    self.headers = objects
                    completion(completed: true)
                })
            } else {
                let icon = ["", "icon", "icon"]
                if self.typeForum == .Forum {
                    attrBg = ["forumbg announcement", "forumbg", "forumbg"]
                    attrRow = ["topictitle", "topictitle", "topictitle"]
                } else if self.typeForum == .Subforum {
                    attrBg = ["forumbg announcement", "forabg", "forumbg"]
                    attrRow = ["topictitle", "forumtitle", "topictitle"]
                }
                for i in 0...2{
                    guard let section = jiDoc?.rootNode?.firstDescendantWithAttributeName("class", attributeValue: attrBg[i]) else { continue }
                    guard let header = section.firstDescendantWithAttributeName("class", attributeValue: "header") else { continue }
                    guard let icons = header.firstDescendantWithAttributeName("class", attributeValue: icon[i]) else { continue }
                    guard let dt = icons.firstChildWithName("dt") else { continue }
                    //                guard let urlString = dt.children.first?.attributes["href"] else { continue }
                    guard let content = dt.content else { continue }
                    let rows = section.descendantsWithAttributeName("class", attributeValue: attrRow[i])
                    //                let link = urlString.stringByReplacingOccurrencesOfString("./", withString: "http://forum.awd.ru/")
                    objects.append(HeaderObject(url: "", content: content, children: self.parseRows(rows)))
                }
                dispatch_async(dispatch_get_main_queue(), {
                    self.headers = objects
                    completion(completed: true)
                })
            }
        }
    
    }
    
    func parseRows(rows : [JiNode]) -> [ForumObject] {
        var objects = [ForumObject]()
        for row in rows {
            if self.typeForum == .MainPage{
                let dt = row.firstDescendantWithName("dt")
                guard let a = dt!.firstChildWithName("a"), let content = a.content, let urlString = a.attributes["href"] else { continue }
                let link = urlString.stringByReplacingOccurrencesOfString("./", withString: "http://forum.awd.ru/")
                objects.append(ForumObject(url:link, type: chooseForumType(row), content:content))
            } else if (self.typeForum == ForumObjectType.Subforum || self.typeForum == ForumObjectType.Forum) {
                guard let content = row.content, let urlString = row.attributes["href"] else {continue}
                let link = urlString.stringByReplacingOccurrencesOfString("./", withString: "http://forum.awd.ru/")
                objects.append(ForumObject(url:link, type: chooseForumType(row.parent!.parent!.parent!), content:content))
            }
        }
        return objects
    }
    
    func chooseForumType(row : JiNode) -> ForumObjectType {
        if self.typeForum == ForumObjectType.Forum {
            return .Topic
        }
        if let dl = row.firstDescendantWithName("dl"){
            if let icon = dl.attributes["style"]{
                if icon == "background-image: url(./styles/prosilver/imageset/forum_read_subforum.gif); background-repeat: no-repeat;" {
                    return .Subforum
                } else if icon == "background-image: url(./styles/prosilver/imageset/forum_read.gif); background-repeat: no-repeat;" {
                    return .Forum
                }
            }
        }
        return .Topic
    }
    
    func getCellContent(indexPath: NSIndexPath) -> (String){
        let message = self.headers[indexPath.section].children[indexPath.row].content
        return message
    }
    
    func nextPage(vc: ForumViewController, indexPath: NSIndexPath) -> (){
        vc.parser.pathUrl = getURL(atIndexPath: indexPath)
        vc.parser.typeForum = self.headers[indexPath.section].children[indexPath.row].type
    }
    
    func getURL(atIndexPath indexPath: NSIndexPath) -> String {
        return self.headers[indexPath.section].children[indexPath.row].url
    }
    
}
