//
//  RidesClient.swift
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

import CoreLocation
import UberCore

/// API client for the Uber Rides API.
@objc(UBSDKRidesClient) public class RidesClient: NSObject {
    
    /// Application client ID. Required for every instance of RidesClient.
    var clientID: String = Configuration.shared.clientID

    /// The Access Token Identifier. The identifier to use for looking up this client's accessToken
    let accessTokenIdentifier: String

    /// The Keychain Access Group. The access group to use when looking up this client's accessToken
    let keychainAccessGroup: String

    /// NSURLSession used to make requests to Uber API. Default session configuration unless otherwise initialized.
    var session: URLSession

    /// Developer server token.
    private var serverToken: String? = Configuration.shared.serverToken
    
    /**
     Initializer for the RidesClient. The RidesClient handles making requests to the API
     for you.
     
     - parameter accessTokenIdentifier: The accessTokenIdentifier to use. This identifier
     is used (along with keychainAccessGroup) to fetch the appropriate AccessToken. Defaults
     to the value set in your Configuration struct
     - parameter sessionConfiguration:  Configuration to use for NSURLSession. Defaults to defaultSessionConfiguration.
     - parameter keychainAccessGroup:   The keychain access group to use. Uses this group
     (along with the accessTokenIdentifier) to fetch the appropriate AccessToken. Defaults
     to the value set in yoru Configuration struct
     
     - returns: An initialized RidesClient
     */
    @objc public init(accessTokenIdentifier: String, sessionConfiguration: URLSessionConfiguration, keychainAccessGroup: String) {
        self.accessTokenIdentifier = accessTokenIdentifier
        self.keychainAccessGroup = keychainAccessGroup
        self.session = URLSession(configuration: sessionConfiguration)
    }
    
    /**
     Initializer for the RidesClient. The RidesClient handles making requests to the API
     for you.
     By default, uses NSURLSessionConfiguration.defaultSessionConfiguration() for the URL requests
     
     - parameter accessTokenIdentifier: Initializer for the RidesClient. The RidesClient handles making requests to the API
     for you.
     By default, it is initialized using the keychainAccessGroup default from your Configuration object
     Also uses NSURLSessionConfiguration.defaultSessionConfiguration() for the URL requests
     - parameter keychainAccessGroup:   The keychain access group to use. Uses this group
     (along with the accessTokenIdentifier) to fetch the appropriate AccessToken. Defaults
     to the value set in yoru Configuration struct
     
     - returns: An initialized RidesClient
     */
    @objc public convenience init(accessTokenIdentifier: String, keychainAccessGroup: String) {
        self.init(accessTokenIdentifier: accessTokenIdentifier,
                  sessionConfiguration: URLSessionConfiguration.default,
                  keychainAccessGroup: keychainAccessGroup)
    }
    
    /**
     Initializer for the RidesClient. The RidesClient handles making requests to the API
     for you.
     By default, it is initialized using the keychainAccessGroup default from your Configuration object
     
     - parameter accessTokenIdentifier: The accessTokenIdentifier to use. This identifier
     is used (along with keychainAccessGroup) to fetch the appropriate AccessToken
     - parameter sessionConfiguration:   Configuration to use for NSURLSession. Defaults to defaultSessionConfiguration.
     
     - returns: An initialized RidesClient
     */
    @objc public convenience init(accessTokenIdentifier: String, sessionConfiguration: URLSessionConfiguration) {
        self.init(accessTokenIdentifier: accessTokenIdentifier,
                  sessionConfiguration: sessionConfiguration,
                  keychainAccessGroup: Configuration.shared.defaultKeychainAccessGroup)
    }
    
