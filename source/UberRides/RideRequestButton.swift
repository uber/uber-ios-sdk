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

/**
 *  Protocol to listen to request button events, such as loading button content
 */
@objc(UBSDKRideRequestButtonDelegate) public protocol RideRequestButtonDelegate {
    /**
     The button finished loading ride information successfully.
     
     - parameter button: the RideRequestButton
     */
    @objc func rideRequestButtonDidLoadRideInformation(_ button: RideRequestButton)
    
    /**
     The button encountered an error when refreshing its metadata content.
     
     - parameter button: the RideRequestButton
     - parameter error:  the error that it encountered
     */
    @objc func rideRequestButton(_ button: RideRequestButton, didReceiveError error: RidesError)
}

/// RequestButton implements a button on the touch screen to request a ride.
@objc(UBSDKRideRequestButton) open class RideRequestButton: UberButton {
    /// Delegate is informed of events that occur with request button.
    open var delegate: RideRequestButtonDelegate?
    
    /// The RideParameters object this button will use to make a request
    open var rideParameters: RideParameters
    
    /// The RideRequesting object the button will use to make a request
    open var requestBehavior: RideRequesting
    
    /// The RidesClient used for retrieving metadata for the button.
    open var client: RidesClient?
    
    static let sourceString = "button"
    
    var metadata: ButtonMetadata = ButtonMetadata()
    var uberMetadataLabel: UILabel = UILabel()
    
    fileprivate let opticalCorrection: CGFloat = 1.0
    
    /**
     Initializer to use in storyboard. Must call setRidesClient for request button to show metadata.
     requestBehavior defaults to DeeplinkRequestingBehavior
     rideParameters defaults to RideParameters with pickup location set to current location
     */
    required public init?(coder aDecoder: NSCoder) {
        requestBehavior = DeeplinkRequestingBehavior()
        rideParameters = RideParametersBuilder().build()
        super.init(coder: aDecoder)
    }
    
     /**
     The Request button initializer.
     
     - parameter client:                The RidesClient to use for getting button metadata
     - parameter rideParameters:        The RideParameters for this button. These parameters are used to request a ride when the button is tapped.
     - parameter requestingBehavior:    The RideRequesting object to use for requesting a ride.
     
     - returns: An initialized RideRequestButton
     */
    @objc public init(client: RidesClient, rideParameters: RideParameters, requestingBehavior: RideRequesting) {
        requestBehavior = requestingBehavior
        self.rideParameters = rideParameters
        super.init(frame: CGRect.zero)
        self.client = client
    }
    
    /**
     The Request button initializer.
     Uses a default RidesClient
     
     - parameter rideParameters:        The RideParameters for this button. These parameters are used to request a ride when the button is tapped.
     - parameter requestingBehavior:    The RideRequesting object to use for requesting a ride.
     
     - returns: An initialized RideRequestButton
     */
    @objc public convenience init(rideParameters: RideParameters, requestingBehavior: RideRequesting) {
        self.init(client: RidesClient(), rideParameters: rideParameters, requestingBehavior: requestingBehavior)
    }
    
    /**
     The RideRequestButton initializer.
     Uses DeeplinkRequestingBehavior by default
     Defaults to using the current location for pickup
     
     - parameter client: The RidesClient to use for getting button metadata
     
     - returns: An initialized RideRequestButton
     */
    @objc public convenience init(client: RidesClient) {
        self.init(client: client, rideParameters: RideParametersBuilder().build(), requestingBehavior: DeeplinkRequestingBehavior())
    }
    
    /**
     The RideRequestButton initializer. Creates a request button that uses the Deeplink
     Requesting behavior & the provided RidesParameters
     Uses a default RidesClient
     
     - parameter rideParameters: The RideParameters for this button. These parameters are used to request a ride when the button is tapped.
     
     - returns: An initialized RideRequestButton
     */
    @objc public convenience init(rideParameters: RideParameters) {
        self.init(client: RidesClient(), rideParameters: rideParameters, requestingBehavior: DeeplinkRequestingBehavior())
    }
    
    /**
     The RideRequestButton initializer.
     Defaults to using the current location for pickup
     Uses a default RidesClient
     
     - parameter requestingBehavior: The RideRequesting object to use for requesting a ride.
     
     - returns: An initialized RideRequestButton
     */
    @objc public convenience init(requestingBehavior: RideRequesting) {
        self.init(client: RidesClient(), rideParameters: RideParametersBuilder().build(), requestingBehavior: requestingBehavior)
    }
    
