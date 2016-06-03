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

/// API client for the Uber Rides API.
@objc(UBSDKRidesClient) public class RidesClient: NSObject {
    
    /// Application client ID. Required for every instance of RidesClient.
    var clientID: String = Configuration.getClientID()
    
    /// The Access Token Identifier. The identifier to use for looking up this client's accessToken
    let accessTokenIdentifier: String
    
    /// The Keychain Access Group. The access group to use when looking up this client's accessToken
    let keychainAccessGroup: String
    
    /// NSURLSession used to make requests to Uber API. Default session configuration unless otherwise initialized.
    var session: NSURLSession
    
    /// Developer server token.
    private var serverToken: String? = Configuration.getServerToken()
    
    /**
     Initializer for the RidesClient. The RidesClient handles making reqeusts to the API
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
    @objc public init(accessTokenIdentifier: String, sessionConfiguration: NSURLSessionConfiguration, keychainAccessGroup: String) {
        self.accessTokenIdentifier = accessTokenIdentifier
        self.keychainAccessGroup = keychainAccessGroup
        self.session = NSURLSession(configuration: sessionConfiguration)
    }
    
    /**
     Initializer for the RidesClient. The RidesClient handles making reqeusts to the API
     for you.
     By default, uses NSURLSessionConfiguration.defaultSessionConfiguration() for the URL requests
     
     - parameter accessTokenIdentifier: Initializer for the RidesClient. The RidesClient handles making reqeusts to the API
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
                  sessionConfiguration: NSURLSessionConfiguration.defaultSessionConfiguration(),
                  keychainAccessGroup: keychainAccessGroup)
    }
    
    /**
     Initializer for the RidesClient. The RidesClient handles making reqeusts to the API
     for you.
     By default, it is initialized using the keychainAccessGroup default from your Configuration object
     
     - parameter accessTokenIdentifier: The accessTokenIdentifier to use. This identifier
     is used (along with keychainAccessGroup) to fetch the appropriate AccessToken
     - parameter sessionConfiguration:   Configuration to use for NSURLSession. Defaults to defaultSessionConfiguration.
     
     - returns: An initialized RidesClient
     */
    @objc public convenience init(accessTokenIdentifier: String, sessionConfiguration: NSURLSessionConfiguration) {
        self.init(accessTokenIdentifier: accessTokenIdentifier,
                  sessionConfiguration: sessionConfiguration,
                  keychainAccessGroup: Configuration.getDefaultKeychainAccessGroup())
    }
    
    /**
     Initializer for the RidesClient. The RidesClient handles making reqeusts to the API
     for you.
     By default, it is initialized using the keychainAccessGroup default from your Configuration object
     Also uses NSURLSessionConfiguration.defaultSessionConfiguration() for the URL requests
     
     - parameter accessTokenIdentifier: The accessTokenIdentifier to use. This identifier
     is used (along with keychainAccessGroup) to fetch the appropriate AccessToken
     
     - returns: An initialized RidesClient
     */
    @objc public convenience init(accessTokenIdentifier: String) {
        self.init(accessTokenIdentifier: accessTokenIdentifier,
                  sessionConfiguration: NSURLSessionConfiguration.defaultSessionConfiguration(),
                  keychainAccessGroup: Configuration.getDefaultKeychainAccessGroup())
    }
    
    /**
     Initializer for the RidesClient. The RidesClient handles making reqeusts to the API
     for you.
     By default, it is initialized using the accessTokenIdentifier & keychainAccessGroup
     defaults from your Configuration object
     Also uses NSURLSessionConfiguration.defaultSessionConfiguration() for the URL requests
     
     - returns: An initialized RidesClient
     */
    @objc public convenience override init() {
        self.init(accessTokenIdentifier: Configuration.getDefaultAccessTokenIdentifier(),
                  sessionConfiguration: NSURLSessionConfiguration.defaultSessionConfiguration(),
                  keychainAccessGroup: Configuration.getDefaultKeychainAccessGroup())
    }
    
