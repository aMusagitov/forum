//
//  ForumParser.swift
//  Forum
//
//  Created by Bogdan Dikolenko on 27.07.16.
//  Copyright © 2016 Konstantin. All rights reserved.
//
import Ji
import UIKit

class ForumParser: NSObject {
    
    var objects = [AnyObject]()
    var messages = [ForumObject]()
    var headers = [HeaderObject]()
    let page = ForumPage()
    
    func parseSections() {
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
        
            let jiDoc = Ji(htmlURL: NSURL(string: self.page.pathUrl)!)
            print(self.page.pathUrl)
            //            self.page.switchContent()
        if self.page.lastPathUrl != "http://forum.awd.ru/" {
            guard let array = jiDoc?.rootNode?.descendantsWithAttributeName("class", attributeValue: "forum") else { return }
        } else {
            guard let array = jiDoc?.rootNode?.descendantsWithAttributeName("class", attributeValue: "forabg") else { return }
        }
            var objects = [HeaderObject]()
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
//            dispatch_async(dispatch_get_main_queue(), {
                self.headers = objects
//                self.tableView.reloadData()
//            })
//        }
        
    }
    
    func parseRows(rows : [JiNode]) -> [ForumObject] {
        var objects = [ForumObject]()
        for row in rows {
            let dt = row.firstDescendantWithName("dt")
            guard let a = dt?.firstChildWithName("a"), let content = a.content, let urlString = a.attributes["href"] else { continue }
            let link = urlString.stringByReplacingOccurrencesOfString("./", withString: "http://forum.awd.ru/")
            objects.append(ForumObject(url:link , content:content))
        }
        return objects
    }
    
    func getCellContent(indexPath: NSIndexPath) -> (String){
        let message = self.headers[indexPath.section].children[indexPath.row].content
        return message
    }
    
    func nextPageUrl(vc: MasterViewController, indexPath: NSIndexPath) -> (){
        vc.parser.page.lastPathUrl = self.page.pathUrl
        vc.parser.page.pathUrl = self.headers[indexPath.section].children[indexPath.row].url        
    }
    
    //    func parseUrl() {
    //        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
    //
    //            let jiDoc = Ji(htmlURL: NSURL(string: self.page.pathUrl)!)
    //            self.page.switchContent()
    //            guard let array = jiDoc?.rootNode?.descendantsWithAttributeName("class", attributeValue: self.page.content) else { return }
    //            var objects = [ForumObject]()
    //            for message in array {
    //                var link = message.attributes["href"]!
    //                if !self.page.pathUrl.containsString("t="){
    //                    link = link.stringByReplacingOccurrencesOfString("./", withString: "http://forum.awd.ru/")
    //                    self.page.links.append(link)
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
