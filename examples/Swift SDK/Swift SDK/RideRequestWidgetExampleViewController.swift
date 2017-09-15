//
//  RideRequestWidgetExampleViewController.swift
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

/// This class provides an example of how to use the RideRequestButton to initiate
/// a ride request using the Ride Request Widget
class RideRequestWidgetExampleViewController: ButtonExampleViewController {
    
    var blackRideRequestButton: RideRequestButton!
    var whiteRideRequestButton: RideRequestButton!
    
    let locationManger:CLLocationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        
        self.navigationItem.title = "Ride Request Widget"
        
        blackRideRequestButton = buildRideRequestWidgetButton(.native)
        whiteRideRequestButton = buildRideRequestWidgetButton(.implicit)
        
        whiteRideRequestButton.colorStyle = .white
        
        topView.addSubview(blackRideRequestButton)
        bottomView.addSubview(whiteRideRequestButton)
        
        addBlackRequestButtonConstraints()
        addWhiteRequestButtonConstraints()
        
        locationManger.delegate = self
        
        if !checkLocationServices() {
            locationManger.requestWhenInUseAuthorization()
        }
    }
    
    // Mark: Private Interface
    
    fileprivate func buildRideRequestWidgetButton(_ loginType: LoginType) -> RideRequestButton {
        let loginManager = LoginManager(loginType: loginType)
        let requestBehavior = RideRequestViewRequestingBehavior(presentingViewController: self, loginManager: loginManager)
        requestBehavior.modalRideRequestViewController.delegate = self
        
        let rideParameters = RideParametersBuilder().build()

        let accessTokenString = "access_token_string"
        let token = AccessToken(tokenString: accessTokenString)
        if TokenManager.save(accessToken: token){
            // Success
        } else {
            // Unable to save
        }

        TokenManager.fetchToken()
        TokenManager.deleteToken()
        
        return RideRequestButton(rideParameters: rideParameters, requestingBehavior: requestBehavior)
    }
    
    fileprivate func addBlackRequestButtonConstraints() {
        blackRideRequestButton.translatesAutoresizingMaskIntoConstraints = false
        
        let centerYConstraint = NSLayoutConstraint(item: blackRideRequestButton, attribute: .centerY, relatedBy: .equal, toItem: topView, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        let centerXConstraint = NSLayoutConstraint(item: blackRideRequestButton, attribute: .centerX, relatedBy: .equal, toItem: topView, attribute: .centerX, multiplier: 1.0, constant: 0.0)
        
        topView.addConstraints([centerYConstraint, centerXConstraint])
    }
    
    fileprivate func addWhiteRequestButtonConstraints() {
        whiteRideRequestButton.translatesAutoresizingMaskIntoConstraints = false
        
        let centerYConstraint = NSLayoutConstraint(item: whiteRideRequestButton, attribute: .centerY, relatedBy: .equal, toItem: bottomView, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        let centerXConstraint = NSLayoutConstraint(item: whiteRideRequestButton, attribute: .centerX, relatedBy: .equal, toItem: bottomView, attribute: .centerX, multiplier: 1.0, constant: 0.0)
        
        bottomView.addConstraints([centerYConstraint, centerXConstraint])
    }
    
    fileprivate func checkLocationServices() -> Bool {
        let locationEnabled = CLLocationManager.locationServicesEnabled()
        let locationAuthorization = CLLocationManager.authorizationStatus()
        let locationAuthorized = locationAuthorization == .authorizedWhenInUse || locationAuthorization == .authorizedAlways
        
        return locationEnabled && locationAuthorized
    }
    
    fileprivate func showMessage(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okayAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil)
        alert.addAction(okayAction)
        self.present(alert, animated: true, completion: nil)
    }
    
}

//MARK: ModalViewControllerDelegate

extension RideRequestWidgetExampleViewController : ModalViewControllerDelegate {
    func modalViewControllerDidDismiss(_ modalViewController: ModalViewController) {
        print("did dismiss")
    }
    
    func modalViewControllerWillDismiss(_ modalViewController: ModalViewController) {
        print("will dismiss")
    }
}

//MARK: CLLocationManagerDelegate

extension RideRequestWidgetExampleViewController : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .denied || status == .restricted {
            showMessage("Location Services disabled.")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManger.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManger.stopUpdatingLocation()
        showMessage("There was an error locating you.")
    }
}
