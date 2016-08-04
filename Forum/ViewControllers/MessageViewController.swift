//
//  MessageViewController.swift
//  HTMLStringTest
//
//  Created by Ruslan Musagitov on 22/07/16.
//  Copyright © 2016 Synergy. All rights reserved.
//

import UIKit

class MessageViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var textView : UITextView!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        dispatch_async(dispatch_get_main_queue()) {
            self.textView.textContainer.lineFragmentPadding = 0
            self.textView.textContainerInset = UIEdgeInsetsMake(0, 2, 0, 0)
            self.textView.setContentOffset(CGPointZero, animated: false)
            self.textView.delegate = self
        }
    }

    func textView(textView: UITextView, shouldInteractWithTextAttachment textAttachment: NSTextAttachment, inRange characterRange: NSRange) -> Bool {
        guard let wrapper = textAttachment.fileWrapper, data = wrapper.regularFileContents, let image = UIImage(data: data) else { return false }
        print(image.size)
        performSegueWithIdentifier("segue:message-image", sender: image)
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let vc = segue.destinationViewController as? ZoomedPhotoViewController else { return }
        print(vc.view)
        vc.imageView.image = sender as? UIImage
    }
}

/*
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import DTCoreText

class ZoomedPhotoViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTrailingConstraint: NSLayoutConstraint!
    
    var photoName: String!
    
    private func updateMinZoomScaleForSize(size: CGSize) {
        let widthScale = size.width / imageView.bounds.width
        let heightScale = size.height / imageView.bounds.height
        let minScale = min(widthScale, heightScale)
        // 2
        scrollView.minimumZoomScale = minScale
        // 3
        scrollView.zoomScale = minScale
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 4
        updateMinZoomScaleForSize(view.bounds.size)
    }
    
    private func updateConstraintsForSize(size: CGSize) {
        // 2
        let yOffset = max(0, (size.height - imageView.frame.height) / 2)
        imageViewTopConstraint.constant = yOffset
        imageViewBottomConstraint.constant = yOffset
        // 3
        let xOffset = max(0, (size.width - imageView.frame.width) / 2)
        imageViewLeadingConstraint.constant = xOffset
        imageViewTrailingConstraint.constant = xOffset
        
        view.layoutIfNeeded()
    }
    
}

extension ZoomedPhotoViewController: UIScrollViewDelegate {
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        // 1
        return imageView
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        updateConstraintsForSize(view.bounds.size)  // 4
    }
    
}
