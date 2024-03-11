//
//  Copyright © Uber Technologies, Inc. All rights reserved.
//


import Foundation
import UberAuth

enum LoginType: String, CaseIterable, SelectionOption {
    case authorizationCode = "Authorization Code"

    var description: String { rawValue }
    var id: String { rawValue }
}

enum LoginDestination: String, CaseIterable, SelectionOption {
    case inApp = "In App"
    case native = "Native"    
    
    var description: String { rawValue }
    var id: String { rawValue }
}
