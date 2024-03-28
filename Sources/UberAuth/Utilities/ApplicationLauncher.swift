//
//  Copyright © Uber Technologies, Inc. All rights reserved.
//


import Foundation
import UIKit

/// @mockable
protocol ApplicationLaunching {
    
    func open(_ url: URL, options: [UIApplication.OpenExternalURLOptionsKey: Any], completionHandler: ((Bool) -> Void)?)
}

extension UIApplication: ApplicationLaunching {}
