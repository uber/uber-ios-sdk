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
public class DeeplinkExampleViewController: ButtonExampleViewController {

    let blackRequestButton = RideRequestButton()
    let whiteRequestButton = RideRequestButton()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Deeplink Buttons"
        
        topView.addSubview(blackRequestButton)
        bottomView.addSubview(whiteRequestButton)
        
        initialSetup()
        addBlackRequestButtonConstraints()
        addWhiteRequestButtonConstraints()
    }
    
    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        whiteRequestButton.loadRideInformation()
    }
    
    // Mark: Private Interface
    
    private func initialSetup() {
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
    }
    
    private func addBlackRequestButtonConstraints() {
        blackRequestButton.translatesAutoresizingMaskIntoConstraints = false
        
        let centerYConstraint = NSLayoutConstraint(item: blackRequestButton, attribute: .CenterY, relatedBy: .Equal, toItem: topView, attribute: .CenterY, multiplier: 1.0, constant: 0.0)
        let centerXConstraint = NSLayoutConstraint(item: blackRequestButton, attribute: .CenterX, relatedBy: .Equal, toItem: topView, attribute: .CenterX, multiplier: 1.0, constant: 0.0)
        
        topView.addConstraints([centerYConstraint, centerXConstraint])
    }
    
    private func addWhiteRequestButtonConstraints() {
        whiteRequestButton.translatesAutoresizingMaskIntoConstraints = false
        
        let centerYConstraint = NSLayoutConstraint(item: whiteRequestButton, attribute: .CenterY, relatedBy: .Equal, toItem: bottomView, attribute: .CenterY, multiplier: 1.0, constant: 0.0)
        let centerXConstraint = NSLayoutConstraint(item: whiteRequestButton, attribute: .CenterX, relatedBy: .Equal, toItem: bottomView, attribute: .CenterX, multiplier: 1.0, constant: 0.0)
        
        bottomView.addConstraints([centerYConstraint, centerXConstraint])
    }
}

