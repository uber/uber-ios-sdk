//
//  RequestButton.swift
//  Rides
//
//  Copyright © 2015 Uber Technologies, Inc. All rights reserved.
//

import UIKit


// RequestButton implements a button on the touch screen to request a ride.
public class RequestButton: UIButton {
    var deeplink: RequestDeeplink?
    var contentWidth: CGFloat = 0
    var contentHeight: CGFloat = 0
    let padding: CGFloat = 8
    let imageSize: CGFloat = 28
    var buttonStyle: UberButtonColorStyle
    
    let uberImageView: UIImageView!
    let uberTitleLabel: UILabel!
    
    override public var highlighted: Bool {
        didSet {
            if buttonStyle == .black {
                if highlighted {
                    //uberTitleLabel.textColor = UIColor.grayColor()
                    backgroundColor = uberUIColor(.blackHighlighted)
                } else {
                    //uberTitleLabel.textColor = UIColor.whiteColor()
                    backgroundColor = uberUIColor(.uberBlack)
                }
            } else if buttonStyle == .white {
                if highlighted {
                    //uberTitleLabel.textColor = UIColor.grayColor()
                    backgroundColor = uberUIColor(.whiteHighlighted)
                } else {
                    //uberTitleLabel.textColor = UIColor.blackColor()
                    backgroundColor = uberUIColor(.uberWhite)
                }
            }
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        buttonStyle = .black
        uberImageView = UIImageView()
        uberTitleLabel = UILabel()
        uberTitleLabel.numberOfLines = 1;
        super.init(coder: aDecoder)
        addSubview(uberImageView)
        addSubview(uberTitleLabel)
        setUp(.black)
    }
    
    public init(colorStyle: UberButtonColorStyle = .black) {
        buttonStyle = colorStyle
        uberImageView = UIImageView()
        uberTitleLabel = UILabel()
        uberTitleLabel.numberOfLines = 1;
        super.init(frame: CGRectZero)
        addSubview(uberImageView)
        addSubview(uberTitleLabel)
        setUp(colorStyle)
    }
    
    private func setUp(colorStyle: UberButtonColorStyle) {
        do {
            try setDeeplink()
            addTarget(self, action: "uberButtonTapped:", forControlEvents: .TouchUpInside)
        } catch UberButtonError.NullClientID {
            print("No Client ID attached to the deeplink.")
        } catch {
            print("Unknown Error")
        }
        
        setContent()
        setConstraints()
        setColorStyle(colorStyle)
    }
    
    // build and attach a deeplink to the button
    private func setDeeplink() throws {
        guard RidesClient.sharedInstance.hasClientID() else {
            throw UberButtonError.NullClientID
        }
        
        let clientID = RidesClient.sharedInstance.clientID
        deeplink = RequestDeeplink(withClientID: clientID!)
        deeplink!.build()
    }
    
    /**
     Set the user's current location as a default pickup location.
     */
    public func setPickupLocationToCurrentLocation() {
        if RidesClient.sharedInstance.hasClientID() {
            deeplink!.setPickupLocationToCurrentLocation()
            deeplink!.build()
        }
    }
    
    /**
     Set deeplink pickup location information.
     
     - parameter latitude:  The latitude coordinate for pickup
     - parameter longitude: The longitude coordinate for pickup
     - parameter nickname:  Optional pickup location name
     - parameter address:   Optional pickup location address
     */
    public func setPickupLocation(latitude lat: String, longitude: String, nickname: String? = nil, address: String? = nil) {
        if RidesClient.sharedInstance.hasClientID() {
            deeplink!.setPickupLocation(latitude: lat, longitude: longitude, nickname: nickname, address: address)
            deeplink!.build()
        }
    }
    
    /**
     Set deeplink dropoff location information.
     
     - parameter latitude:  The latitude coordinate for dropoff
     - parameter longitude: The longitude coordinate for dropoff
     - parameter nickname:  Optional dropoff location name
     - parameter address:   Optional dropoff location address
     */
    public func setDropoffLocation(latitude lat: String, longitude: String, nickname: String? = nil, address: String? = nil) {
        if RidesClient.sharedInstance.hasClientID() {
            deeplink!.setDropoffLocation(latitude: lat, longitude: longitude, nickname: nickname, address: address)
            deeplink!.build()
        }
    }
    
    /**
     Add a specific product ID to the deeplink. You can see product ID's for a given
     location with the Rides API `GET /v1/products` endpoint.
     
     - parameter productID: Unique identifier of the product to populate in pickup
     */
    public func setProductID(productID: String) {
        if RidesClient.sharedInstance.hasClientID() {
            deeplink!.setProductID(productID)
            deeplink!.build()
        }
    }
    
    // add title, image, and sizing configuration
    private func setContent() {
        // add title label
        uberTitleLabel.text = "Ride there with Uber"
        uberTitleLabel.font = UIFont.systemFontOfSize(17)
        
        // add image
        let badge = getImage("Badge")
        uberImageView.image = badge
        
        // update content sizes
        let titleSize = uberTitleLabel!.intrinsicContentSize()
        contentWidth += titleSize.width + badge.size.width
        contentHeight = max(titleSize.height, badge.size.height)
        
        // rounded corners
        clipsToBounds = true
        layer.cornerRadius = 5
        
        // set to false for constraint-based layouts
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    // get image from media directory
    private func getImage(name: String) -> UIImage {
        let bundle = NSBundle(forClass: RequestButton.self)
        let image = UIImage(named: name, inBundle: bundle, compatibleWithTraitCollection: nil)
        return image!
    }
    
    private func setConstraints() {
        // store constraints and metrics in dictionaries
        let views = ["image": uberImageView!, "label": uberTitleLabel!]
        let metrics = ["padding": padding, "imageSize": imageSize]
        
        // set to false for constraint-based layouts
        uberImageView?.translatesAutoresizingMaskIntoConstraints = false
        uberTitleLabel?.translatesAutoresizingMaskIntoConstraints = false
        
        // prioritize constraints
        uberTitleLabel.setContentCompressionResistancePriority(UILayoutPriorityDefaultLow, forAxis: .Horizontal)
        
        // create layout constraints
        let horizontalConstraint: NSArray = NSLayoutConstraint.constraintsWithVisualFormat("H:|-padding-[image(24)]-padding-[label]-padding-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: views)
        let imageVerticalViewConstraint: NSArray = NSLayoutConstraint.constraintsWithVisualFormat("V:|-[image(24)]-|", options: NSLayoutFormatOptions.AlignAllLeading, metrics: nil, views: views)
        let labelVerticalViewConstraint: NSArray = NSLayoutConstraint.constraintsWithVisualFormat("V:|-padding-[label]-padding-|", options: NSLayoutFormatOptions.AlignAllLeading, metrics: metrics, views: views)
        
        // add layout constraints
        addConstraints(horizontalConstraint as! [NSLayoutConstraint])
        addConstraints(imageVerticalViewConstraint as! [NSLayoutConstraint])
        addConstraints(labelVerticalViewConstraint as! [NSLayoutConstraint])
    }
    
    // set color scheme, default is black background with white font
    private func setColorStyle(style: UberButtonColorStyle) {
        buttonStyle = style
        
        switch style {
        case .black:
            uberTitleLabel.textColor = uberUIColor(.uberWhite)
            backgroundColor = uberUIColor(.uberBlack)
        case .white :
            uberTitleLabel.textColor = uberUIColor(.uberBlack)
            backgroundColor = uberUIColor(.uberWhite)
        }
    }
    
    public override func intrinsicContentSize() -> CGSize {
        let width = (3 * padding) + contentWidth
        let height = (2 * padding) + contentHeight
        return CGSizeMake(width, height)
    }
    
    // initiate deeplink when button is tapped
    public func uberButtonTapped(sender: UIButton) {
        if RidesClient.sharedInstance.hasClientID() {
            deeplink!.execute()
        }
    }
}

public enum UberButtonColorStyle {
    case black
    case white
}

public enum UberButtonError: ErrorType {
    case NullClientID
}
