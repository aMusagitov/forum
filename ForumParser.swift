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
    var lastPathUrl = "http://forum.awd.ru/"
    var typeForum = "subforum"

    
    func parseSections(completion:((completed : Bool) -> Void)) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
        
            let jiDoc = Ji(htmlURL: NSURL(string: self.pathUrl)!)
            print(self.pathUrl)
            var attrBg = ""
            var attrRow = ""
            if self.typeForum == "subforum" {
                attrBg = "forabg"
                attrRow = "row"
            }
            if self.typeForum == "forum" {
                attrBg = "forumbg"
                attrRow = "row bg1"
            }
            guard let array = jiDoc?.rootNode?.descendantsWithAttributeName("class", attributeValue: attrBg) else { return }
            var objects = [HeaderObject]()
            for section in array {
                guard let header = section.firstDescendantWithAttributeName("class", attributeValue: "header") else { continue }
                guard let icons = header.firstDescendantWithAttributeName("class", attributeValue: "icon") else { continue }
                guard let dt = icons.firstChildWithName("dt") else { continue }
                //                guard let urlString = dt.children.first?.attributes["href"] else { continue }
                guard let content = dt.content else { continue }
                let rows = section.descendantsWithAttributeName("class", attributeValue: attrRow)
                //                let link = urlString.stringByReplacingOccurrencesOfString("./", withString: "http://forum.awd.ru/")
                objects.append(HeaderObject(url: "", content: content, children: self.parseRows(rows)))
            }
            dispatch_async(dispatch_get_main_queue(), {
                self.headers = objects
                completion(completed: true)
            })
        }
    
    }
    
    func parseRows(rows : [JiNode]) -> [ForumObject] {
        var objects = [ForumObject]()
        for row in rows {
            let dl = row.firstDescendantWithName("dl")
            let icon = dl!.attributes["style"]
            var type = ""
            if icon == "background-image: url(./styles/prosilver/imageset/forum_read_subforum.gif); background-repeat: no-repeat;" {
                type = "subforum"
            } else if icon == "background-image: url(./styles/prosilver/imageset/forum_read.gif); background-repeat: no-repeat;" {
                type = "forum"
            }
            let dt = row.firstDescendantWithName("dt")
            guard let a = dt!.firstDescendantWithName("a"), let content = a.content, let urlString = a.attributes["href"] else { continue }
            let link = urlString.stringByReplacingOccurrencesOfString("./", withString: "http://forum.awd.ru/")
            objects.append(ForumObject(url:link, type: type, content:content))
        }
        return objects
    }
    
    func getCellContent(indexPath: NSIndexPath) -> (String){
        let message = self.headers[indexPath.section].children[indexPath.row].content
        return message
    }
    
    func nextPageUrl(vc: MasterViewController, indexPath: NSIndexPath) -> (){
        vc.parser.lastPathUrl = self.pathUrl
        vc.parser.pathUrl = self.headers[indexPath.section].children[indexPath.row].url
        vc.parser.typeForum = self.headers[indexPath.section].children[indexPath.row].type
    }
    
    //    func parseUrl() {
    //        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
    //
    //            let jiDoc = Ji(htmlURL: NSURL(string: self.pathUrl)!)
    //            self.switchContent()
    //            guard let array = jiDoc?.rootNode?.descendantsWithAttributeName("class", attributeValue: self.content) else { return }
    //            var objects = [ForumObject]()
    //            for message in array {
    //                var link = message.attributes["href"]!
    //                if !self.pathUrl.containsString("t="){
    //                    link = link.stringByReplacingOccurrencesOfString("./", withString: "http://forum.awd.ru/")
    //                    self.links.append(link)
    //                }
    //                objects.append(ForumObject(url: link, content: message.content!))
    //            }
    //            dispatch_async(dispatch_get_main_queue(), {
    //                self.messages = objects
    //                self.tableView.reloadData()
    //            })
    //        }
    //    }
    
}
