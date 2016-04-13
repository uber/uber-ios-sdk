//
//  UberButton.swift
//  UberRides
//
//  Copyright © 2016 Uber Technologies, Inc. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import UIKit

/// Base class for Uber buttons that sets up colors and some constraints.
@objc(UBSDKUberButton) public class UberButton: UIButton {
    let horizontalImagePadding: CGFloat = 12
    let horizontalLabelPadding: CGFloat = 19
    let imageLabelPadding: CGFloat = 9
    let verticalPadding: CGFloat = 10
    
    let uberImageView: UIImageView! = UIImageView()
    let uberTitleLabel: UILabel! = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setColorStyle(.Black)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setColorStyle(.Black)
    }
    
    override public var highlighted: Bool {
        // Change colors when button is highlighted
        didSet {
            var color: UberButtonColor
            switch colorStyle {
            case .Black:
                color = highlighted ? .BlackHighlighted : .UberBlack
            case .White:
                color = highlighted ? .WhiteHighlighted : .UberWhite
            }
            backgroundColor = ColorUtil.uberUIColor(color)
        }
    }
    
    /// Set color scheme, default is black background with white font.
    public var colorStyle: RequestButtonColorStyle = .Black {
        didSet {
            setColorStyle(colorStyle)
        }
    }
    
    private func setColorStyle(style: RequestButtonColorStyle) {
        switch colorStyle {
        case .Black:
            backgroundColor = ColorUtil.uberUIColor(.UberBlack)
            uberTitleLabel.textColor = ColorUtil.uberUIColor(.UberWhite)
        case .White :
            backgroundColor = ColorUtil.uberUIColor(.UberWhite)
            uberTitleLabel.textColor = ColorUtil.uberUIColor(.UberBlack)
        }
    }
    
    public func setImage(image: UIImage) {
        uberImageView.image = image
    }
    
    public func setText(text: String, font: UIFont?) {
        uberTitleLabel.text = text
        uberTitleLabel.font = font
    }
    
    func setContent() {
        self.dynamicType.loadFonts()
        clipsToBounds = true
        layer.cornerRadius = 5
    }
    
    private static func loadFonts() {
        struct DispatchOnce { static var token: dispatch_once_t = 0}
        dispatch_once(&DispatchOnce.token, {
            FontUtil.loadFontWithName("ClanPro-Book", familyName: "Clan Pro")
            FontUtil.loadFontWithName("ClanPro-Medium", familyName: "Clan Pro")
        })
    }
    
    func setConstraints() {
        let views = ["imageView": uberImageView, "titleView": uberTitleLabel]
        let metrics = ["horizontalImagePadding": horizontalImagePadding, "horizontalLabelPadding": horizontalLabelPadding, "verticalPadding": verticalPadding]
        
        let horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-horizontalImagePadding-[imageView]-imageLabelPadding-[titleLabel]-horizontalLabelPadding-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: views)
        let verticalContraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-verticalPadding-[imageView]-verticalPadding-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: views)
        
        addConstraints(horizontalConstraints)
        addConstraints(verticalContraints)
    }
}
