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
import UberCore

/// A protocol used to response to Uber RideRequestButton events
public protocol RideRequestButtonDelegate: AnyObject {
    /**
     The button finished loading ride information successfully.
     
     - parameter button: the RideRequestButton
     */
    func rideRequestButtonDidLoadRideInformation(_ button: RideRequestButton)
    
    /**
     The button encountered an error when refreshing its metadata content.
     
     - parameter button: the RideRequestButton
     - parameter error:  the error that it encountered
     */
    func rideRequestButton(_ button: RideRequestButton, didReceiveError error: UberError)
}

public class RideRequestButton: UberButton {
    
    // MARK: Public Properties
    
    /// Delegate is informed of events that occur with request button.
    public weak var delegate: RideRequestButtonDelegate?
    
    /// The RideParameters object this button will use to make a request
    public var rideParameters: RideParameters
    
    /// The RideRequesting object the button will use to make a request
    public var requestBehavior: RideRequesting
    
    /// The RidesClient used for retrieving metadata for the button.
    public var client: RidesClient?
    
    // MARK: Internal Properties
    
    static let sourceString = "button"
    
    var metadata = ButtonMetadata()
    
    // MARK: Private Properties
    
    private var _title: NSAttributedString? = .init(string: "Ride there with Uber")
    
    private var _subtitle: NSAttributedString? = nil
    
    private lazy var _image: UIImage? = image(name: "Badge")
    
    private let opticalCorrection: CGFloat = 1.0
    
    // MARK: Initializers
    
    public init(client: RidesClient = RidesClient(),
                rideParameters: RideParameters = RideParametersBuilder().build(),
                requestBehavior: RideRequesting = DeeplinkRequestingBehavior()) {
        self.client = client
        self.rideParameters = rideParameters
        self.requestBehavior = requestBehavior
        super.init(frame: CGRect.zero)
        configure()
    }
    
    required public init?(coder: NSCoder) {
        self.client = RidesClient()
        self.rideParameters = RideParametersBuilder().build()
        self.requestBehavior = DeeplinkRequestingBehavior()
        super.init(coder: coder)
        configure()
    }
    
    // MARK: Public Methods
    
    public func loadRideInformation() {
        guard client != nil else {
            delegate?.rideRequestButton(self, didReceiveError: createValidationFailedError())
            return
        }
        
        metadata.productID = rideParameters.productID
        metadata.pickupLatitude = rideParameters.pickupLocation?.coordinate.latitude
        metadata.pickupLongitude = rideParameters.pickupLocation?.coordinate.longitude
        metadata.dropoffLatitude = rideParameters.dropoffLocation?.coordinate.latitude
        metadata.dropoffLongitude = rideParameters.dropoffLocation?.coordinate.longitude
        
        setMetadata()
    }
    
    // MARK: UberButton
    
    public override var title: NSAttributedString? {
        _title
    }
    
    public override var subtitle: NSAttributedString? {
        _subtitle
    }
    
    public override var image: UIImage? {
        _image
    }
    
    public override var horizontalAlignment: UIControl.ContentHorizontalAlignment {
        .leading
    }
    
    // MARK: Private
    
