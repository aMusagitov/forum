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
    var messages = [NSAttributedString]()
    let page = ForumPage()

    override func viewDidAppear(animated: Bool) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
            
            let jiDoc = Ji(htmlURL: NSURL(string: self.page.pathUrl)!)
            self.page.switchContent()
            guard let array = jiDoc?.rootNode?.descendantsWithAttributeName("class", attributeValue: self.page.content) else { return }
            var objects = [NSAttributedString]()
            for message in array {
//                let options = [DTDefaultTextColor : UIColor.blackColor(), DTDefaultFontFamily : "Helvetica Neue"]
                let str = NSMutableString(string: message.rawContent!)
//                print("\(str.length)")
                if !self.page.pathUrl.containsString("t="){
                var link = message.attributes["href"]!
                link = link.stringByReplacingOccurrencesOfString("./", withString: "http://forum.awd.ru/")
                self.page.links.append(link)
                }
                
                str.removeTrailingWhitespace()
//                print("\(str.length)")
                let attributedString = NSAttributedString(HTMLData: str.dataUsingEncoding(NSUTF8StringEncoding), documentAttributes: nil)
                objects.append(attributedString)
            }
            dispatch_async(dispatch_get_main_queue(), {
                self.messages = objects
                print(self.messages.count)
                self.tableView.reloadData()
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }

    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func insertNewObject(sender: AnyObject) {
        self.messages.insert(NSAttributedString(), atIndex: 0)
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
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
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ForumCell", forIndexPath: indexPath)
        let label = cell.contentView.subviews.first as! DTAttributedLabel
        label.attributedString = self.messages[indexPath.row]
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let attrString = messages[indexPath.row]
        let layouter = DTCoreTextLayouter(attributedString: attrString)
        let maxRect = CGRectMake(8, 0, tableView.frame.size.width - 16, CGFloat(CGFLOAT_HEIGHT_UNKNOWN))
        let entireString = NSMakeRange(0, attrString.length)
        let layoutFrame = layouter.layoutFrameWithRect(maxRect, range: entireString)
        let sizeNeeded = layoutFrame.frame.size
        return sizeNeeded.height
    }
    
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