    /**
     Initializer for the RidesClient. The RidesClient handles making requests to the API
     for you.
     By default, it is initialized using the keychainAccessGroup default from your Configuration object
     Also uses NSURLSessionConfiguration.defaultSessionConfiguration() for the URL requests
     
     - parameter accessTokenIdentifier: The accessTokenIdentifier to use. This identifier
     is used (along with keychainAccessGroup) to fetch the appropriate AccessToken
     
     - returns: An initialized RidesClient
     */
    @objc public convenience init(accessTokenIdentifier: String) {
        self.init(accessTokenIdentifier: accessTokenIdentifier,
                  sessionConfiguration: URLSessionConfiguration.default,
                  keychainAccessGroup: Configuration.shared.defaultKeychainAccessGroup)
    }
    
    /**
     Initializer for the RidesClient. The RidesClient handles making requests to the API
     for you.
     By default, it is initialized using the accessTokenIdentifier & keychainAccessGroup
     defaults from your Configuration object
     Also uses NSURLSessionConfiguration.defaultSessionConfiguration() for the URL requests
     
     - returns: An initialized RidesClient
     */
    @objc public convenience override init() {
        self.init(accessTokenIdentifier: Configuration.shared.defaultAccessTokenIdentifier,
                  sessionConfiguration: URLSessionConfiguration.default,
                  keychainAccessGroup: Configuration.shared.defaultKeychainAccessGroup)
    }
    
    /**
     Retrieves the token used by this rides client.
     
     Currently pulls from the keychain each time.
     
     - returns: an AccessToken object, or nil if one can't be located
     */
    @objc public func fetchAccessToken() -> AccessToken? {
        guard let accessToken = TokenManager.fetchToken(identifier: accessTokenIdentifier, accessGroup: keychainAccessGroup) else {
            return nil
        }
        return accessToken
    }
    
    /**
     Public getter to check for the existence of a server token.
     
     - returns: true if a server token exists, false otherwise.
     */
    @objc public var hasServerToken: Bool {
        return serverToken != nil
    }
    
    // MARK: Helper functions
    
    /**
    Helper function to execute request. All endpoints should use this function.
    
    - parameter endpoint:   endpoint that conforms to APIEndpoint.
    - parameter completion: completion block for when request is completed.
    */
    private func apiCall(_ endpoint: APIEndpoint, completion: @escaping (_ response: Response) -> Void) {
        
        let accessTokenString = fetchAccessToken()?.tokenString
        
        guard let request = Request(session: session, endpoint: endpoint, serverToken: serverToken, bearerToken: accessTokenString) else {
            let response = Response(data: nil, statusCode: 400, response: nil, error: UberError(status: 400, code: "bad_request", title: "Unable to create request"))
            completion(response)
            return
        }
        request.execute { response in
            completion(response)
        }
    }
    
    /**
     Helper function to execute request that will return a Ride object.
     
     - parameter endpoint:   endpoint that conforms to APIEndpoint.
     - parameter completion: user's completion block for returned ride.
     */
    private func apiCallForRideResponse(_ endpoint: APIEndpoint, completion:@escaping (_ ride: Ride?, _ response: Response) -> Void) {
        apiCall(endpoint, completion: { response in
            var ride: Ride? = nil
            if let data = response.data,
                response.error == nil {
                ride = try? JSONDecoder.uberDecoder.decode(Ride.self, from: data)
            }
            completion(ride, response)
        })
    }
    
    // MARK: Endpoints
    
    /**
     Get all products at specified location.
     
     - parameter location:  coordinates of pickup location
     - parameter completion: completion handler for returned products.
     */
    @objc public func fetchProducts(pickupLocation location: CLLocation, completion:@escaping (_ products: [Product], _ response: Response) -> Void) {
        let endpoint = Products.getAll(location: location)
        apiCall(endpoint, completion: { response in
            var products: UberProducts?
            if let data = response.data,
                response.error == nil {
                products = try? JSONDecoder.uberDecoder.decode(UberProducts.self, from: data)
                if let productList = products?.list {
                    completion(productList, response)
                    return
                }
            }
            completion([], response)
        })
    }
    
