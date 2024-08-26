//
//  UberButton.swift
//  UberCore
//
//  Copyright © 2024 Uber Technologies, Inc. All rights reserved.
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

import Foundation
import UIKit

open class UberButton: UIButton {
    
    // MARK: Public Properties
    
    open var title: NSAttributedString? { nil }
    
    open var subtitle: NSAttributedString? { nil }
    
    open var image: UIImage? { nil }
    
    open var horizontalAlignment: UIControl.ContentHorizontalAlignment { .fill }
    
    open var imagePlacement: NSDirectionalRectEdge { .leading }
    
    // MARK: Initializers
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
        update()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
        update()
    }
    
    // MARK: UIButton
        
    open override var isHighlighted: Bool {
        didSet { update() }
    }
    
    // MARK: Private
    
    lazy var secondaryLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .uberButtonForeground
        label.numberOfLines = 0
        label.textAlignment = .right
        return label
    }()
    
    private func configure() {
        addSubview(secondaryLabel)
        
        NSLayoutConstraint.activate([
            secondaryLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            secondaryLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -12),
            secondaryLabel.topAnchor.constraint(equalTo: topAnchor)
        ])
        
        if let titleLabel {
            secondaryLabel.leftAnchor.constraint(equalTo: titleLabel.rightAnchor, constant: 24).isActive = true
        }
    }
    
    public func update() {
        if #available(iOS 15, *) {
            secondaryLabel.attributedText = subtitle
            
            contentHorizontalAlignment = horizontalAlignment
            configuration = .uber(
                title: AttributedString(title ?? .init(string: "")),
                image: image,
                isHighlighted: isHighlighted,
                imagePlacement: imagePlacement
            )
            
            updateConfiguration()
        }
        else {
            clipsToBounds = true
            layer.cornerRadius = Constants.cornerRadius

            setImage(
                image?.withRenderingMode(.alwaysTemplate),
                for: .normal
            )
            imageView?.tintColor = .uberButtonForeground
            imageView?.contentMode = .left
            
            setTitle(title?.string, for: .normal)
            titleLabel?.textAlignment = .right
            
            setTitleColor(.uberButtonForeground, for: .normal)
            backgroundColor = ColorStyle.light.backgroundColor(isHighlighted: isHighlighted)
            
            contentEdgeInsets = Constants.contentInsets
        }
    }
    
    private enum Constants {
        static let cornerRadius: CGFloat = 8
        static let horizontalPadding: CGFloat = 16
        static let verticalPadding: CGFloat = 10
        static let contentInsets: UIEdgeInsets = .init(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    // MARK: ColorStyle
    
    public enum ColorStyle {
        case light
        case dark
        
        var foregroundColor: UIColor {
            switch self {
            case .light: return .uberButtonBackground
            case .dark: return .uberButtonForeground
            }
        }
        
        func backgroundColor(isHighlighted: Bool) -> UIColor {
            switch self {
            case .light: return isHighlighted ? .uberButtonHighlightedLightBackground : .uberButtonForeground
            case .dark: return isHighlighted ? .uberButtonHighlightedDarkBackground : .uberButtonBackground
            }
        }
    }
}


@available(iOS 15, *)
extension UIButton.Configuration {
    
    static func uber(colorStyle: UberButton.ColorStyle = .dark,
                     title: AttributedString? = nil,
                     image: UIImage? = nil,
                     isHighlighted: Bool = false,
                     imagePlacement: NSDirectionalRectEdge = .leading) -> UIButton.Configuration {
        
        var style: UIButton.Configuration = .plain()
        
        // Background Color
        var background = style.background
        background.backgroundColor = colorStyle.backgroundColor(isHighlighted: isHighlighted)
        style.background = background
        
        // Image
        style.image = image
        style.imagePadding = 12.0
        style.imagePlacement = imagePlacement
        
        // Title
        style.attributedTitle = title
        style.baseForegroundColor = colorStyle.foregroundColor
        
        return style
    }
}
