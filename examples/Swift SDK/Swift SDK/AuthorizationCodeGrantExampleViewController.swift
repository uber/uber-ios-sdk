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

import UberCore
import UberRides
import CoreLocation

/// This class demonstrates how do use the LoginManager to complete Authorization Code Grant Authorization
/// and how to use some of the request endpoints 
/// Make sure to replace instances of "YOUR_URL" with the path for your backend service
class AuthorizationCodeGrantExampleViewController: AuthorizationBaseViewController {
    
    fileprivate let states = ["accepted", "arriving", "in_progress", "completed"]
    
    /// The LoginManager to use for login
    /// Specify authorization code grant as the loginType to use privileged scopes
    let loginManager = LoginManager(loginType: .authorizationCode)
    
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
        loginButton.isEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let loggedIn = TokenManager.fetchToken() != nil
        loginButton.isEnabled = !loggedIn
        requestButton.isEnabled = loggedIn
        
        reset()
    }
    
    override func reset() {
        statusLabel.text = ""
        carLabel.text = ""
        driverLabel.text = ""
        carImageView.image = nil
        driverImageView.image = nil
    }
    
    @IBAction func login(_ sender: AnyObject) {
        // Define which scopes we're requesting
        // Need to be authorized on your developer dashboard at developer.uber.com
        // Privileged scopes can be used by anyone in sandbox for your own account but must be approved for production
        let requestedScopes = [UberScope.request, UberScope.allTrips]
        // Use your loginManager to login with the requested scopes, viewcontroller to present over, and completion block
        loginManager.login(requestedScopes: requestedScopes, presentingViewController: self) { (accessToken, error) -> () in
            // Error
            if let error = error {
                self.showMessage(error.localizedDescription)
                return
            }
            
            // Poll backend for access token
            // Replace "YOUR_URL" with the path for your backend service
            if let url = URL(string: "YOUR_URL") {
                let request = URLRequest(url: url)
                URLSession.shared.dataTask(with: request) { (data, response, error) in
                    DispatchQueue.main.async {
                        guard let data = data,
                            let jsonString = String(data: data, encoding: String.Encoding.utf8) else {
                                self.showMessage("Unable to retrieve access token")
                                return
                        }
                        let token = AccessToken(tokenString: jsonString)

                        // Do any additional work to verify the state passed in earlier
                        
                        if !TokenManager.save(accessToken: token) {
                            self.showMessage("Unable to save access token")
                        } else {
                            self.showMessage("Saved an AccessToken!")
                            self.loginButton.isEnabled = false
                            self.requestButton.isEnabled = true
                        }
                    }
                }.resume()
            }
        }
    }
    
    @IBAction func requestRide(_ sender: AnyObject) {
        // Create ride parameters
        self.requestButton.isEnabled = false
        let pickupLocation = CLLocation(latitude: 37.770, longitude: -122.466)
        let dropoffLocation = CLLocation(latitude: 37.791, longitude: -122.405)

        let builder = RideParametersBuilder()
        builder.pickupLocation = pickupLocation
        builder.pickupNickname = "California Academy of Sciences"
        builder.dropoffLocation = dropoffLocation
        builder.dropoffNickname = "Pier 39"
        builder.productID = "a1111c8c-c720-46c3-8534-2fcdd730040d"

        // Use the POST /v1/requests endpoint to make a ride request (in sandbox)
        ridesClient.requestRide(parameters: builder.build(), completion: { ride, response in
            DispatchQueue.main.async(execute: {
                self.checkError(response)
                if let ride = ride,
                    let requestID = ride.requestID {
                    self.statusLabel.text = "Processing"
                    
                    self.updateRideStatus(requestID, index: 0)
                } else {
                    self.requestButton.isEnabled = true
                }
            })
        })
    }
    
    // Uses the the GET /v1/requests/{request_id} endpoint to get information about a ride request
    func getRideData(_ requestID: String) {
        ridesClient.fetchRideDetails(requestID: requestID) { ride, response in
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
            DispatchQueue.main.async {
                self.driverLabel.text = "\(driverName)\n\(driverNumber)"
                self.carLabel.text = "\(make) \(model)\n(\(licensePlate)"
                
                // Asynchronously fetch images
                URLSession.shared.dataTask(with: driverImage) {
                    (data, response, error) in
                    DispatchQueue.main.async {
                        guard let data = data else {
                            return
                        }

                        self.driverImageView.image = UIImage(data: data)
                    }
                }.resume()
                URLSession.shared.dataTask(with: carImage) {
                    (data, response, error) in
                    DispatchQueue.main.async {
                        guard let data = data else {
                            return
                        }

                        self.carImageView.image = UIImage(data: data)
                    }
                }.resume()
                self.updateRideStatus(requestID, index: 1)
            }
        }
    }
    
    // Simulates stepping through ride statuses recursively
    func updateRideStatus(_ requestID: String, index: Int) {
        guard index < states.count,
            let token = TokenManager.fetchToken() else {
            return
        }
        
        let status = states[index]

        // Use the PUT /v1/sandbox/requests/{request_id} to update the ride status
        let updateStatusEndpoint = URL(string: "https://sandbox-api.uber.com/v1/sandbox/requests/\(requestID)")!
        var request = URLRequest(url: updateStatusEndpoint)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(token.tokenString)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            let data = try JSONSerialization.data(withJSONObject: ["status":status], options: .prettyPrinted)
            request.httpBody = data
        } catch { }
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                if let response = response as? HTTPURLResponse, response.statusCode != 204  {
                    return
                }
                
                self.statusLabel.text = status.capitalized
                
                // Get ride data when in the Accepted state
                if status == "accepted" {
                    self.getRideData(requestID)
                    return
                }
                    
                self.delay(2) {
                    self.updateRideStatus(requestID, index: index+1)
                }
            }
        }.resume()
    }
}
