//
//  UberButtonView.swift
//  UberSDK
//
//  Copyright © 2024 Uber Technologies, Inc. All rights reserved.
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
import Foundation
import SwiftUI
import UberAuth
import UberCore
import UberRides

struct UberButtonView: UIViewRepresentable {
    func makeUIView(context: Context) -> UberCore.UberButton {
        LoginButton()
    }
    
    func updateUIView(_ uiView: UberCore.UberButton, context: Context) {}
}

struct RideRequestButtonView: UIViewRepresentable {
    
    private let delegate = RideRequestViewDelegate()
    
    private let sampleRideParameters = RideParametersBuilder(
        productID: "a1111c8c-c720-46c3-8534-2fcdd730040d",
        pickupLocation: CLLocation(latitude: 37.770, longitude: -122.466),
        pickupNickname: "California Academy of Science",
        pickupAddress: "55 Music Concourse Drive, San Francisco",
        dropoffLocation: CLLocation(latitude: 37.791, longitude: -122.405),
        dropoffNickname: "Pier 39", 
        dropoffAddress: "Beach Street & The Embarcadero, San Francisco",
        paymentMethod: "paymentMethod",
        surgeConfirmationID: "surgeConfirm"
    )
    .build()
    
    
    func makeUIView(context: Context) -> UberCore.UberButton {
        let button = RideRequestButton(rideParameters: sampleRideParameters)
        button.delegate = delegate
        return button
    }
    
    func updateUIView(_ uiView: UberCore.UberButton, context: Context) {
        (uiView as? RideRequestButton)?.loadRideInformation()
    }
}

fileprivate final class RideRequestViewDelegate: RideRequestButtonDelegate {
    
    func rideRequestButtonDidLoadRideInformation(_ button: UberRides.RideRequestButton) {
        
    }
    
    func rideRequestButton(_ button: UberRides.RideRequestButton, didReceiveError error: UberRides.UberError) {
        
    }
}

#Preview {
    VStack {
        UberButtonView()
            .padding()
        
        RideRequestButtonView()
            .padding()
    }
}
