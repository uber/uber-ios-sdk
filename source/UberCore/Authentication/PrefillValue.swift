//
//  Copyright © Uber Technologies, Inc. All rights reserved.
//


import Foundation

@objc(UBSDKPrefill) public class Prefill: NSObject {
    @objc public let email: String?
    @objc public let phoneNumber: String?
    @objc public let firstName: String?
    @objc public let lastName: String?
    
    @objc public init(email: String? = nil,
                phoneNumber: String? = nil,
                firstName: String? = nil,
                lastName: String? = nil) {
        self.email = email
        self.phoneNumber = phoneNumber
        self.firstName = firstName
        self.lastName = lastName
    }
    
    @objc var dictValue: [String: String] {
        [
            "email": email,
            "phone": phoneNumber,
            "first_name": firstName,
            "last_name": lastName
        ]
        .compactMapValues { $0 }
    }
}
