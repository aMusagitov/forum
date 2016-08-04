//
//  ViewController.swift
//  HTMLStringTest
//
//  Created by Ruslan Musagitov on 20/07/16.
//  Copyright © 2016 Synergy. All rights reserved.
//

import UIKit
import Ji
import DTCoreText

class MessagesViewController: UIViewController {
    var messages : [MessageObject]? {
        didSet {
            tableView.reloadData()
        }
    }
    
    var url : String! {
        didSet {
            parse()
        }
    }
        
    var sampleCell : MessageTableViewCell!
    
    @IBOutlet weak var tableView : UITableView!
    
    private func parse() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
            let jiDoc = Ji(htmlURL: NSURL(string: self.url)!)
            guard let contentsArray = jiDoc?.rootNode?.descendantsWithAttributeName("class", attributeValue: "content") else { return }
            guard let authorsArray = jiDoc?.rootNode?.descendantsWithAttributeName("class", attributeValue: "author") else { return }
            guard let messagesOrder = jiDoc?.rootNode?.descendantsWithAttributeName("style", attributeValue: "float: right;") else { return }
            guard let avatarsArray = jiDoc?.rootNode?.descendantsWithAttributeName("class", attributeValue: "postprofile") else { return }
            var objects = [MessageObject]()
            var avatar = ""
            print(contentsArray.count)
            print(authorsArray.count)
            print(messagesOrder.count)
            print(avatarsArray.count)
            for i in 0..<contentsArray.count {
                var j = 0
                let str = NSMutableString(string: contentsArray[i].rawContent!)
                let authorAndTime = authorsArray[i].content?.componentsSeparatedByString(" » ")
                let content = NSAttributedString(HTMLData: str.dataUsingEncoding(NSUTF8StringEncoding), documentAttributes: nil)
                if authorsArray[i].lastChild?.content == "Гость" {
                    objects.append(MessageObject(time: authorAndTime![1], content: content, author: AuthorObject(name: authorAndTime![0], profileUrl: "", avatar: "")))
                    j--
                } else {
                guard var url = authorsArray[i].lastChild?.firstChild!.attributes["href"] else {return}
                    if let a = avatarsArray[j].firstDescendantWithName("a"){
                        if a.attributes["href"]! == url{
                            if let img = (a.firstChildWithName("img")?.attributes["src"]){
                                avatar = img.stringByReplacingOccurrencesOfString("/.", withString: "http://forum.awd.ru")
                                url = url.stringByReplacingOccurrencesOfString(".", withString: "http://forum.awd.ru")
                            }
                        }
                    }
                    j++
                    //                let options = [DTDefaultTextColor : UIColor.blackColor(), DTDefaultFontFamily : "Helvetica Neue"]
                    objects.append(MessageObject(time: authorAndTime![1], content: content, author: AuthorObject(name: authorAndTime![0], profileUrl: url, avatar: avatar)))
                }
            }
            dispatch_async(dispatch_get_main_queue(), {
                self.messages = objects
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sampleCell = self.tableView.dequeueReusableCellWithIdentifier("MessageTableViewCell") as! MessageTableViewCell
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sampleCell.frame.size.width = tableView.bounds.size.width
        sampleCell.contentView.frame.size.width = tableView.bounds.size.width
        sampleCell.contentTextView.frame.size.width = tableView.bounds.size.width
    }
}
extension MessagesViewController: UITableViewDataSource, UITableViewDelegate, MessageTableViewCellDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let array = messages else { return 0 }
        return array.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MessageTableViewCell") as! MessageTableViewCell
        cell.tableView = tableView
        cell.delegate = self
        cell.setContent(messages![indexPath.row].content)
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let attrString = messages![indexPath.row].content
        let layouter = DTCoreTextLayouter(attributedString: attrString)
        let maxRect = CGRectMake(2, 0, tableView.frame.size.width - 4, CGFloat(CGFLOAT_HEIGHT_UNKNOWN))
        let entireString = NSMakeRange(0, attrString.length)
        let layoutFrame = layouter.layoutFrameWithRect(maxRect, range: entireString)
        let sizeNeeded = layoutFrame.frame.size
        if sizeNeeded.height > 250
        {
            return 250
        }
        return sizeNeeded.height

    }
    
    func messageTableViewCellReadAllButtonSelected(cell: MessageTableViewCell) {
        performSegueWithIdentifier("segue:messages-message", sender: cell)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let cell = sender as? MessageTableViewCell else { return }
        guard let vc = segue.destinationViewController as? MessageViewController else { return }
        let indexPath = tableView.indexPathForCell(cell)!
        print(vc.view)
        vc.textView.attributedText = messages![indexPath.row].content
    }
}

protocol MessageTableViewCellDelegate : class {
    func messageTableViewCellReadAllButtonSelected(cell : MessageTableViewCell)
}

class MessageTableViewCell: UITableViewCell, DTAttributedTextContentViewDelegate, DTLazyImageViewDelegate {
    @IBOutlet weak var contentTextView: DTAttributedTextView!
    @IBOutlet weak var readAllButton: UIButton!
    weak var tableView : UITableView!
    
    weak var delegate : MessageTableViewCellDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentTextView.textDelegate = self
    }
    
    override func prepareForReuse() {
        readAllButton.hidden = true
    }
    
    @IBAction func readAllButtonSelected(sender: AnyObject) {
        delegate.messageTableViewCellReadAllButtonSelected(self)
    }
    
    func setContent(html : NSAttributedString) {
        contentTextView.attributedString = html
    }
    
    func attributedTextContentView(attributedTextContentView: DTAttributedTextContentView!, viewForAttachment attachment: DTTextAttachment!, frame: CGRect) -> UIView! {
        if attachment.isKindOfClass(DTTextAttachment) {
            let imageView = DTLazyImageView(frame: frame)
            imageView.delegate = self
            imageView.contentMode = .ScaleAspectFit
                imageView.url = attachment.contentURL
            print("start \(attachment.contentURL)")
            return imageView
        }
        return nil
    }
    
    func lazyImageView(lazyImageView: DTLazyImageView!, didChangeImageSize size: CGSize) {
        let url = lazyImageView.url
        let pred = NSPredicate(format: "contentURL == %@", url)
        print("end \(url)")
        for oneAttachment in contentTextView.attributedTextContentView.layoutFrame.textAttachmentsWithPredicate(pred) {
            guard let attach = oneAttachment as? DTTextAttachment else { continue }
            attach.originalSize = size
            let displayWidth = contentTextView.frame.size.width
            let ratio = size.width / size.height
            let displayHeight = displayWidth / ratio
            attach.displaySize = CGSizeMake(displayWidth,  displayHeight)
            break
        }
    
        if(CGRectIntersectsRect(lazyImageView.frame, CGRectMake(tableView.contentOffset.x, tableView.contentOffset.y, tableView.frame.size.width, tableView.frame.size.height))) {
            print("RELAYOUT")
            self.contentTextView.attributedTextContentView.layouter = nil
            self.contentTextView.attributedTextContentView.relayoutText()
        }
    }
    
}

class UnscrollableTextView : UITextView {
    var shrinked = false
    override var attributedText: NSAttributedString! {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    override func intrinsicContentSize() -> CGSize {
        guard let cell = superview?.superview as?MessageTableViewCell else { return contentSize }
        let numberOfLines = self.contentSize.height/self.font!.lineHeight
        shrinked = numberOfLines > 30
        if shrinked {
            let height = 30*self.font!.lineHeight
            cell.readAllButton.hidden = false
            return CGSizeMake(contentSize.width, height)
        }
        cell.readAllButton.hidden = true
        return contentSize
    }
}