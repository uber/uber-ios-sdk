//
//  Copyright © Uber Technologies, Inc. All rights reserved.
//


import Foundation

extension Bundle {
    
    static func resource(for targetClass: AnyClass?) -> Bundle {
#if SWIFT_PACKAGE
        return .module
#endif
        if let targetClass {
            return Bundle(for: targetClass)
        }
        return .main
    }
}
