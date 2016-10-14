//
//  DeeplinkRequestingBehavior.swift
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
@objc(UBSDKDeeplinkRequestingBehavior) open class DeeplinkRequestingBehavior : NSObject, RideRequesting {
        
    /**
     Requests a ride using a RequestDeeplink that is constructed using the provided
     rideParameters
     
     - parameter rideParameters: The RideParameters to use for building and executing 
     the deeplink
     */
    @objc open func requestRide(_ rideParameters: RideParameters?) {
        guard let rideParameters = rideParameters else {
            return
        }
        let deeplink = createDeeplink(rideParameters)
        
        let deeplinkCompletion: (NSError?) -> () = { error in
            if let error = error , error.code != DeeplinkErrorType.deeplinkNotFollowed.rawValue {
                self.createAppStoreDeeplink(rideParameters).execute(nil)
            }
        }
        
        deeplink.execute(deeplinkCompletion)
    }
    
    func createDeeplink(_ rideParameters: RideParameters) -> RequestDeeplink {
        return RequestDeeplink(rideParameters: rideParameters)
    }
    
    func createAppStoreDeeplink(_ rideParameters: RideParameters) -> Deeplinking {
        return AppStoreDeeplink(userAgent: rideParameters.userAgent)
    }
}
