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
    var parser = ForumParser()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50
        // Do any additional setup after loading the view, typically from a nib.
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
            self.parser.parseSections()
            self.tableView.reloadData()
    }

    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
    }
    
    // MARK: - Segues
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.parser.headers.count
    }

    private func labelForHeader(inSection : Int) -> UILabel {
        let label = UILabel(frame: CGRectMake(2, 0, CGRectGetWidth(tableView.bounds) - 4, 0))
        label.text = self.parser.headers[inSection].content
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
        return self.parser.headers[section].children.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ForumCell", forIndexPath: indexPath)
        let label = cell.contentView.subviews.first as! UILabel
        label.text = self.parser.getCellContent(indexPath)
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
        
        if !self.parser.page.pathUrl.containsString("t="){
            let vc = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("MasterViewController") as!MasterViewController
            self.parser.nextPageUrl(vc, indexPath: indexPath)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

