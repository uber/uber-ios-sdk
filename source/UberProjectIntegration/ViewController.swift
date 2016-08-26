//
//  ViewController.swift
//  UberProjectIntegration
//
//  Created by Gaurav Sharma on 25/08/16.
//  Copyright © 2016 Uber. All rights reserved.
//

import UIKit
import UberRides
import CoreLocation

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.uberTest()
    }

    func uberTest() {
        let behavior = RideRequestViewRequestingBehavior(presentingViewController: self)
        // loc to 
        let location = CLLocation(latitude: 26.9152452, longitude: 75.8038488)
        let parameters = RideParametersBuilder().setPickupLocation(location).build()
        let button = RideRequestButton(rideParameters: parameters, requestingBehavior: behavior)
        self.view.addSubview(button)
    }


}
