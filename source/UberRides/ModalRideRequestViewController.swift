//
//  ModalRideRequestViewController.swift
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

/// Modal View Controller to use for presenting a RideRequestViewController. Handles errors & closing the modal for you
@objc(UBSDKModalRideRequestViewController) open class ModalRideRequestViewController : ModalViewController {
    /// The RideRequestViewController this modal is wrapping
    open internal(set) var rideRequestViewController : RideRequestViewController
    
    /**
     Initializer for the ModalRideRequestViewController. Wraps the provided RideRequestViewController
     and acts as it's delegate. Will handle errors coming in via the RideRequestViewControllerDelegate
     and dismiss the modal appropriately
     
     - parameter rideRequestViewController: The RideRequestViewController to wrap
     
     - returns: An initialized ModalRideRequestViewController
     */
    @objc public init(rideRequestViewController: RideRequestViewController) {
        self.rideRequestViewController = rideRequestViewController
        super.init(childViewController: rideRequestViewController, buttonStyle: ModalViewControllerButtonStyle.backButton)
        self.rideRequestViewController.delegate = self
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: UIViewController

    open override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return [.portrait, .portraitUpsideDown]
    }
}

extension ModalRideRequestViewController : RideRequestViewControllerDelegate {
    /**
     ModalRideRequestViewController's implmentation for the RideRequestViewController delegate.
     
     - parameter rideRequestViewController: The RideRequestViewController that experienced an error
     - parameter error:                     The RideRequestViewError that occured
     */
    public func rideRequestViewController(_ rideRequestViewController: RideRequestViewController, didReceiveError error: NSError) {
        let errorType = RideRequestViewErrorType(rawValue: error.code) ?? RideRequestViewErrorType.unknown
        var errorString: String?
        navigationItem.title = LocalizationUtil.localizedString(forKey: "Sign in with Uber", comment: "Title of navigation bar during OAuth")
        switch errorType {
        case .accessTokenExpired:
            fallthrough
        case .accessTokenMissing:
            errorString = LocalizationUtil.localizedString(forKey: "There was a problem authenticating you. Please try again.", comment: "RideRequestView error text for authentication error")
        case .networkError:
            break
        default:
            errorString = LocalizationUtil.localizedString(forKey: "The Ride Request Widget encountered a problem. Please try again.", comment: "RideRequestView error text for a generic error")
        }
        
        if let errorString = errorString {
            let actionString = LocalizationUtil.localizedString(forKey: "OK", comment: "OK button title")
            let alert = UIAlertController(title: nil, message: errorString, preferredStyle: UIAlertControllerStyle.alert)
            let okayAction = UIAlertAction(title: actionString, style: UIAlertActionStyle.default, handler: { (_) -> Void in
                self.dismiss()
            })
            alert.addAction(okayAction)
            self.present(alert, animated: true, completion: nil)
        } else {
            self.dismiss()
        }
    }
}