    //Mark: UberButton
    
    /**
     The Request button initializer.
     Defaults to using the current location for pickup
     Defaults to DeeplinkRequestingBehavior, which links into the Uber app
     Uses a default RidesClient
     
     - returns: An initialized RideRequestButton
     */
    @objc public convenience init() {
        self.init(client: RidesClient(), rideParameters: RideParametersBuilder().build(), requestingBehavior: DeeplinkRequestingBehavior())
    }
    
    /**
     Setup the RideRequestButton by adding  a target to the button and setting the login completion block
     */
    override open func setup() {
        super.setup()
        addTarget(self, action: #selector(uberButtonTapped(_:)), for: .touchUpInside)
        sizeToFit()
    }
    
    /**
     Adds the Metadata Label to the button
     */
    override open func addSubviews() {
        super.addSubviews()
        addSubview(uberMetadataLabel)
    }
    
    /**
     Updates the content of the button. Sets the image icon and font, as well as the text
     */
    override open func setContent() {
        super.setContent()
        
        uberMetadataLabel.numberOfLines = 2
        uberMetadataLabel.textColor = colorStyle == .black ? ColorUtil.colorForUberButtonColor(.uberWhite) : ColorUtil.colorForUberButtonColor(.uberBlack)
        uberMetadataLabel.textAlignment = .right
        
        uberTitleLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 15) ?? UIFont.systemFont(ofSize: 16)
        
        let titleText = LocalizationUtil.localizedString(forKey: "Ride there with Uber", comment: "Request button description")
        uberTitleLabel.text = titleText
        
        let logo = getImage("Badge")
        uberImageView.image = logo
        uberImageView.contentMode = .center
    }
    
    /**
     Adds the layout constraints for the ride request button.
     */
    override open func setConstraints() {
        
        uberTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        uberImageView.translatesAutoresizingMaskIntoConstraints = false
        uberMetadataLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let views = ["image": uberImageView, "titleLabel": uberTitleLabel, "metadataLabel": uberMetadataLabel]
        let metrics = ["edgePadding": horizontalEdgePadding, "verticalPadding": verticalPadding, "imageLabelPadding": imageLabelPadding, "middlePadding": horizontalEdgePadding*2]
        
        uberImageView.setContentHuggingPriority(UILayoutPriorityDefaultHigh, for: .horizontal)
        uberTitleLabel.setContentHuggingPriority(UILayoutPriorityDefaultHigh, for: .horizontal)
        uberTitleLabel.setContentHuggingPriority(UILayoutPriorityDefaultHigh, for: .vertical)
        uberMetadataLabel.setContentHuggingPriority(UILayoutPriorityDefaultLow, for: .horizontal)
        
        let horizontalConstraints: [NSLayoutConstraint] = NSLayoutConstraint.constraints(withVisualFormat: "H:|-edgePadding-[image]-imageLabelPadding-[titleLabel]-middlePadding-[metadataLabel]-edgePadding-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: views)
        let verticalConstraints: [NSLayoutConstraint] = NSLayoutConstraint.constraints(withVisualFormat: "V:|-verticalPadding-[image]-verticalPadding-|", options: .alignAllLeading, metrics: metrics, views: views)
        
        let titleLabelCenterConstraint = NSLayoutConstraint(item: self,
                                                            attribute: .centerY,
                                                            relatedBy: .equal,
                                                            toItem: uberTitleLabel,
                                                            attribute: .centerY,
                                                            multiplier: 1.0,
                                                            constant: opticalCorrection)
        let metadataLabelCenterConstraint = NSLayoutConstraint(item: self,
                                                               attribute: .centerY,
                                                               relatedBy: .equal,
                                                               toItem: uberMetadataLabel,
                                                               attribute: .centerY,
                                                               multiplier: 1.0,
                                                               constant: 0)
        let imageViewCenterConstraint = NSLayoutConstraint(item: self,
                                                           attribute: .centerY,
                                                           relatedBy: .equal,
                                                           toItem: uberImageView,
                                                           attribute: .centerY,
                                                           multiplier: 1.0,
                                                           constant: 0)
        
        addConstraints(horizontalConstraints)
        addConstraints(verticalConstraints)
        addConstraints([titleLabelCenterConstraint, metadataLabelCenterConstraint, imageViewCenterConstraint])
    }
    
    override func colorStyleDidUpdate(_ style: RequestButtonColorStyle) {
        super.colorStyleDidUpdate(style)
        
        switch style {
        case .black:
            uberMetadataLabel.textColor = ColorUtil.colorForUberButtonColor(.uberWhite)
        case .white :
            uberMetadataLabel.textColor = ColorUtil.colorForUberButtonColor(.uberBlack)
        }
    }
    
    //Mark: UIView
    
    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        let logoSize = uberImageView.image?.size ?? CGSize.zero
        let titleSize = uberTitleLabel.intrinsicContentSize
        let metadataSize = uberMetadataLabel.intrinsicContentSize
        var width: CGFloat = 4*horizontalEdgePadding + imageLabelPadding + logoSize.width + titleSize.width
        var height: CGFloat = 2*verticalPadding + max(logoSize.height, titleSize.height)
        
        if let _ = metadata.productID {
            width += metadataSize.width
            height = max(height, metadataSize.height)
        }
        
        return CGSize(width: width, height: height)
    }
    
