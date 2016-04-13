//
//  DeeplinkExampleViewController.swift
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
import CoreLocation

/// This class provides an example for using the RideRequestButton to initiate a deeplink
/// into the Uber app
class DeeplinkExampleViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Deeplink Buttons"
        
        // create background UIViews
        let topView = UIView()
        view.addSubview(topView)
        let bottomView = UIView()
        view.addSubview(bottomView)
        
        // add black request button with default configurations
        let blackRequestButton = RideRequestButton()
        topView.addSubview(blackRequestButton)
        
        // add white request button and add custom configurations
        let whiteRequestButton = RideRequestButton()
        
        //Create the DeeplinkRequestingBehavior
        //The RideRequestButton is initialized with this behavior by default, shown
        //as an example
        let deeplinkBehavior = DeeplinkRequestingBehavior()
        whiteRequestButton.requestBehavior = deeplinkBehavior
        
        whiteRequestButton.colorStyle = .White
        let parameterBuilder = RideParametersBuilder()
        parameterBuilder.setProductID("a1111c8c-c720-46c3-8534-2fcdd730040d")
        let pickupLocation = CLLocation(latitude: 37.770, longitude: -122.466)
        parameterBuilder.setPickupLocation(pickupLocation, nickname: "California Academy of Sciences")
        let dropoffLocation = CLLocation(latitude: 37.791, longitude: -122.405)
        parameterBuilder.setDropoffLocation(dropoffLocation, nickname: "Pier 39")

        whiteRequestButton.rideParameters = parameterBuilder.build()
        
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
    func centerButton(forButton button: RideRequestButton, inView: UIView) {
        button.translatesAutoresizingMaskIntoConstraints = false
        
        // position constraints
        let horizontalConstraint = NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: inView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        let verticalConstraint = NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: inView, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0)
        
        // add constraints to view
        inView.addConstraints([horizontalConstraint, verticalConstraint])
    }
}