    /**
     Retrieves the token used by this rides client.
     
     Currently pulls from the keychain each time.
     
     - returns: an AccessToken object, or nil if one can't be located
     */
    @objc public func fetchAccessToken() -> AccessToken? {
        guard let accessToken = TokenManager.fetchToken(accessTokenIdentifier, accessGroup: keychainAccessGroup) else {
            return nil
        }
        return accessToken
    }
    
    /**
     Public getter to check for the existence of a server token.
     
     - returns: true if a server token exists, false otherwise.
     */
    @objc public func hasServerToken() -> Bool {
        return serverToken != nil
    }
    
    // MARK: Helper functions
    
    /**
    Helper function to execute request. All endpoints should use this function.
    
    - parameter endpoint:   endpoint that conforms to UberAPI.
    - parameter completion: completion block for when request is completed.
    */
    private func apiCall(endpoint: UberAPI, completion: (response: Response) -> Void) {
        
        let accessTokenString = fetchAccessToken()?.tokenString
        
        let request = Request(session: session, endpoint: endpoint, serverToken: serverToken, bearerToken: accessTokenString)
        request.execute({
            response in
            completion(response: response)
        })
    }
    
    /**
     Helper function to execute request that will return a Ride object.
     
     - parameter endpoint:   endpoint that conforms to UberAPI.
     - parameter completion: user's completion block for returned ride.
     */
    private func apiCallForRideResponse(endpoint: UberAPI, completion:(ride: Ride?, response: Response) -> Void) {
        apiCall(endpoint, completion: { response in
            var ride: Ride? = nil
            if response.error == nil {
                ride = ModelMapper<Ride>().mapFromJSON(response.toJSONString())
            }
            completion(ride: ride, response: response)
        })
    }
    
    // MARK: Endpoints
    
    /**
    Convenience function for returning cheapest product at location.
    
    - parameter location:  coordinates of pickup location.
    - parameter completion: completion handler for returned product.
    */
    @objc public func fetchCheapestProduct(pickupLocation location: CLLocation, completion:(product: UberProduct?, response: Response) -> Void) {
        fetchProducts(pickupLocation: location, completion:{ products, response in
            let filteredProducts = products.filter({$0.priceDetails != nil})
            if filteredProducts.count == 0 {
                completion(product: nil, response: response)
                return
            }
            
            // Find cheapest product by first comparing minimum value, then by cost per distance; compared in order such that products earlier in display order are favored.
            let cheapestMinimumValue = filteredProducts.reduce(filteredProducts[0].priceDetails!.minimumFee, combine: {min($0, $1.priceDetails!.minimumFee)})
            let cheapestProducts = filteredProducts.filter({$0.priceDetails!.minimumFee == cheapestMinimumValue})
            let cheapest = cheapestProducts.reduce(cheapestProducts[0], combine: {$1.priceDetails!.costPerDistance < $0.priceDetails!.costPerDistance ? $1 : $0})
            
            completion(product: cheapest, response: response)
        })
    }
    
    /**
     Get all products at specified location.
     
     - parameter location:  coordinates of pickup location
     - parameter completion: completion handler for returned products.
     */
    @objc public func fetchProducts(pickupLocation location: CLLocation, completion:(products: [UberProduct], response: Response) -> Void) {
        let endpoint = Products.GetAll(location: location)
        apiCall(endpoint, completion: { response in
            var products: UberProducts?
            if response.error == nil {
                products = ModelMapper<UberProducts>().mapFromJSON(response.toJSONString())
                if let productList = products?.list {
                    completion(products: productList, response: response)
                    return
                }
            }
            completion(products: [], response: response)
        })
    }
    
