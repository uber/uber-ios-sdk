//
//  Copyright © Uber Technologies, Inc. All rights reserved.
//


import UIKit

public extension UIColor {
    
    static let uberButtonBackground: UIColor = UIColor(
        named: "UberButtonBackground",
        in: .resource(for: UberButton.self),
        compatibleWith: nil
    ) ?? UIColor.darkText
    
    static let uberButtonHighlightedDarkBackground: UIColor = UIColor(
        named: "UberButtonHighlightedDarkBackground",
        in: .module,
        compatibleWith: nil
    ) ?? UIColor.darkText
    
    static let uberButtonHighlightedLightBackground: UIColor = UIColor(
        named: "UberButtonHighlightedLightBackground",
        in: .module,
        compatibleWith: nil
    ) ?? UIColor.darkText
    
    static let uberButtonForeground: UIColor = UIColor(
        named: "UberButtonForeground",
        in: .resource(for: UberButton.self),
        compatibleWith: nil
    ) ?? UIColor.lightText
}
