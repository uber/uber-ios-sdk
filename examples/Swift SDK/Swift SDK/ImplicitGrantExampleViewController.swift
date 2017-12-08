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
import UberCore
import CoreLocation

/// This class demonstrates how do use the LoginManager to complete Implicit Grant Authorization
/// and how to use the user profile, trip history, and places endpoints.
class ImplicitGrantExampleViewController: AuthorizationBaseViewController {
    /// The LoginManager to use for login
    let loginManager = LoginManager(loginType: .implicit)
    
    /// The RidesClient to use for endpoints
    let ridesClient = RidesClient()
    
    /// Variables to store retrieved information
    fileprivate var profile: UserProfile?
    fileprivate var places = [Place?](repeating: nil, count: 2)
    fileprivate var history = [UserActivity]()
    
    /// Constants representing each section
    fileprivate let ProfileSection = 0
    fileprivate let PlacesSection = 1
    fileprivate let HistorySection = 2
    
    /// Reuse identifiers for the table view cells
    fileprivate let ProfileCell = "ProfileCell"
    fileprivate let PlacesCell = "PlacesCell"
    fileprivate let HistoryCell = "HistoryCell"
    
    /// Rows in the "Places" section
    fileprivate let homePlaceRow = 0
    fileprivate let workPlaceRow = 1

    /// Custom views in the "Profile" section
    fileprivate let profileImageTag = 1
    fileprivate let profileLabelTag = 2
    
    /// Outlets
    @IBOutlet weak var loginButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        loginButton.isEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let _ = TokenManager.fetchToken() {
            loginButton.isEnabled = false
            getData()
        }
    }
    
    override func reset() {
        profile = nil
        self.tableView.reloadData()
        loginButton.isEnabled = true
    }
    
    @IBAction func login(_ sender: AnyObject) {
        // Define which scopes we're requesting
        // Need to be authorized on your developer dashboard at developer.uber.com
        let requestedScopes = [UberScope.rideWidgets, UberScope.profile, UberScope.places, UberScope.history, UberScope.places]
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
    
    fileprivate func getData() {
        // Examples of various data that can be retrieved
        
        // Retrieves UserProfile for the current logged in user
        ridesClient.fetchUserProfile() { profile, response in
            self.checkError(response)
            if let profile = profile {
                DispatchQueue.main.async {
                    self.profile = profile
                    self.tableView.reloadData()
                }
            }
        }
        
        // Gets the address assigned as the "home" address for current user
        ridesClient.fetchPlace(placeID: Place.home) { place, response in
            self.checkError(response)
            DispatchQueue.main.async {
                self.places[self.homePlaceRow] = place
                self.tableView.reloadData()
            }
        }
        
        // Gets the address assigned as the "work" address for current user
        ridesClient.fetchPlace(placeID: Place.work) { place, response in
            self.checkError(response)
            DispatchQueue.main.async {
                self.places[self.workPlaceRow] = place
                self.tableView.reloadData()
            }
        }
        
        // Gets the last 25 trips that the current user has taken
        ridesClient.fetchTripHistory(limit: 25) { tripHistory, response in
            self.checkError(response)
            guard let history = tripHistory?.history else {
                return
            }
            
            DispatchQueue.main.async {
                self.history = history
                self.tableView.reloadData()
            }
        }
    }
}

extension ImplicitGrantExampleViewController: UITableViewDataSource {
    // Only show rows in section if we have a profile
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case ProfileSection:
            guard let profile = profile,
                let profilePicture = profile.picturePath,
                let firstName = profile.firstName,
                let lastName = profile.lastName,
                let email = profile.email else {
                fallthrough
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: ProfileCell) ?? UITableViewCell(style: .default, reuseIdentifier: ProfileCell)
            
            let profileLabel = cell.viewWithTag(profileLabelTag) as? UILabel
            profileLabel?.text = "\(firstName) \(lastName)\n\(email)"
            
            if let url = URL(string: profilePicture) {
                URLSession.shared.dataTask(with: url, completionHandler: {
                    (data, response, error) in
                    DispatchQueue.main.async(execute: {
                        let imageView = cell.viewWithTag(self.profileImageTag) as? UIImageView
                        if let imageView = imageView, let data = data {
                            imageView.image = UIImage(data: data)
                        }
                    })
                }).resume()
            }
            
            return cell
        case PlacesSection:
            let cell = tableView.dequeueReusableCell(withIdentifier: PlacesCell) ??
                UITableViewCell(style: .default, reuseIdentifier: PlacesCell)
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
            let startCity = trip.startCity?.name ?? ""
            
            let cell = tableView.dequeueReusableCell(withIdentifier: HistoryCell) ??
                UITableViewCell(style: .default, reuseIdentifier: HistoryCell)
            cell.textLabel?.text = startCity
            
            if let startTime = trip.startTime,
                let endTime = trip.endTime {
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .short
                dateFormatter.timeStyle = .short
                cell.detailTextLabel?.text = "\(dateFormatter.string(from: startTime)) to \(dateFormatter.string(from: endTime))"
            } else {
                cell.detailTextLabel?.text = ""
            }
            
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
}

extension ImplicitGrantExampleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        guard indexPath.section == PlacesSection else {
            return
        }
        
        let alertController = UIAlertController(title: "Update Place Address", message: nil, preferredStyle: .alert)
        alertController.addTextField(configurationHandler: { (textField) in
            if let place = self.places[indexPath.row] {
                textField.placeholder = place.address
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        let updateAction = UIAlertAction(title: "Update", style: .default) { (_) in
            let addressTextField = alertController.textFields![0] as UITextField
            
            guard let address = addressTextField.text else {
                return
            }
            
            let placeID = indexPath.row == self.homePlaceRow ? Place.home : Place.work
            self.ridesClient.updatePlace(placeID: placeID, withAddress: address) { place, response in
                if response.error == nil, let place = place {
                    DispatchQueue.main.async {
                        self.places[indexPath.row] = place
                        self.tableView.reloadData()
                    }
                }
            }
        }
        
        alertController.addAction(updateAction)
        alertController.addAction(cancelAction)
        
        self.view.setNeedsLayout()
        self.present(alertController, animated: true, completion: nil)
    }
}
