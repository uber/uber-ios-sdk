//
//  Copyright © Uber Technologies, Inc. All rights reserved.
//


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