    //Mark: Public Interface
    
    /**
     Manual refresh for the ride information on the button. The product ID must be set in order to show any metadata.
     */
    open func loadRideInformation() {
        guard client != nil else {
            return
        }
        
        metadata.productID = rideParameters.productID
        metadata.pickupLatitude = rideParameters.pickupLocation?.coordinate.latitude
        metadata.pickupLongitude = rideParameters.pickupLocation?.coordinate.longitude
        metadata.dropoffLatitude = rideParameters.dropoffLocation?.coordinate.latitude
        metadata.dropoffLongitude = rideParameters.dropoffLocation?.coordinate.longitude
        
        setMetadata()
    }
    
    //Mark: Internal Interface
    
    // Initiate deeplink when button is tapped
    func uberButtonTapped(_ sender: UIButton) {
        rideParameters.source = RideRequestButton.sourceString
        requestBehavior.requestRide(rideParameters)
    }
    
    //Mark: Private Interface
    
    /**
     Helper function that sets appropriate attributes on multi-line label.
     
     - parameter title:    The main title of the label. (ex. "3 MINS AWAY" or "Get a Ride")
     - parameter subtitle: The subtitle of the label. (ex. "$6-8 for uberX")
     - parameter surge:    Whether the price estimate should include a surge image. Default false.
     */
    fileprivate func setMultilineAttributedString(_ title: String, subtitle: String = "", surge: Bool = false) {
        let metadataFont = UIFont(name: "HelveticaNeue-Regular", size: 12) ?? UIFont.systemFont(ofSize: 12)
        
        let attrString = NSMutableAttributedString(string: title)
        
        // If there is a price estimate to include, add a new line
        if !subtitle.isEmpty {
            attrString.append(NSAttributedString(string: "\n"))
            
            // If the price estimate is higher due to a surge, add the surge icon
            if surge == true {
                let attachment = getSurgeAttachment()
                
                // Adjust bounds to center the text attachment
                attachment.bounds = CGRect(x: 0, y: metadataFont.descender-opticalCorrection, width: attachment.image!.size.width, height: attachment.image!.size.height)
                let surgeImage = NSAttributedString(attachment: attachment)
                
                attrString.append(surgeImage)
                attrString.append(NSAttributedString(string: " "))
                
                // Adding the text attachment increases the space between lines so set the max line height
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = .right
                paragraphStyle.maximumLineHeight = 16
                attrString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
            }
            
            attrString.append(NSAttributedString(string: "\(subtitle)"))
        }
        
        attrString.addAttribute(NSFontAttributeName, value: metadataFont, range: (attrString.string as NSString).range(of: title))
        attrString.addAttribute(NSFontAttributeName, value: metadataFont, range: (attrString.string as NSString).range(of: subtitle))
        
        uberTitleLabel.text = LocalizationUtil.localizedString(forKey: "Get a ride", comment: "Request button shorter description")
        uberMetadataLabel.attributedText = attrString
    }
    
    fileprivate func getSurgeAttachment() -> NSTextAttachment {
        let attachment = NSTextAttachment()
        
        switch colorStyle {
        case .black:
            attachment.image = getImage("Surge-WhiteOutline")
        case .white:
            attachment.image = getImage("Surge-BlackOutline")
        }
    
        return attachment
    }
    
