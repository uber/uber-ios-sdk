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
class RideRequestWidgetExampleViewController: UIViewController {
    /// The RideRequestButton instance
    let rideRequestButton = RideRequestButton()
    /// Location manger for getting user location
    let locationManger:CLLocationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        self.navigationItem.title = "Ride Request Widget"
        
        // Create a RideRequestViewRequestingBehavior for the RideRequestButton
        let requestBehavior = RideRequestViewRequestingBehavior(presentingViewController: self)
        
        // Optionally subscribe to the ModalRideRequestViewController delegate
        requestBehavior.modalRideRequestViewController.delegate = self
        // Set the RideRequestButton behavior
        rideRequestButton.requestBehavior = requestBehavior
        
        // Subscribe to the CLLocationManager location updates
        locationManger.delegate = self
        
        setupRideRequestButton()
        
        //Check location authorization
        if !checkLocationServices() {
            locationManger.requestWhenInUseAuthorization()
        }
    }
    
    /**
     Sets up the RideRequestButton
     */
    private func setupRideRequestButton() {
        // Using autolayout
        rideRequestButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(rideRequestButton)
        
        // Center the button in the view
        let centerXConstraint = NSLayoutConstraint(item: rideRequestButton, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0.0)
        let centerYConstraint = NSLayoutConstraint(item: rideRequestButton, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.CenterY, multiplier: 1.0, constant: 0.0)
        
        self.view.addConstraints([ centerXConstraint, centerYConstraint ])
        
        // Setup our RideParameters. This button will be using the users current location
        let parameterBuilder = RideParametersBuilder()
        parameterBuilder.setPickupToCurrentLocation()
        let rideParameters = parameterBuilder.build()
        rideRequestButton.rideParameters = rideParameters
    }
    
    private func checkLocationServices() -> Bool {
        let locationEnabled = CLLocationManager.locationServicesEnabled()
        let locationAuthorization = CLLocationManager.authorizationStatus()
        let locationAuthorized = locationAuthorization == .AuthorizedWhenInUse || locationAuthorization == .AuthorizedAlways
        
        return locationEnabled && locationAuthorized
    }
    
    private func showMessage(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let okayAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil)
        alert.addAction(okayAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
}

//MARK: ModalViewControllerDelegate

extension RideRequestWidgetExampleViewController : ModalViewControllerDelegate {
    // Fired when the modal is dismissed
    func modalViewControllerDidDismiss(modalViewController: ModalViewController) {
        print("did dismiss")
    }
    
    // Fired right before the modal dismisses
    func modalViewControllerWillDismiss(modalViewController: ModalViewController) {
        print("will dismiss")
    }
}

//MARK: CLLocationManagerDelegate

extension RideRequestWidgetExampleViewController : CLLocationManagerDelegate {
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .Denied || status == .Restricted {
            showMessage("Location Services disabled.")
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManger.stopUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        locationManger.stopUpdatingLocation()
        showMessage("There was an error locating you.")
    }
}