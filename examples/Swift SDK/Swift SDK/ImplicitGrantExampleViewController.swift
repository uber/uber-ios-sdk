//
//  ImplicitGrantExampleViewController.swift
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

/// This class demonstrates how do use the LoginManager to complete Implicit Grant Authorization
/// and how to use the user profile, trip history, and places endpoints.
class ImplicitGrantExampleViewController: AuthorizationBaseViewController {
    /// The LoginManager to use for login
    let loginManager = LoginManager(loginType: .Implicit)
    
    /// The RidesClient to use for endpoints
    let ridesClient = RidesClient()
    
    /// Variables to store retrieved information
    private var profile: UserProfile?
    private var places = [Place?](count: 2, repeatedValue: nil)
    private var history = [UserActivity]()
    
    /// Constants representing each section
    private let ProfileSection = 0
    private let PlacesSection = 1
    private let HistorySection = 2
    
    /// Reuse identifiers for the table view cells
    private let ProfileCell = "ProfileCell"
    private let PlacesCell = "PlacesCell"
    private let HistoryCell = "HistoryCell"
    
    /// Rows in the "Places" section
    private let homePlaceRow = 0
    private let workPlaceRow = 1

    /// Custom views in the "Profile" section
    private let profileImageTag = 1
    private let profileLabelTag = 2
    
    /// Outlets
    @IBOutlet weak var loginButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        loginButton.enabled = true
    }
    
    override func viewWillAppear(animated: Bool) {
        if let _ = TokenManager.fetchToken() {
            loginButton.enabled = false
            getData()
        }
    }
    
    override func reset() {
        profile = nil
        self.tableView.reloadData()
        loginButton.enabled = true
    }
    
    @IBAction func login(sender: AnyObject) {
        // Define which scopes we're requesting
        // Need to be authorized on your developer dashboard at developer.uber.com
        let requestedScopes = [RidesScope.RideWidgets, RidesScope.Profile, RidesScope.Places, RidesScope.History, RidesScope.Places]
        // Use your loginManager to login with the requested scopes, viewcontroller to present over, and completion block
        loginManager.login(requestedScopes: requestedScopes, presentingViewController: self) { (accessToken, error) -> () in
            if accessToken != nil {
                //Success! AccessToken is automatically saved in keychain
                self.showMessage("Got an AccessToken!")
            } else {
                // Error
                if let error = error {
                    self.showMessage(error.localizedDescription)
                } else {
                    self.showMessage("An Unknown Error Occured")
                }
            }
        }
    }
    
    private func getData() {
        // Examples of various data that can be retrieved
        
        // Retrieves UserProfile for the current logged in user
        ridesClient.fetchUserProfile({ profile, response in
            self.checkError(response)
            if let profile = profile {
                dispatch_async(dispatch_get_main_queue(), {
                    self.profile = profile
                    self.tableView.reloadData()
                })
            }
        })
        
        // Gets the address assigned as the "home" address for current user
        ridesClient.fetchPlace(Place.Home, completion: { place, response in
            self.checkError(response)
            dispatch_async(dispatch_get_main_queue(), {
                self.places[self.homePlaceRow] = place
                self.tableView.reloadData()
            })
        })
        
        // Gets the address assigned as the "work" address for current user
        ridesClient.fetchPlace(Place.Work, completion: { place, response in
            self.checkError(response)
            dispatch_async(dispatch_get_main_queue(), {
                self.places[self.workPlaceRow] = place
                self.tableView.reloadData()
            })
        })
        
        // Gets the last 25 trips that the current user has taken
        ridesClient.fetchTripHistory(limit: 25, completion: { tripHistory, response in
            self.checkError(response)
            guard let history = tripHistory?.history else {
                return
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                self.history = history
                self.tableView.reloadData()
            })
        })
    }
}

extension ImplicitGrantExampleViewController: UITableViewDataSource {
    // Only show rows in section if we have a profile
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let _ = profile else {
            return 0
        }
        
        switch section {
        case ProfileSection:
            return 1
        case PlacesSection:
            return places.count
        case HistorySection:
            return history.count
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case ProfileSection:
            guard let profile = profile,
                let profilePicture = profile.picturePath,
                let firstName = profile.firstName,
                let lastName = profile.lastName,
                let email = profile.email else {
                fallthrough
            }
            
            let cell = tableView.dequeueReusableCellWithIdentifier(ProfileCell) ?? UITableViewCell(style: .Default, reuseIdentifier: ProfileCell)
            
            let profileLabel = cell.viewWithTag(profileLabelTag) as? UILabel
            profileLabel?.text = "\(firstName) \(lastName)\n\(email)"
            
            if let url = NSURL(string: profilePicture) {
                NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: {
                    (data, response, error) in
                    dispatch_async(dispatch_get_main_queue(), {
                        let imageView = cell.viewWithTag(self.profileImageTag) as? UIImageView
                        if let imageView = imageView, data = data {
                            imageView.image = UIImage(data: data)
                        }
                    })
                }).resume()
            }
            
            return cell
        case PlacesSection:
            let cell = tableView.dequeueReusableCellWithIdentifier(PlacesCell) ??
                UITableViewCell(style: .Default, reuseIdentifier: PlacesCell)
            let placeText = indexPath.row == homePlaceRow ? "Home" : "Work"
            let place = self.places[indexPath.row]
            var addressText = "None"
            if let address = place?.address {
                addressText = address
            }
            cell.textLabel?.text = "\(placeText): \(addressText)"
            return cell
        case HistorySection:
            let trip = history[indexPath.row]
            guard let startCity = trip.startCity?.name,
                let startTime = trip.startTime,
                let endTime = trip.endTime else {
                fallthrough
            }
            
            let cell = tableView.dequeueReusableCellWithIdentifier(HistoryCell) ??
                UITableViewCell(style: .Default, reuseIdentifier: HistoryCell)
            cell.textLabel?.text = startCity
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = .ShortStyle
            dateFormatter.timeStyle = .ShortStyle
            cell.detailTextLabel?.text = "\(dateFormatter.stringFromDate(startTime)) to \(dateFormatter.stringFromDate(endTime))"
            
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
}

extension ImplicitGrantExampleViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
        guard indexPath.section == PlacesSection else {
            return
        }
        
        let alertController = UIAlertController(title: "Update Place Address", message: nil, preferredStyle: .Alert)
        alertController.addTextFieldWithConfigurationHandler({ (textField) in
            if let place = self.places[indexPath.row],
                let address = place.address {
                textField.placeholder = address
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (_) in }
        let updateAction = UIAlertAction(title: "Update", style: .Default) { (_) in
            let addressTextField = alertController.textFields![0] as UITextField
            
            guard let address = addressTextField.text else {
                return
            }
            
            let placeID = indexPath.row == self.homePlaceRow ? Place.Home : Place.Work
            self.ridesClient.updatePlace(placeID, withAddress: address, completion: {
                place, response in
                if response.error == nil, let place = place {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.places[indexPath.row] = place
                        self.tableView.reloadData()
                    })
                }
            })
        }
        
        alertController.addAction(updateAction)
        alertController.addAction(cancelAction)
        
        self.view.setNeedsLayout()
        self.presentViewController(alertController, animated: true, completion: nil)
    }
}
