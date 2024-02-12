//
//  Copyright © Uber Technologies, Inc. All rights reserved.
//


import Foundation

public class Prefill: NSObject {
    public let email: String?
    public let phoneNumber: String?
    public let firstName: String?
    public let lastName: String?
    
    public init(email: String? = nil,
                phoneNumber: String? = nil,
                firstName: String? = nil,
                lastName: String? = nil) {
        self.email = email
        self.phoneNumber = phoneNumber
        self.firstName = firstName
        self.lastName = lastName
    }
    
    var dictValue: [String: String] {
        [
            "email": email,
            "phone": phoneNumber,
            "first_name": firstName,
            "last_name": lastName
        ]
        .compactMapValues { $0 }
    }
}
