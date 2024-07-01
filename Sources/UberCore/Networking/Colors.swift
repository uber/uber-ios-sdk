//
//  Copyright © Uber Technologies, Inc. All rights reserved.
//


import UIKit

extension UIColor {
    
    static let uberButtonBackground: UIColor = UIColor(
        named: "UberButtonBackground",
        in: .resource(for: UberButton.self),
        compatibleWith: nil
    ) ?? UIColor.darkText
    
    static let uberButtonHighlightedBackground: UIColor = UIColor(
        named: "UberButtonHighlightedBackground",
        in: .resource(for: UberButton.self),
        compatibleWith: nil
    ) ?? UIColor.darkText
    
    static let uberButtonForeground: UIColor = UIColor(
        named: "UberButtonForeground",
        in: .resource(for: UberButton.self),
        compatibleWith: nil
    ) ?? UIColor.lightText
}
