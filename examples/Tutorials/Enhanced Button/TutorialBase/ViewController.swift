//
//  ViewController.swift
//  TutorialBase - Enhanced Button Finished


import UIKit
import UberRides
import CoreLocation

class ViewController: UIViewController, RideRequestButtonDelegate {
    
    let button = RideRequestButton()
    let ridesClient = RidesClient()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        button.delegate = self
        
        let pickupLocation = CLLocation(latitude: 37.775159, longitude: -122.417907)
        let dropoffLocation = CLLocation(latitude: 37.6213129, longitude: -122.3789554)
        
        //make sure that the pickupLocation and dropoffLocation is set in the deeplink
        let builder = RideParametersBuilder()
            .setPickupLocation(pickupLocation)
            // nickname or address is required to properly display destination on the Uber App
            .setDropoffLocation(dropoffLocation,
                                nickname: "San Francisco International Airport")
        button.rideParameters = builder.build()
        
            
        // use the same pickupLocation to get the estimate
        ridesClient.fetchCheapestProduct(pickupLocation: pickupLocation, completion: {
            product, response in
            if let productID = product?.productID { //check if the productID exists
                
                let builder = RideParametersBuilder(rideParameters: self.button.rideParameters)
                builder.setProductID(productID)
                
                self.button.rideParameters = builder.build()
                // show estimate in the button
                self.button.loadRideInformation()
            }
            
        })
        
        
        // center the button (optional)
        button.center = view.center
        
        view.addSubview(button)
    }
    
    func rideRequestButtonDidLoadRideInformation(button: RideRequestButton) {
        button.sizeToFit()
        button.center = view.center
    }
    
    func rideRequestButton(button: RideRequestButton, didReceiveError error: RidesError) {
        // error handling
    }
}

