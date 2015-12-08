//
//  ViewController.swift
//  Swift SDK
//
//  Copyright © 2015 Uber Technologies, Inc. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import UIKit
import UberRides

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create background UIViews
        let topView = UIView()
        view.addSubview(topView)
        let bottomView = UIView()
        view.addSubview(bottomView)
        
        // add black request button with default configurations
        let blackRequestButton = RequestButton()
        topView.addSubview(blackRequestButton)
        
        // add white request button and add custom configurations
        let whiteRequestButton = RequestButton(colorStyle: .White)
        whiteRequestButton.setProductID("a1111c8c-c720-46c3-8534-2fcdd730040d")
        whiteRequestButton.setPickupLocation(latitude: "37.770", longitude: "-122.466", nickname: "California Academy of Sciences")
        whiteRequestButton.setDropoffLocation(latitude: "37.791", longitude: "-122.405", nickname: "Pier 39")
        bottomView.addSubview(whiteRequestButton)
        
        // position UIViews and request buttons
        setUpBackgroundViews(top: topView, bottom: bottomView)
        centerButton(forButton: blackRequestButton, inView: topView)
        centerButton(forButton: whiteRequestButton, inView: bottomView)
    }
    
    // set up two white and black background UIViews with autolayout constraints
    func setUpBackgroundViews(top topView: UIView, bottom: UIView) {
        topView.backgroundColor = UIColor.whiteColor()
        bottom.backgroundColor = UIColor.blackColor()
        topView.translatesAutoresizingMaskIntoConstraints = false
        bottom.translatesAutoresizingMaskIntoConstraints = false
        
        // pass views in dictionary
        let views = ["top": topView, "bottom": bottom]
        
        // position constraints
        let horizontalTopConstraint = NSLayoutConstraint.constraintsWithVisualFormat("H:|[top]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        let horizontalBottomConstraint = NSLayoutConstraint.constraintsWithVisualFormat("H:|[bottom]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        let verticalConstraint = NSLayoutConstraint.constraintsWithVisualFormat("V:|[top(bottom)][bottom]|", options: NSLayoutFormatOptions.AlignAllLeading, metrics: nil, views: views)
        
        // add constraints to view
        view.addConstraints(horizontalTopConstraint)
        view.addConstraints(horizontalBottomConstraint)
        view.addConstraints(verticalConstraint)
    }
    
    // center button position inside each background UIView
    func centerButton(forButton button: RequestButton, inView: UIView) {
        button.translatesAutoresizingMaskIntoConstraints = false
        
        // position constraints
        let horizontalConstraint = NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: inView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        let verticalConstraint = NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: inView, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0)
        
        // add constraints to view
        inView.addConstraints([horizontalConstraint, verticalConstraint])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