    /**
     Get information for specific product.
     
     - parameter productID:  string representing product ID.
     - parameter completion: completion handler for returned product.
     */
    @objc public func fetchProduct(productID: String, completion:@escaping (_ product: Product?, _ response: Response) -> Void) {
        let endpoint = Products.getProduct(productID: productID)
        apiCall(endpoint, completion: { response in
            var product: Product?
            if let data = response.data,
                response.error == nil {
                product = try? JSONDecoder.uberDecoder.decode(Product.self, from: data)
            }
            completion(product, response)
        })
    }
    
    /**
     Get time estimates for all products (or specific product) at specified pickup location.
     
     - parameter pickupLocation:  coordinates of pickup location
     - parameter productID:  optional string representing the productID.
     - parameter completion: completion handler for returned estimates.
     */
    @objc public func fetchTimeEstimates(pickupLocation location: CLLocation, productID: String? = nil, completion:@escaping (_ timeEstimates: [TimeEstimate], _ response: Response) -> Void) {
        let endpoint = Estimates.time(location: location, productID: productID)
        apiCall(endpoint, completion: { response in
            var timeEstimates: TimeEstimates?
            if let data = response.data,
                response.error == nil {
                timeEstimates = try? JSONDecoder.uberDecoder.decode(TimeEstimates.self, from: data)
                if let estimateList = timeEstimates?.list {
                    completion(estimateList, response)
                    return
                }
            }
            completion([], response)
        })
    }
    
    /**
     Get price estimates for all products between specified pickup and dropoff locations.
     
     - parameter pickupLocation:   coordinates of pickup location.
     - parameter dropoffLocation:  coordinates of dropoff location
     - parameter completion:       completion handler for returned estimates.
     */
    @objc public func fetchPriceEstimates(pickupLocation: CLLocation, dropoffLocation: CLLocation, completion:@escaping (_ priceEstimates: [PriceEstimate], _ response: Response) -> Void) {
        let endpoint = Estimates.price(startLocation: pickupLocation,
                                       endLocation: dropoffLocation)
        apiCall(endpoint, completion: { response in
            var priceEstimates: PriceEstimates?
            if let data = response.data,
                response.error == nil {
                priceEstimates = try? JSONDecoder.uberDecoder.decode(PriceEstimates.self, from: data)
                if let estimateList = priceEstimates?.list {
                    completion(estimateList, response)
                    return
                }
            }
            completion([], response)
        })
    }
    
    /**
     Get trip history for current authenticated user.
     
     - parameter offset:     offset the list of returned results by this amount. Default is zero.
     - parameter limit:      number of items to retrieve. Default is 5, maximum is 50.
     - parameter completion: completion handler for returned user trip history.
     */
    @objc public func fetchTripHistory(offset: Int = 0, limit: Int = 5, completion:@escaping (_ tripHistory: TripHistory?, _ response: Response) -> Void) {
        let endpoint = History.get(offset: offset, limit: limit)
        apiCall(endpoint, completion: { response in
            var history: TripHistory?
            if let data = response.data,
                response.error == nil {
                history = try? JSONDecoder.uberDecoder.decode(TripHistory.self, from: data)
            }
            completion(history, response)
        })
    }
    
    /**
    Gets user profile of current authenticated user.
    
    - parameter completion: completion handler for returned user profile.
    */
    @objc public func fetchUserProfile(completion:@escaping (_ profile: UserProfile?, _ response: Response) -> Void) {
        let endpoint = Me.userProfile
        apiCall(endpoint, completion: { response in
            var userProfile: UserProfile?
            if let data = response.data,
                response.error == nil {
                userProfile = try? JSONDecoder.uberDecoder.decode(UserProfile.self, from: data)
            }
            completion(userProfile, response)
        })
    }
    
    /**
     Request a ride on behalf of Uber user.
     
     - parameter parameters: RideParameters object containing paramaters for the request.
     - parameter completion:  completion handler for returned request information.
     */
    @objc public func requestRide(parameters: RideParameters, completion:@escaping (_ ride: Ride?, _ response: Response) -> Void) {
        let endpoint = Requests.make(rideParameters: parameters)
        apiCallForRideResponse(endpoint, completion: completion)
    }
    
