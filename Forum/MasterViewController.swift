//
//  MasterViewController.swift
//  Forum
//
//  Created by Bogdan Dikolenko on 25.07.16.
//  Copyright © 2016 Konstantin. All rights reserved.
//

import UIKit
import Ji
import DTCoreText

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var objects = [AnyObject]()
    var messages = [ForumObject]()
    var headers = [HeaderObject]()
    let page = ForumPage()
    
    func parseSections() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
            
            let jiDoc = Ji(htmlURL: NSURL(string: self.page.pathUrl)!)
            self.page.switchContent()
            guard let array = jiDoc?.rootNode?.descendantsWithAttributeName("class", attributeValue: "forabg") else { return }
            var objects = [HeaderObject]()
            for section in array {
                guard let header = section.firstDescendantWithAttributeName("class", attributeValue: "header") else { continue }
                guard let icons = header.firstDescendantWithAttributeName("class", attributeValue: "icon") else { continue }
                guard let dt = icons.firstChildWithName("dt") else { continue }
                guard let urlString = dt.children.first?.attributes["href"] else { continue }
                guard let content = dt.content else { continue }
                let rows = section.descendantsWithAttributeName("class", attributeValue: "row")
                let link = urlString.stringByReplacingOccurrencesOfString("./", withString: "http://forum.awd.ru/")
                objects.append(HeaderObject(url: link, content: content, children: self.parseRows(rows)))
            }
            dispatch_async(dispatch_get_main_queue(), {
                self.headers = objects
                self.tableView.reloadData()
            })
        }

    }
    
    func parseRows(rows : [JiNode]) -> [ForumObject] {
        var objects = [ForumObject]()
        for row in rows {
            let dt = row.firstDescendantWithName("dt")
            guard let a = dt?.firstChildWithName("a"), let content = a.content, let link = a.attributes["href"] else { continue }
            objects.append(ForumObject(url:link , content:content))
        }
        return objects
    }
   
    func parseUrl() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
            
            let jiDoc = Ji(htmlURL: NSURL(string: self.page.pathUrl)!)
            self.page.switchContent()
            guard let array = jiDoc?.rootNode?.descendantsWithAttributeName("class", attributeValue: self.page.content) else { return }
            var objects = [ForumObject]()
            for message in array {
                var link = message.attributes["href"]!
                if !self.page.pathUrl.containsString("t="){
                    link = link.stringByReplacingOccurrencesOfString("./", withString: "http://forum.awd.ru/")
                    self.page.links.append(link)
                }
                objects.append(ForumObject(url: link, content: message.content!))
            }
            dispatch_async(dispatch_get_main_queue(), {
                self.messages = objects
                self.tableView.reloadData()
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50
        // Do any additional setup after loading the view, typically from a nib.
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        parseUrl()
        parseSections()
    }

    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
    }
    
    // MARK: - Segues
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let object = objects[indexPath.row] as! NSDate
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return headers.count
    }

    private func labelForHeader(inSection : Int) -> UILabel {
        let label = UILabel(frame: CGRectMake(2, 0, CGRectGetWidth(tableView.bounds) - 4, 0))
        label.text = headers[inSection].content
        label.textColor = UIColor.blackColor()
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.ByWordWrapping
        label.backgroundColor = UIColor.lightGrayColor()
        label.sizeToFit()
        return label
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return labelForHeader(section)
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGRectGetHeight(labelForHeader(section).frame)
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return headers[section].children.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ForumCell", forIndexPath: indexPath)
        let label = cell.contentView.subviews.first as! UILabel
        let message = self.headers[indexPath.section].children[indexPath.row]
        label.text = message.content
        return cell
    }
    
//    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    
//        let attrString = messages[indexPath.row]
//        let layouter = DTCoreTextLayouter(attributedString: attrString)
//        let maxRect = CGRectMake(8, 0, tableView.frame.size.width - 16, CGFloat(CGFLOAT_HEIGHT_UNKNOWN))
//        let entireString = NSMakeRange(0, attrString.length)
//        let layoutFrame = layouter.layoutFrameWithRect(maxRect, range: entireString)
//        let sizeNeeded = layoutFrame.frame.size
//        return sizeNeeded.height
//    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if !self.page.pathUrl.containsString("t="){
        let vc = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("MasterViewController") as!MasterViewController
        vc.page.lastPathUrl = self.page.pathUrl
        vc.page.pathUrl = self.page.links[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
        }
    }
}

