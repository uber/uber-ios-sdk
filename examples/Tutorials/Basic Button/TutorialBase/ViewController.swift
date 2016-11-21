//
//  ViewController.swift
//  TutorialBase - Basic Button Finished


import UIKit
import UberRides
import CoreLocation

class ViewController: UIViewController {
    // ride request button
    let button = RideRequestButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set a dropoffLocation
        let dropoffLocation = CLLocation(latitude: 37.6213129, longitude: -122.3789554)
        let builder = RideParametersBuilder()
            .setDropoffLocation(dropoffLocation,
                                nickname: "San Francisco International Airport")
        button.rideParameters = builder.build()
        
        //center the button
        button.center = view.center
        
        //put the button in the view
        view.addSubview(button)
    }

}