    /**
     Get the real-time details for an ongoing ride.
     
     - parameter completion: completion handler for returned ride information.
     */
    @objc public func fetchCurrentRide(completion: @escaping (_ ride: Ride?, _ response: Response) -> Void) {
        let endpoint = Requests.getCurrent
        apiCallForRideResponse(endpoint, completion: completion)
    }
    
    /**
     Get the status of an ongoing or completed ride that was created using the Ride Request endpoint.
     
     - parameter requestID:  unique identifier representing a Request.
     - parameter completion: completion handler for returned trip information.
     */
    @objc public func fetchRideDetails(requestID: String, completion:@escaping (_ ride: Ride? , _ response: Response) -> Void) {
        let endpoint = Requests.getRequest(requestID: requestID)
        apiCallForRideResponse(endpoint, completion: completion)
    }
    
    /**
     Estimate a ride request given the desired product, start, and end locations.
     
     - parameter rideParameters: RideParameters object containing necessary information.
     - parameter completion:  completion handler for returned estimate.
     */
    @objc public func fetchRideRequestEstimate(parameters: RideParameters, completion:@escaping (_ estimate: RideEstimate?, _ response: Response) -> Void) {
        let endpoint = Requests.estimate(rideParameters: parameters)
        apiCall(endpoint, completion: { response in
            var estimate: RideEstimate? = nil
            if let data = response.data,
                response.error == nil {
                estimate = try? JSONDecoder.uberDecoder.decode(RideEstimate.self, from: data)
            }
            completion(estimate, response)
        })
    }
    
    /**
     Retrieve the list of the user’s available payment methods.
     
     - parameter completion: completion handler for returned payment method list as well as last used payment method.
     */
    @objc public func fetchPaymentMethods(completion:@escaping (_ methods: [PaymentMethod], _ lastUsed: PaymentMethod?, _ response: Response) -> Void) {
        let endpoint = Payment.getMethods
        apiCall(endpoint, completion: { response in
            var paymentMethods = [PaymentMethod]()
            var lastUsed: PaymentMethod?
            if response.error == nil,
                let data = response.data,
                let allPayments = try? JSONDecoder.uberDecoder.decode(PaymentMethods.self, from: data),
                let payments = allPayments.list {
                paymentMethods = payments
                lastUsed = paymentMethods.filter({$0.methodID == allPayments.lastUsed}).first

            }
            completion(paymentMethods, lastUsed, response)
        })
    }
    
    /**
     Retrieve home and work addresses from an Uber user's profile.
     
     - parameter placeID:    the name of the place to retrieve. Only home and work are acceptable.
     - parameter completion: completion handler for returned place.
     */
    @objc public func fetchPlace(placeID: String, completion:@escaping (_ place: Place?, _ response: Response) -> Void) {
        let endpoint = Places.getPlace(placeID: placeID)
        apiCall(endpoint, completion: { response in
            var place: Place? = nil
            if let data = response.data,
                response.error == nil {
                place = try? JSONDecoder.uberDecoder.decode(Place.self, from: data)
            }
            completion(place, response)
        })
    }
    
    /**
     Update home and work addresses for an Uber user's profile.
     
     - parameter placeID:    the name of the place to update. Only home and work are acceptable.
     - parameter address:    the address of the place that should be tied to the given placeID.
     - parameter completion: completion handler for response.
     */
    @objc public func updatePlace(placeID: String, withAddress address: String, completion:@escaping (_ place: Place?, _ response: Response) -> Void) {
        let endpoint = Places.putPlace(placeID: placeID, address: address)
        apiCall(endpoint, completion: { response in
            var place: Place?
            if let data = response.data,
                response.error == nil {
                place = try? JSONDecoder.uberDecoder.decode(Place.self, from: data)
            }
            completion(place, response)
        })
    }
    
