//
//  RideRequestButton.swift
//  UberRides
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
import CoreLocation

/// RequestButton implements a button on the touch screen to request a ride.
@objc(UBSDKRideRequestButton) public class RideRequestButton: UberButton {
    
    /// The RideParameters object this button will use to make a request
    public var rideParameters: RideParameters
    
    /// The RideRequesting object the button will use to make a request
    public var requestBehavior: RideRequesting
    
    static let sourceString = "button"
    
    /**
     Initializer to use in storyboard.
     requestBehavior defaults to DeeplinkRequestingBehavior
     rideParameters defaults to RideParameters with pickup location set to current location
     */
    required public init?(coder aDecoder: NSCoder) {
        requestBehavior = DeeplinkRequestingBehavior()
        rideParameters = RideParametersBuilder().build()
        super.init(coder: aDecoder)
        setUp()
    }
    
     /**
     The Request button initializer.
     
     - parameter rideParameters:        The RideParameters for this button. These parameters are used to request a ride when the button is tapped.
     - parameter requestingBehavior:    The RideRequesting object to use for requesting a ride.
     
     - returns: An initialized RideRequestButton
     */
    @objc public init(rideParameters: RideParameters, requestingBehavior: RideRequesting) {
        requestBehavior = requestingBehavior
        self.rideParameters = rideParameters
        super.init(frame: CGRectZero)
        setUp()
    }
    
    /**
     The RideRequestButton initializer. Creates a request button that uses the Deeplink
     Requesting behavior & the provided RidesParameters
     
     - parameter rideParameters: The RideParameters for this button. These parameters are used to request a ride when the button is tapped.
     
     - returns: An initialized RideRequestButton
     */
    @objc public convenience init(rideParameters: RideParameters) {
        self.init(rideParameters: rideParameters, requestingBehavior: DeeplinkRequestingBehavior())
    }
    
    /**
     The RideRequestButton initializer.
     Defaults to using the current location for pickup
     
     - parameter requestingBehavior: The RideRequesting object to use for requesting a ride.
     
     - returns: An initialized RideRequestButton
     */
    @objc public convenience init(requestingBehavior: RideRequesting) {
        self.init(rideParameters: RideParametersBuilder().build(), requestingBehavior: requestingBehavior)
    }
    
    /**
     The Request button initializer.
     Defaults to using the current location for pickup
     Defaults to DeeplinkRequestingBehavior, which links into the Uber app
     
     - returns: An initialized RideRequestButton
     */
    @objc public convenience init() {
        self.init(rideParameters: RideParametersBuilder().build(), requestingBehavior: DeeplinkRequestingBehavior())
    }
    
    private func setUp() {
        addTarget(self, action: Selector("uberButtonTapped:"), forControlEvents: .TouchUpInside)
        setContent()
        setConstraints()
        sizeToFit()
    }
    
    // add title, image, and sizing configuration
    override func setContent() {
        super.setContent()
        
        uberTitleLabel.font = UIFont.systemFontOfSize(17)
        uberTitleLabel.numberOfLines = 2;
        uberTitleLabel.textAlignment = .Right
        
        // Add title label
        let titleText = LocalizationUtil.localizedString(forKey: "Ride there with Uber", comment: "Request button description")
        uberTitleLabel.text = titleText
        
        // add image
        let logo = getImage("Badge")
        uberImageView.image = logo
        uberImageView.contentMode = .Center
    }
    
    // get image from media directory
    private func getImage(name: String) -> UIImage {
        let bundle = NSBundle(forClass: RideRequestButton.self)
        let image = UIImage(named: name, inBundle: bundle, compatibleWithTraitCollection: nil)
        return image!
    }
    
    override func setConstraints() {
        addSubview(uberImageView)
        addSubview(uberTitleLabel)
        
        uberTitleLabel?.translatesAutoresizingMaskIntoConstraints = false
        uberImageView?.translatesAutoresizingMaskIntoConstraints = false
        
        let imageSize = uberImageView?.image?.size.height ?? 0
        
        let views = ["image": uberImageView!, "label": uberTitleLabel!]
        let metrics = ["imagePadding": horizontalImagePadding, "verticalPadding": verticalPadding, "labelPadding": horizontalLabelPadding, "middlePadding":imageLabelPadding, "imageSize": imageSize]
        
        uberTitleLabel.setContentHuggingPriority(UILayoutPriorityDefaultLow, forAxis: .Horizontal)
        uberTitleLabel.setContentHuggingPriority(UILayoutPriorityDefaultHigh, forAxis: .Vertical)
        
        let horizontalConstraint: [NSLayoutConstraint] = NSLayoutConstraint.constraintsWithVisualFormat("H:|-imagePadding-[image]-middlePadding-[label]-(>=labelPadding)-|", options: .AlignAllCenterY, metrics: metrics, views: views)
        let verticalConstraint: [NSLayoutConstraint] = NSLayoutConstraint.constraintsWithVisualFormat("V:|-verticalPadding-[image]-verticalPadding-|", options: .AlignAllLeading, metrics: metrics, views: views)
        
        addConstraints(horizontalConstraint)
        addConstraints(verticalConstraint)
        addConstraint(NSLayoutConstraint(item: self, attribute: .CenterY, relatedBy: .Equal, toItem: uberImageView, attribute: .CenterY, multiplier: 1.0, constant: 0))
    }
    
    override public func sizeThatFits(size: CGSize) -> CGSize {
        let logoSize = uberImageView.image?.size ?? CGSizeZero
        let titleSize = uberTitleLabel.intrinsicContentSize()
        let width: CGFloat = horizontalLabelPadding + horizontalImagePadding + imageLabelPadding + logoSize.width + titleSize.width
        let height: CGFloat = 2 * verticalPadding + max(logoSize.height, titleSize.height)
        return CGSizeMake(width, height)
    }
    
    // initiate deeplink when button is tapped
    func uberButtonTapped(sender: UIButton) {
        rideParameters.source = RideRequestButton.sourceString
        
        requestBehavior.requestRide(rideParameters)
    }
}

// MARK: RideRequestButton structures

@objc public enum RequestButtonColorStyle: Int {
    case Black
    case White
}
