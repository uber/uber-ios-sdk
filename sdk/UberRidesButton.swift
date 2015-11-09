//
//  UberRidesButton.swift
//  sdk
//
//  Copyright © 2015 Uber Technologies, Inc. All rights reserved.
//

import UIKit


// UberRidesButton implements a button on the touch screen.
public class UberRidesButton: UIButton {
    var deeplink: UberRidesDeeplink?
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setUp(.black)
    }
    
    public init(colorStyle: UberButtonColorStyle = .black) {
        super.init(frame: CGRectZero)
        self.setUp(colorStyle)
    }
    
    public init(colorStyle: UberButtonColorStyle = .black, position: CGPoint) {
        super.init(frame: CGRectMake(position.x, position.y, 0, 0))
        self.setUp(colorStyle)
    }
    
    private func setUp(colorStyle: UberButtonColorStyle) {
        do {
            try setDeeplink()
            self.addTarget(self, action: "uberButtonTapped:", forControlEvents: .TouchUpInside)
        } catch UberButtonError.NullClientID {
            print("No Client ID attached to the deeplink.")
        } catch {
            print("Unknown Error")
        }
        setContent()
        setColorStyle(colorStyle)
    }
    
    // build and attach a deeplink to the button
    private func setDeeplink() throws {
        guard UberRidesClient.sharedInstance.hasClientID() else {
            throw UberButtonError.NullClientID
        }
        
        let clientID = UberRidesClient.sharedInstance.clientID
        deeplink = UberRidesDeeplink(clientID: clientID)
        deeplink!.build()
    }
    
    // add title, image, and sizing configuration
    private func setContent() {
        // add title label and an image
        self.setTitle("Ride there with Uber", forState: .Normal)
        self.titleLabel!.font = UIFont.systemFontOfSize(16)
        let badge = self.getImage("Badge")
        self.setImage(badge, forState: .Normal)
        
        // set button frame size
        let padding = CGFloat(7)
        let labelSize = self.titleLabel!.size()
        let contentWidth = labelSize.width + badge.size.width + (3 * padding)
        let contentHeight = max(labelSize.height, badge.size.height) + (2 * padding)
        self.titleEdgeInsets = UIEdgeInsetsMake(0, padding, 0, 0)
        self.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, padding)
        self.frame = CGRect(x: 0, y: 0, width: contentWidth, height: contentHeight)
        
        // rounded corners
        self.clipsToBounds = true
        self.layer.cornerRadius = 5
        
        // allow frame-based layout if Auto Layout is enabled
        self.translatesAutoresizingMaskIntoConstraints = true
    }
    
    // get image from media directory
    private func getImage(name: String) -> UIImage {
        let bundle = NSBundle(forClass: UberRidesButton.self)
        let image = UIImage(named: name, inBundle: bundle, compatibleWithTraitCollection: nil)
        return image!
    }
    
    // set color scheme, default is black background with white font
    private func setColorStyle(style: UberButtonColorStyle) {
        switch style {
        case .black:
            self.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            self.setTitleColor(UIColor.grayColor(), forState: .Highlighted)
            self.backgroundColor = UIColor.blackColor()
        case .white :
            self.setTitleColor(UIColor.blackColor(), forState: .Normal)
            self.setTitleColor(UIColor.grayColor(), forState: .Highlighted)
            self.backgroundColor = UIColor.whiteColor()
        }
    }
    
    public func uberButtonTapped(sender: UIButton) {
        if UberRidesClient.sharedInstance.hasClientID() {
            deeplink!.execute()
        }
    }
}

public enum UberButtonColorStyle {
    case black
    case white
}

// use the size() extension to get height and width of a UI label
private extension UILabel {
    func size() -> (width: CGFloat, height: CGFloat) {
        let label = UILabel(frame: CGRectMake(0, 0, self.frame.width, CGFloat.max))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.ByWordWrapping
        label.font = self.font
        label.text = self.text
        label.sizeToFit()
        return (label.frame.width, label.frame.height)
    }
}

public enum UberButtonError: ErrorType {
    case NullClientID
}