    /**
     Update the ride details for an ongoing ride by ID.
     
     - parameter requestID:   the ID of the ride request. If nil, will attempt to update current trip.
     - parameter rideParameters: the RideParameters object containing the updated parameters.
     - parameter completion:  completion handler for response.
     */
    @objc public func updateRideDetails(requestID: String?, rideParameters: RideParameters, completion:@escaping (_ response: Response) -> Void) {
        guard let requestID = requestID else {
            updateCurrentRide(rideParameters: rideParameters, completion: completion)
            return
        }
        
        let endpoint = Requests.patchRequest(requestID: requestID, rideParameters: rideParameters)
        apiCall(endpoint, completion: { response in
            completion(response)
        })
    }
    
    /**
     Update an ongoing request’s destination that was requested using the Ride Request endpoint.
     
     - parameter rideParameters: RideParameters object with updated ride parameters.
     - parameter completion:  completion handler for response.
     */
    @objc public func updateCurrentRide(rideParameters: RideParameters, completion:@escaping (_ response: Response) -> Void) {
        let endpoint = Requests.patchCurrent(rideParameters: rideParameters)
        apiCall(endpoint, completion: { response in
            completion(response)
        })
    }
    
    /**
     Cancel a user's ride using the request ID.
     
     - parameter requestID:  request ID of the ride. If nil, current ride will be canceled.
     - parameter completion: completion handler for response.
     */
    @objc public func cancelRide(requestID: String?, completion:@escaping (_ response: Response) -> Void) {
        guard let requestID = requestID else {
            cancelCurrentRide(completion: completion)
            return
        }
        
        let endpoint = Requests.deleteRequest(requestID: requestID)
        apiCall(endpoint, completion: { response in
            completion(response)
        })
    }
    
    /**
     Cancel the user's current trip. This endpoint can only be used on trips that your app requested.
     
     - parameter completion: completion handler for response
     */
    @objc public func cancelCurrentRide(completion:@escaping (_ response: Response) -> Void) {
        let endpoint = Requests.deleteCurrent
        apiCall(endpoint, completion: { response in
            completion(response)
        })
    }
    
    /**
     Get the receipt information of a completed request.
     
     - parameter requestID:  unique identifier representing a ride request
     - parameter completion: completion handler for receipt
     */
    @objc public func fetchRideReceipt(requestID: String, completion:@escaping (_ rideReceipt: RideReceipt?, _ response: Response) -> Void) {
        let endpoint = Requests.rideReceipt(requestID: requestID)
        apiCall(endpoint, completion: { response in
            var receipt: RideReceipt?
            if let data = response.data,
                response.error == nil {
                receipt = try? JSONDecoder.uberDecoder.decode(RideReceipt.self, from: data)
            }
            completion(receipt, response)
        })
    }
    
    /**
     Get a map with a visual representation of a Request.
     
     - parameter requestID:  unique identifier representing a request
     - parameter completion: completion handler for map
     */
    @objc public func fetchRideMap(requestID: String, completion:@escaping (_ map: RideMap?, _ response: Response) -> Void) {
        let endpoint = Requests.rideMap(requestID: requestID)
        apiCall(endpoint, completion: { response in
            var map: RideMap?
            if let data = response.data,
                response.error == nil {
                map = try? JSONDecoder.uberDecoder.decode(RideMap.self, from: data)
            }
            completion(map, response)
        })
    }
    
    /**
     Get a refreshed AccessToken from a refresh token string. Only works for access
     tokens retrieved via SSO
     
     - parameter refreshToken: The Refresh Token String from an SSO access token
     - parameter completion:   completion handler for the new access token
     */
    @objc public func refreshAccessToken(usingRefreshToken refreshToken: String, completion:@escaping (_ accessToken: AccessToken?, _ response: Response) -> Void) {
        let endpoint = OAuth.refresh(clientID: clientID, refreshToken: refreshToken)
        apiCall(endpoint) { response in
            var accessToken: AccessToken?
            if let data = response.data,
                response.error == nil {
                accessToken = try? AccessTokenFactory.createAccessToken(fromJSONData: data)
            }
            completion(accessToken, response)
        }
    }
}