    /**
     Get information for specific product.
     
     - parameter productID:  string representing product ID.
     - parameter completion: completion handler for returned product.
     */
    @objc public func fetchProduct(productID: String, completion:(product: UberProduct?, response: Response) -> Void) {
        let endpoint = Products.GetProduct(productID: productID)
        apiCall(endpoint, completion: { response in
            var product: UberProduct?
            if response.error == nil {
                product = ModelMapper<UberProduct>().mapFromJSON(response.toJSONString())
            }
            completion(product: product, response: response)
        })
    }
    
    /**
     Get time estimates for all products (or specific product) at specified pickup location.
     
     - parameter pickupLocation:  coordinates of pickup location
     - parameter productID:  optional string representing the productID.
     - parameter completion: completion handler for returned estimates.
     */
    @objc public func fetchTimeEstimates(pickupLocation location: CLLocation, productID: String? = nil, completion:(timeEstimates: [TimeEstimate], response: Response) -> Void) {
        let endpoint = Estimates.Time(location: location, productID: productID)
        apiCall(endpoint, completion: { response in
            var timeEstimates: TimeEstimates?
            if response.error == nil {
                timeEstimates = ModelMapper<TimeEstimates>().mapFromJSON(response.toJSONString())
                if let estimateList = timeEstimates?.list {
                    completion(timeEstimates: estimateList, response: response)
                    return
                }
            }
            completion(timeEstimates: [], response: response)
        })
    }
    
    /**
     Get price estimates for all products between specified pickup and dropoff locations.
     
     - parameter pickupLocation:   coordinates of pickup location.
     - parameter dropoffLocation:  coordinates of dropoff location
     - parameter completion:       completion handler for returned estimates.
     */
    @objc public func fetchPriceEstimates(pickupLocation pickupLocation: CLLocation, dropoffLocation: CLLocation, completion:(priceEstimates: [PriceEstimate], response: Response) -> Void) {
        let endpoint = Estimates.Price(startLocation: pickupLocation,
                                       endLocation: dropoffLocation)
        apiCall(endpoint, completion: { response in
            var priceEstimates: PriceEstimates?
            if response.error == nil {
                priceEstimates = ModelMapper<PriceEstimates>().mapFromJSON(response.toJSONString())
                if let estimateList = priceEstimates?.list {
                    completion(priceEstimates: estimateList, response: response)
                    return
                }
            }
            completion(priceEstimates: [], response: response)
        })
    }
    
    /**
     Get trip history for current authenticated user.
     
     - parameter offset:     offset the list of returned results by this amount. Default is zero.
     - parameter limit:      number of items to retrieve. Default is 5, maximum is 50.
     - parameter completion: completion handler for returned user trip history.
     */
    @objc public func fetchTripHistory(offset offset: Int = 0, limit: Int = 5, completion:(tripHistory: TripHistory?, response: Response) -> Void) {
        let endpoint = History.Get(offset: offset, limit: limit)
        apiCall(endpoint, completion: { response in
            var history: TripHistory?
            if response.error == nil {
                history = ModelMapper<TripHistory>().mapFromJSON(response.toJSONString())
            }
            completion(tripHistory: history, response: response)
        })
    }
    
    /**
    Gets user profile of current authenticated user.
    
    - parameter completion: completion handler for returned user profile.
    */
    @objc public func fetchUserProfile(completion:(profile: UserProfile?, response: Response) -> Void) {
        let endpoint = Me.UserProfile
        apiCall(endpoint, completion: { response in
            var userProfile: UserProfile?
            if response.error == nil {
                userProfile = ModelMapper<UserProfile>().mapFromJSON(response.toJSONString())
            }
            completion(profile: userProfile, response: response)
        })
    }
    
    /**
     Request a ride on behalf of Uber user.
     
     - parameter rideParameters: RideParameters object containing paramaters for the request.
     - parameter completion:  completion handler for returned request information.
     */
    @objc public func requestRide(rideParameters: RideParameters, completion:(ride: Ride?, response: Response) -> Void) {
        let endpoint = Requests.Make(rideParameters: rideParameters)
        apiCallForRideResponse(endpoint, completion: completion)
    }
    