    /**
     Sets metadata on button by fetching all required information.
     */
    fileprivate func setMetadata() {
        /**
        *  These are all required for the following requests.
        */
        guard let client = client, let pickupLatitude = metadata.pickupLatitude, let pickupLongitude = metadata.pickupLongitude, let productID = metadata.productID else {
            return
        }
        
        let downloadGroup = DispatchGroup()
        downloadGroup.enter()
        var errors = [RidesError]()
        let pickupLocation = CLLocation(latitude: pickupLatitude, longitude: pickupLongitude)
        
        // Set the information on the button label once all information is retrieved.
        downloadGroup.notify(queue: DispatchQueue.main, execute: {
            guard let estimate = self.metadata.timeEstimate?.estimate else {
                for error in errors {
                    self.delegate?.rideRequestButton(self, didReceiveError: error)
                }
                return
            }
            
            let mins = estimate/60
            var titleText: String
            if mins == 1 {
                titleText = String(format: LocalizationUtil.localizedString(forKey: "%d min away", comment: "Estimate is for car one minute away"), mins).uppercased(with: Locale.current)
            } else {
                titleText = String(format: LocalizationUtil.localizedString(forKey: "%d mins away", comment: "Estimate is for car multiple minutes away"), mins).uppercased(with: Locale.current)
            }
            var subtitleText = ""
            var surge = false
            
            if let productName = self.metadata.productName {
                for estimate in self.metadata.priceEstimates {
                    if estimate.productID == productID, let price = estimate.estimate {
                        if estimate.surgeMultiplier > 1.0 {
                            surge = true
                        }
                        subtitleText = String(format: LocalizationUtil.localizedString(forKey: "%1$@ for %2$@", comment: "Price estimate string for an Uber product"), price, productName)
                    }
                }
            }
            
            self.setMultilineAttributedString(titleText, subtitle: subtitleText, surge: surge)
            self.delegate?.rideRequestButtonDidLoadRideInformation(self)
            
            for error in errors {
                self.delegate?.rideRequestButton(self, didReceiveError: error)
            }
        })
        
        // Get time estimate for productID
        let timeEstimatesCompletion: ([TimeEstimate], Response) -> () = { timeEstimates, response in
            if let error = response.error {
                errors.append(error)
                downloadGroup.leave()
                return
            }
            
            if timeEstimates.count == 0 {
                downloadGroup.leave()
                return
            }
            
            self.metadata.timeEstimate = timeEstimates.first!
            self.metadata.productName = timeEstimates.first!.name
            downloadGroup.leave()
        }
        
        // If dropoff location was set, get price estimates.
        if let dropoffLatitude = metadata.dropoffLatitude, let dropoffLongitude = metadata.dropoffLongitude {
            downloadGroup.enter()
            let dropoffLocation = CLLocation(latitude: dropoffLatitude, longitude: dropoffLongitude)
            let priceEstimatesCompletion: ([PriceEstimate], Response) -> () = {priceEstimates, response in
                if let error = response.error {
                    errors.append(error)
                    downloadGroup.leave()
                    return
                }
                
                if priceEstimates.count == 0 {
                    downloadGroup.leave()
                    return
                }
                
                self.metadata.priceEstimates = priceEstimates
                downloadGroup.leave()
            }
            
            client.fetchPriceEstimates(pickupLocation: pickupLocation, dropoffLocation: dropoffLocation, completion:priceEstimatesCompletion )
        }
        
        client.fetchTimeEstimates(pickupLocation: pickupLocation, productID:productID, completion: timeEstimatesCompletion)
    }
    
    // get image from media directory
    fileprivate func getImage(_ name: String) -> UIImage {
        let bundle = Bundle(for: RideRequestButton.self)
        let image = UIImage(named: name, in: bundle, compatibleWith: nil)
        return image!
    }
}

// MARK: RideRequestButton structures

@objc public enum RequestButtonColorStyle: Int {
    case black
    case white
}

/**
 *  Stores information about current product and its metadata as the information is retrieved.
 */
struct ButtonMetadata {
    var productID: String?
    var productName: String?
    var pickupLatitude: Double?
    var pickupLongitude: Double?
    var dropoffLatitude: Double?
    var dropoffLongitude: Double?
    var timeEstimate: TimeEstimate?
    fileprivate var priceEstimateList: [PriceEstimate]?
    var priceEstimates: [PriceEstimate]! {
        get {
            return priceEstimateList != nil ? priceEstimateList : []
        }
        set {
            priceEstimateList = newValue
        }
    }
}