    private func configure() {
        addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    @objc func buttonTapped(_ sender: UIButton) {
        rideParameters.source = RideRequestButton.sourceString
        requestBehavior.requestRide(parameters: rideParameters)
    }
    
    private func createValidationFailedError() -> UberError {
        return UberError(status: 422, code: "validation_failed", title: "Invalid Request")
    }

    private func setMetadata() {

        guard let client = client,
                let pickupLatitude = metadata.pickupLatitude,
                let pickupLongitude = metadata.pickupLongitude,
                let productID = metadata.productID else {
            delegate?.rideRequestButton(self, didReceiveError: createValidationFailedError())
            return
        }
        
        let downloadGroup = DispatchGroup()
        downloadGroup.enter()
        var errors = [UberError]()
        let pickupLocation = CLLocation(latitude: pickupLatitude, longitude: pickupLongitude)
        
        // Set the information on the button label once all information is retrieved.
        downloadGroup.notify(queue: DispatchQueue.main, execute: {

            var titleText = ""
            var subtitleText = ""

            if let timeEstimate = self.metadata.timeEstimate?.estimate {
                let mins = timeEstimate / 60
                if mins == 1 {
                    titleText = String(format: NSLocalizedString("%d min away", bundle: Bundle(for: type(of: self)), comment: "Estimate is for car one minute away"), mins).uppercased(with: Locale.current)
                } else {
                    titleText = String(format: NSLocalizedString("%d mins away", bundle: Bundle(for: type(of: self)), comment: "Estimate is for car multiple minutes away"), mins).uppercased(with: Locale.current)
                }
            }

            var surge = false
            for estimate in self.metadata.priceEstimates {
                if let price = estimate.estimate,
                    let productName = estimate.name,
                    estimate.productID == productID {
                    if let surgeMultiplier = estimate.surgeMultiplier,
                        surgeMultiplier > 1.0 {
                        surge = true
                    }
                    let priceEstimateString = String(format: NSLocalizedString("%1$@ for %2$@", bundle: Bundle(for: type(of: self)), comment: "Price estimate string for an Uber product"), price, productName)
                    if titleText.isEmpty {
                        titleText = priceEstimateString
                    } else {
                        subtitleText = priceEstimateString
                    }
                    break
                }
            }

            if !titleText.isEmpty {
                self.setMultilineAttributedString(title: titleText, subtitle: subtitleText, surge: surge)
            }
            
            for error in errors {
                self.delegate?.rideRequestButton(self, didReceiveError: error)
            }

            self.delegate?.rideRequestButtonDidLoadRideInformation(self)
        })
        
        // Get time estimate for productID
        let timeEstimatesCompletion: ([TimeEstimate], Response) -> () = { timeEstimates, response in
            if let error = response.error {
                errors.append(error)
                downloadGroup.leave()
                return
            }

            self.metadata.timeEstimate = timeEstimates.first
            self.metadata.productName = timeEstimates.first?.name
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

                self.metadata.priceEstimates = priceEstimates
                downloadGroup.leave()
            }
            
            client.fetchPriceEstimates(pickupLocation: pickupLocation, dropoffLocation: dropoffLocation, completion:priceEstimatesCompletion )
        }
        
        client.fetchTimeEstimates(pickupLocation: pickupLocation, productID:productID, completion: timeEstimatesCompletion)
    }
    
    /**
     Helper function that sets appropriate attributes on multi-line label.
     
     - parameter title:    The main title of the label. (ex. "3 MINS AWAY" or "Get a Ride")
     - parameter subtitle: The subtitle of the label. (ex. "$6-8 for uberX")
     - parameter surge:    Whether the price estimate should include a surge image. Default false.
     */
    private func setMultilineAttributedString(title: String, subtitle: String = "", surge: Bool = false) {
        let metadataFont = UIFont(name: "HelveticaNeue-Regular", size: 12) ?? UIFont.systemFont(ofSize: 12)
        
        let attrString = NSMutableAttributedString(string: title)
        
        // If there is a price estimate to include, add a new line
        if !subtitle.isEmpty {
            attrString.append(NSAttributedString(string: "\n"))
            
            // If the price estimate is higher due to a surge, add the surge icon
            if surge == true {
                let attachment = getSurgeAttachment()
                
                // Adjust bounds to center the text attachment
                attachment.bounds = CGRect(x: 0, y: metadataFont.descender-opticalCorrection, width: attachment.image?.size.width ?? 0, height: attachment.image!.size.height)
                let surgeImage = NSAttributedString(attachment: attachment)
                
                attrString.append(surgeImage)
                attrString.append(NSAttributedString(string: " "))
                
                // Adding the text attachment increases the space between lines so set the max line height
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = .right
                paragraphStyle.maximumLineHeight = 16
                attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
            }
            
            attrString.append(NSAttributedString(string: "\(subtitle)"))
        }
        
        attrString.addAttribute(NSAttributedString.Key.font, value: metadataFont, range: (attrString.string as NSString).range(of: title))
        attrString.addAttribute(NSAttributedString.Key.font, value: metadataFont, range: (attrString.string as NSString).range(of: subtitle))

        if attrString.string.isEmpty {
            _title = NSAttributedString(
                string: NSLocalizedString("Ride there with Uber", bundle: Bundle(for: type(of: self)), comment: "Request button description")
            )
        } else {
            _title = NSAttributedString(
                string: NSLocalizedString("Get a ride", bundle: Bundle(for: type(of: self)), comment: "Request button shorter description")
            )
        }

        _subtitle = attrString
        
        update()
    }
    
    private func getSurgeAttachment() -> NSTextAttachment {
        let attachment = NSTextAttachment()
        attachment.image = image(name: "Surge-WhiteOutline")
        return attachment
    }
    
    private func image(name: String) -> UIImage? {
        UIImage(named: name, in: Bundle.module, compatibleWith: nil)
    }
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
    private var priceEstimateList: [PriceEstimate]?
    var priceEstimates: [PriceEstimate] {
        get {
            return priceEstimateList ?? []
        }
        set {
            priceEstimateList = newValue
        }
    }
}