    /**
     Get the real-time details for an ongoing ride.
     
     - parameter completion: completion handler for returned ride information.
     */
    @objc public func fetchCurrentRide(completion: (ride: Ride?, response: Response) -> Void) {
        let endpoint = Requests.GetCurrent
        apiCallForRideResponse(endpoint, completion: completion)
    }
    
    /**
     Get the status of an ongoing or completed ride that was created using the Ride Request endpoint.
     
     - parameter requestID:  unique identifier representing a Request.
     - parameter completion: completion handler for returned trip information.
     */
    @objc public func fetchRideDetails(requestID: String, completion:(ride: Ride? , response: Response) -> Void) {
        let endpoint = Requests.GetRequest(requestID: requestID)
        apiCallForRideResponse(endpoint, completion: completion)
    }
    
    /**
     Estimate a ride request given the desired product, start, and end locations.
     
     - parameter rideParameters: RideParameters object containing necessary information.
     - parameter completion:  completion handler for returned estimate.
     */
    @objc public func fetchRideRequestEstimate(rideParameters: RideParameters, completion:(estimate: RideEstimate?, response: Response) -> Void) {
        let endpoint = Requests.Estimate(rideParameters: rideParameters)
        apiCall(endpoint, completion: { response in
            var estimate: RideEstimate? = nil
            if response.error == nil {
                estimate = ModelMapper<RideEstimate>().mapFromJSON(response.toJSONString())
            }
            completion(estimate: estimate, response: response)
        })
    }
    
    /**
     Retrieve the list of the user’s available payment methods.
     
     - parameter completion: completion handler for returned payment method list as well as last used payment method.
     */
    @objc public func fetchPaymentMethods(completion:(methods: [PaymentMethod], lastUsed: PaymentMethod?, response: Response) -> Void) {
        let endpoint = Payment.GetMethods
        apiCall(endpoint, completion: { response in
            var paymentMethods = [PaymentMethod]()
            var lastUsed: PaymentMethod?
            if response.error == nil,
                let allPayments = ModelMapper<PaymentMethods>().mapFromJSON(response.toJSONString()),
                let payments = allPayments.list {
                paymentMethods = payments
                lastUsed = paymentMethods.filter({$0.methodID == allPayments.lastUsed}).first

            }
            completion(methods: paymentMethods, lastUsed: lastUsed, response: response)
        })
    }
    
    /**
     Retrieve home and work addresses from an Uber user's profile.
     
     - parameter placeID:    the name of the place to retrieve. Only home and work are acceptable.
     - parameter completion: completion handler for returned place.
     */
    @objc public func fetchPlace(placeID: String, completion:(place: Place?, response: Response) -> Void) {
        let endpoint = Places.GetPlace(placeID: placeID)
        apiCall(endpoint, completion: { response in
            var place: Place? = nil
            if response.error == nil {
                place = ModelMapper<Place>().mapFromJSON(response.toJSONString())
            }
            completion(place: place, response: response)
        })
    }
    
    /**
     Update home and work addresses for an Uber user's profile.
     
     - parameter placeID:    the name of the place to update. Only home and work are acceptable.
     - parameter address:    the address of the place that should be tied to the given placeID.
     - parameter completion: completion handler for response.
     */
    @objc public func updatePlace(placeID: String, withAddress address: String, completion:(place: Place?, response: Response) -> Void) {
        let endpoint = Places.PutPlace(placeID: placeID, address: address)
        apiCall(endpoint, completion: { response in
            var place: Place?
            if response.error == nil {
                place = ModelMapper<Place>().mapFromJSON(response.toJSONString())
            }
            completion(place: place, response: response)
        })
    }
    
