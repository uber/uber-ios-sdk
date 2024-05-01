//
//  Copyright © Uber Technologies, Inc. All rights reserved.
//


import UIKit

extension UIColor {
    
    static let uberButtonBackground: UIColor = UIColor(
        named: "UberButtonBackground",
        in: .module,
        compatibleWith: nil
    ) ?? UIColor.darkText
    
    static let uberButtonHighlightedBackground: UIColor = UIColor(
        named: "UberButtonHighlightedBackground",
        in: .module,
        compatibleWith: nil
    ) ?? UIColor.darkText
    
    static let uberButtonForeground: UIColor = UIColor(
        named: "UberButtonForeground",
        in: .module,
        compatibleWith: nil
    ) ?? UIColor.lightText
}
