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
    let cornerRadius: CGFloat = 8
    let horizontalEdgePadding: CGFloat = 16
    let imageLabelPadding: CGFloat = 8
    let verticalPadding: CGFloat = 10
    
    let uberImageView: UIImageView = UIImageView()
    let uberTitleLabel: UILabel = UILabel()
    
    public var colorStyle: RequestButtonColorStyle = .Black {
        didSet {
            colorStyleDidUpdate(colorStyle)
        }
    }
    
    override public var highlighted: Bool {
        didSet {
            updateColors(highlighted)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        colorStyleDidUpdate(.Black)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
        colorStyleDidUpdate(.Black)
    }
    
    /**
     Function responsible for the initial setup of the button. 
     Calls addSubviews(), setContent(), and setConstraints()
     */
    public func setup() {
        addSubviews()
        setContent()
        setConstraints()
    }
    
    /**
     Function responsible for adding all the subviews to the button. Subclasses
     should override this method and add any necessary subviews.
     */
    public func addSubviews() {
        addSubview(uberImageView)
        addSubview(uberTitleLabel)
    }
    
    /**
     Function responsible for updating content on the button. Subclasses should
     override and do any necessary view setup
     */
    public func setContent() {
        clipsToBounds = true
        layer.cornerRadius = cornerRadius
    }
    
    /**
     Function responsible for adding autolayout constriants on the button. Subclasses
     should override and add any additional autolayout constraints
     */
    public func setConstraints() {
        
        uberTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        uberImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let views = ["imageView": uberImageView, "titleLabel": uberTitleLabel]
        let metrics = ["edgePadding": horizontalEdgePadding, "verticalPadding": verticalPadding, "imageLabelPadding": imageLabelPadding]
        
        let horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-edgePadding-[imageView]-imageLabelPadding-[titleLabel]-(edgePadding)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: views)
        let verticalContraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-verticalPadding-[imageView]-verticalPadding-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: views)
        
        addConstraints(horizontalConstraints)
        addConstraints(verticalContraints)
    }
    
    override public func sizeThatFits(size: CGSize) -> CGSize {
        let logoSize = uberImageView.image?.size ?? CGSizeZero
        let titleSize = uberTitleLabel.intrinsicContentSize()
        
        let width: CGFloat = 4*horizontalEdgePadding + imageLabelPadding + logoSize.width + titleSize.width
        let height: CGFloat = 2*verticalPadding + max(logoSize.height, titleSize.height)
        
        return CGSizeMake(width, height)
    }
    
    // Mark: Internal Interface

    func colorStyleDidUpdate(style: RequestButtonColorStyle) {
        switch colorStyle {
        case .Black:
            backgroundColor = ColorUtil.colorForUberButtonColor(.UberBlack)
            uberTitleLabel.textColor = ColorUtil.colorForUberButtonColor(.UberWhite)
            uberImageView.tintColor = ColorUtil.colorForUberButtonColor(.UberWhite)
        case .White :
            backgroundColor = ColorUtil.colorForUberButtonColor(.UberWhite)
            uberTitleLabel.textColor = ColorUtil.colorForUberButtonColor(.UberBlack)
            uberImageView.tintColor = ColorUtil.colorForUberButtonColor(.UberBlack)
        }
    }
    
    // Mark: Private Interface
    
    private func updateColors(highlighted : Bool) {
        var color: UberButtonColor
        switch colorStyle {
        case .Black:
            color = highlighted ? .BlackHighlighted : .UberBlack
        case .White:
            color = highlighted ? .WhiteHighlighted : .UberWhite
        }
        backgroundColor = ColorUtil.colorForUberButtonColor(color)
    }
}