    /**
     Update the ride details for an ongoing ride by ID.
     
     - parameter requestID:   the ID of the ride request. If nil, will attempt to update current trip.
     - parameter rideParameters: the RideParameters object containing the updated parameters.
     - parameter completion:  completion handler for response.
     */
    @objc public func updateRideDetails(requestID: String?, rideParameters: RideParameters, completion:(response: Response) -> Void) {
        guard let requestID = requestID else {
            updateCurrentRide(rideParameters, completion: completion)
            return
        }
        
        let endpoint = Requests.PatchRequest(requestID: requestID, rideParameters: rideParameters)
        apiCall(endpoint, completion: { response in
            completion(response: response)
        })
    }
    
    /**
     Update an ongoing request’s destination that was requested using the Ride Request endpoint.
     
     - parameter rideParameters: RideParameters object with updated ride parameters.
     - parameter completion:  completion handler for response.
     */
    @objc public func updateCurrentRide(rideParameters: RideParameters, completion:(response: Response) -> Void) {
        let endpoint = Requests.PatchCurrent(rideParameters: rideParameters)
        apiCall(endpoint, completion: { response in
            completion(response: response)
        })
    }
    
    /**
     Cancel a user's ride using the request ID.
     
     - parameter requestID:  request ID of the ride. If nil, current ride will be canceled.
     - parameter completion: completion handler for response.
     */
    @objc public func cancelRide(requestID: String?, completion:(response: Response) -> Void) {
        guard let requestID = requestID else {
            cancelCurrentRide(completion)
            return
        }
        
        let endpoint = Requests.DeleteRequest(requestID: requestID)
        apiCall(endpoint, completion: { response in
            completion(response: response)
        })
    }
    
    /**
     Cancel the user's current trip. This endpoint can only be used on trips that your app requested.
     
     - parameter completion: completion handler for response
     */
    @objc public func cancelCurrentRide(completion:(response: Response) -> Void) {
        let endpoint = Requests.DeleteCurrent
        apiCall(endpoint, completion: { response in
            completion(response: response)
        })
    }
    
    /**
     Get the receipt information of a completed request.
     
     - parameter requestID:  unique identifier representing a ride request
     - parameter completion: completion handler for receipt
     */
    public func fetchRideReceipt(requestID: String, completion:(rideReceipt: RideReceipt?, response: Response) -> Void) {
        let endpoint = Requests.RideReceipt(requestID: requestID)
        apiCall(endpoint, completion: { response in
            var receipt: RideReceipt?
            if response.error == nil {
                receipt = ModelMapper<RideReceipt>().mapFromJSON(response.toJSONString())
            }
            completion(rideReceipt: receipt, response: response)
        })
    }
    
    /**
     Get a map with a visual representation of a Request.
     
     - parameter requestID:  unique identifier representing a request
     - parameter completion: completion handler for map
     */
    public func fetchRideMap(requestID: String, completion:(map: RideMap?, response: Response) -> Void) {
        let endpoint = Requests.RideMap(requestID: requestID)
        apiCall(endpoint, completion: { response in
            var map: RideMap?
            if response.error == nil {
                map = ModelMapper<RideMap>().mapFromJSON(response.toJSONString())
            }
            completion(map: map, response: response)
        })
    }
    
    /**
     Get a refreshed AccessToken from a refresh token string. Only works for access
     tokens retrieved via SSO
     
     - parameter refreshToken: The Refresh Token String from an SSO access token
     - parameter completion:   completion handler for the new access token
     */
    public func refreshAccessToken(refreshToken: String, completion:(accessToken: AccessToken?, response: Response) -> Void) {
        let endpoint = OAuth.Refresh(clientID: clientID, refreshToken: refreshToken)
        apiCall(endpoint) { response in
            var accessToken: AccessToken?
            if response.error == nil {
                accessToken = ModelMapper<AccessToken>().mapFromJSON(response.toJSONString())
            }
            completion(accessToken: accessToken, response: response)
        }
    }
}
