//
//  AuthorizationCodeGrantExampleViewController.swift
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

import UberRides
import CoreLocation

/// This class demonstrates how do use the LoginManager to complete Authorization Code Grant Authorization
/// and how to use some of the request endpoints 
/// Make sure to replace instances of "YOUR_URL" with the path for your backend service
class AuthorizationCodeGrantExampleViewController: AuthorizationBaseViewController {
    
    private let states = ["accepted", "arriving", "in_progress", "completed"]
    
    /// The LoginManager to use for login
    /// Specify authorization code grant as the loginType to use privileged scopes
    let loginManager = LoginManager(loginType: .AuthorizationCode)
    
    /// The RidesClient to use for endpoints
    let ridesClient = RidesClient()

    @IBOutlet weak var driverImageView: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var loginButton: UIBarButtonItem!
    
    @IBOutlet weak var carLabel: UILabel!
    @IBOutlet weak var carImageView: UIImageView!
    @IBOutlet weak var driverLabel: UILabel!
    @IBOutlet weak var requestButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.enabled = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        let loggedIn = TokenManager.fetchToken() != nil
        loginButton.enabled = !loggedIn
        requestButton.enabled = loggedIn
        
        reset()
    }
    
    override func reset() {
        statusLabel.text = ""
        carLabel.text = ""
        driverLabel.text = ""
        carImageView.image = nil
        driverImageView.image = nil
    }
    
    @IBAction func login(sender: AnyObject) {
        // Can define a state variable to prevent tampering
        loginManager.state = NSUUID().UUIDString
        
        // Define which scopes we're requesting
        // Need to be authorized on your developer dashboard at developer.uber.com
        // Privileged scopes can be used by anyone in sandbox for your own account but must be approved for production
        let requestedScopes = [RidesScope.Request, RidesScope.AllTrips]
        // Use your loginManager to login with the requested scopes, viewcontroller to present over, and completion block
        loginManager.login(requestedScopes: requestedScopes, presentingViewController: self) { (accessToken, error) -> () in
            // Error
            if let error = error {
                self.showMessage(error.localizedDescription)
                return
            }
            
            // Poll backend for access token
            // Replace "YOUR_URL" with the path for your backend service
            if let url = NSURL(string: "YOUR_URL") {
                let request = NSURLRequest(URL: url)
                NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {
                    (data, response, error) in
                    dispatch_async(dispatch_get_main_queue(), {
                        guard let data = data,
                            let jsonString = String(data: data, encoding: NSUTF8StringEncoding),
                            let token = AccessTokenFactory.createAccessTokenFromJSONString(jsonString) else {
                                self.showMessage("Unable to retrieve access token")
                                return
                        }
                        
                        // Do any additional work to verify the state passed in earlier
                        
                        if !TokenManager.saveToken(token) {
                            self.showMessage("Unable to save access token")
                        } else {
                            self.showMessage("Saved an AccessToken!")
                            self.loginButton.enabled = false
                            self.requestButton.enabled = true
                        }
                    })
                }).resume()
            }
        }
    }
    
    @IBAction func requestRide(sender: AnyObject) {
        // Create ride parameters
        let parameterBuilder = RideParametersBuilder()
        self.requestButton.enabled = false
        parameterBuilder.setProductID("a1111c8c-c720-46c3-8534-2fcdd730040d")
        let pickupLocation = CLLocation(latitude: 37.770, longitude: -122.466)
        parameterBuilder.setPickupLocation(pickupLocation, nickname: "California Academy of Sciences")
        let dropoffLocation = CLLocation(latitude: 37.791, longitude: -122.405)
        parameterBuilder.setDropoffLocation(dropoffLocation, nickname: "Pier 39")
        
        // Use the POST /v1/requests endpoint to make a ride request (in sandbox)
        ridesClient.requestRide(parameterBuilder.build(), completion: { ride, response in
            dispatch_async(dispatch_get_main_queue(), {
                self.checkError(response)
                if let ride = ride {
                    self.statusLabel.text = "Processing"
                    
                    // Simulate stepping through the different ride statuses
                    guard let requestID = ride.requestID else {
                        return
                    }
                    
                    self.updateRideStatus(requestID, index: 0)
                } else {
                    self.requestButton.enabled = true
                }
            })
        })
    }
    
    // Uses the the GET /v1/requests/{request_id} endpoint to get information about a ride request
    func getRideData(requestID: String) {
        ridesClient.fetchRideDetails(requestID, completion: { ride, response in
            self.checkError(response)
            
            // Unwrap some optionals for data we want to use
            guard let ride = ride,
                let driverName = ride.driver?.name,
                let driverNumber = ride.driver?.phoneNumber,
                let licensePlate = ride.vehicle?.licensePlate,
                let make = ride.vehicle?.make,
                let model = ride.vehicle?.model,
                let driverImage = ride.driver?.pictureURL,
                let carImage = ride.vehicle?.pictureURL else {
                return
            }
            
            // Update the UI on the main thread
            dispatch_async(dispatch_get_main_queue(), {
                self.driverLabel.text = "\(driverName)\n\(driverNumber)"
                self.carLabel.text = "\(make) \(model)\n(\(licensePlate)"
                
                // Asynchronously fetch images
                if let driverUrl = NSURL(string: driverImage) {
                    NSURLSession.sharedSession().dataTaskWithURL(driverUrl, completionHandler: {
                        (data, response, error) in
                        dispatch_async(dispatch_get_main_queue(), {
                            guard let data = data else {
                                return
                            }
                            
                            self.driverImageView.image = UIImage(data: data)
                        })
                    }).resume()
                }
                if let vehicleUrl = NSURL(string: carImage) {
                    NSURLSession.sharedSession().dataTaskWithURL(vehicleUrl, completionHandler: {
                        (data, response, error) in
                        dispatch_async(dispatch_get_main_queue(), {
                            guard let data = data else {
                                return
                            }
                            
                            self.carImageView.image = UIImage(data: data)
                        })
                    }).resume()
                }
                self.updateRideStatus(requestID, index: 1)
            })
        })
    }
    
    // Simulates stepping through ride statuses recursively
    func updateRideStatus(requestID: String, index: Int) {
        guard index < states.count,
            let token = TokenManager.fetchToken() else {
            return
        }
        
        let status = states[index]

        // Use the PUT /v1/sandbox/requests/{request_id} to update the ride status
        let updateStatusEndpoint = NSURL(string: "https://sandbox-api.uber.com/v1/sandbox/requests/\(requestID)")!
        let request = NSMutableURLRequest(URL: updateStatusEndpoint)
        request.HTTPMethod = "PUT"
        request.setValue("Bearer \(token.tokenString!)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            let data = try NSJSONSerialization.dataWithJSONObject(["status":status], options: .PrettyPrinted)
            request.HTTPBody = data
        } catch { }
        
        NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data, response, error) in
            dispatch_async(dispatch_get_main_queue(), {
                if let response = response as? NSHTTPURLResponse where response.statusCode != 204  {
                    return
                }
                
                self.statusLabel.text = status.capitalizedString
                
                // Get ride data when in the Accepted state
                if status == "accepted" {
                    self.getRideData(requestID)
                    return
                }
                    
                self.delay(1.5, closure: {
                    self.updateRideStatus(requestID, index: index+1)
                })
            })
        }).resume()
    }
}
