// ActionButton.swift
//
// The MIT License (MIT)
//
// Copyright (c) 2015 ActionButton
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit

public typealias ActionButtonAction = (ActionButton) -> Void

public class ActionButton: NSObject {
    
    /// The action the button should perform when tapped
    public var action: ActionButtonAction?

    /// The button's background color : set default color and selected color
    public var backgroundColor: UIColor = UIColor(red: 238.0/255.0, green: 130.0/255.0, blue: 34.0/255.0, alpha:1.0) {
        willSet {
            floatButton.backgroundColor = newValue
            backgroundColorSelected = newValue
        }
    }
    
    /// The button's background color : set default color
    public var backgroundColorSelected: UIColor = UIColor(red: 238.0/255.0, green: 130.0/255.0, blue: 34.0/255.0, alpha:1.0)
    
    /// Indicates if the buttons is active (showing its items)
    private(set) public var active: Bool = false
    
    /// An array of items that the button will present
    internal var items: [ActionButtonItem]? {
        willSet {
            for abi in self.items! {
                abi.view.removeFromSuperview()
            }
        }
        didSet {
            placeButtonItems()
            showActive(true)
        }
    }
    
    /// The button that will be presented to the user
    private var floatButton: UIButton!
    
    
    /// View that will hold the placement of the button's actions
    private var contentView: UIView!
    
    /// View where the *floatButton* will be displayed
    private var parentView: UIView!
    
    /// Blur effect that will be presented when the button is active
    private var blurVisualEffect: UIVisualEffectView!
    
    // Distance between each item action
    private let itemOffset = -55
    
    /// the float button's radius
    private let floatButtonRadius = 50
    
    public init(attachedToView view: UIView, items: [ActionButtonItem]?) {
        super.init()
        
        self.parentView = view
        self.items = items
        let bounds = self.parentView.bounds
        
        self.floatButton = UIButton(type: .Custom)
        self.floatButton.layer.cornerRadius = CGFloat(floatButtonRadius / 2)
        self.floatButton.layer.shadowOpacity = 1
        self.floatButton.layer.shadowRadius = 2
        self.floatButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.floatButton.layer.shadowColor = UIColor.grayColor().CGColor
        self.floatButton.setTitle("+", forState: .Normal)
        self.floatButton.setImage(nil, forState: .Normal)
        self.floatButton.backgroundColor = self.backgroundColor
        self.floatButton.titleLabel!.font = UIFont(name: "HelveticaNeue-Light", size: 35)
        self.floatButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 0)
        self.floatButton.userInteractionEnabled = true
        self.floatButton.translatesAutoresizingMaskIntoConstraints = false
        
        self.floatButton.addTarget(self, action: #selector(ActionButton.buttonTapped(_:)), forControlEvents: .TouchUpInside)
        self.floatButton.addTarget(self, action: #selector(ActionButton.buttonTouchDown(_:)), forControlEvents: .TouchDown)
        self.parentView.addSubview(self.floatButton)

        self.contentView = UIView(frame: bounds)
        self.blurVisualEffect = UIVisualEffectView(effect: UIBlurEffect(style: .ExtraLight))
        self.blurVisualEffect.frame = self.contentView.frame
        self.contentView.addSubview(self.blurVisualEffect)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(ActionButton.backgroundTapped(_:)))
        self.contentView.addGestureRecognizer(tap)
        
        self.installConstraints()
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Set Methods
    public func setTitle(title: String?, forState state: UIControlState) {
        floatButton.setImage(nil, forState: state)
        floatButton.setTitle(title, forState: state)
        floatButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 0)
    }
    
    public func setImage(image: UIImage?, forState state: UIControlState) {
        setTitle(nil, forState: state)
        floatButton.setImage(image, forState: state)
        floatButton.adjustsImageWhenHighlighted = false
        floatButton.contentEdgeInsets = UIEdgeInsetsZero
    }
    
    //MARK: - Auto Layout Methods
    /**
        Install all the necessary constraints for the button. By the default the button will be placed at 15pts from the bottom and the 15pts from the right of its *parentView*
    */
    private func installConstraints() {
        let views = ["floatButton":self.floatButton, "parentView":self.parentView]
        let width = NSLayoutConstraint.constraintsWithVisualFormat("H:[floatButton(\(floatButtonRadius))]", options: NSLayoutFormatOptions.AlignAllCenterX, metrics: nil, views: views)
        let height = NSLayoutConstraint.constraintsWithVisualFormat("V:[floatButton(\(floatButtonRadius))]", options: NSLayoutFormatOptions.AlignAllCenterX, metrics: nil, views: views)
        self.floatButton.addConstraints(width)
        self.floatButton.addConstraints(height)
        
        let trailingSpacing = NSLayoutConstraint.constraintsWithVisualFormat("V:[floatButton]-15-|", options: NSLayoutFormatOptions.AlignAllCenterX, metrics: nil, views: views)
        let bottomSpacing = NSLayoutConstraint.constraintsWithVisualFormat("H:[floatButton]-15-|", options: NSLayoutFormatOptions.AlignAllCenterX, metrics: nil, views: views)
        self.parentView.addConstraints(trailingSpacing)
        self.parentView.addConstraints(bottomSpacing)
    }
    
    //MARK: - Button Actions Methods
    func buttonTapped(sender: UIControl) {
        animatePressingWithScale(1.0)
        
        if let unwrappedAction = self.action {
            unwrappedAction(self)
        }
    }
    
    func buttonTouchDown(sender: UIButton) {
        animatePressingWithScale(0.9)
    }
    
    //MARK: - Gesture Recognizer Methods
    func backgroundTapped(gesture: UIGestureRecognizer) {
        if self.active {
            self.toggle()
        }
    }
    
    //MARK: - Custom Methods
    /**
        Presents or hides all the ActionButton's actions
    */
    public func toggleMenu() {
        self.placeButtonItems()
        self.toggle()
    }
    
    //MARK: - Action Button Items Placement
    /**
        Defines the position of all the ActionButton's actions
    */
    private func placeButtonItems() {
        if let optionalItems = self.items {
            for item in optionalItems {
                item.view.center = CGPoint(x: self.floatButton.center.x - 83, y: self.floatButton.center.y)
                item.view.removeFromSuperview()
                
                self.contentView.addSubview(item.view)
            }
        }
    }
    
    //MARK - Float Menu Methods
    /**
        Presents or hides all the ActionButton's actions and changes the *active* state
    */
    private func toggle() {
        self.animateMenu()
        self.showBlur()
        
        self.active = !self.active
        self.floatButton.backgroundColor = self.active ? backgroundColorSelected : backgroundColor
        self.floatButton.selected = self.active
    }
    
    private func animateMenu() {
        let rotation = self.active ? 0 : CGFloat(M_PI_4)
        
        UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.1, options: UIViewAnimationOptions.AllowAnimatedContent, animations: {
            
            if self.floatButton.imageView?.image == nil {
                self.floatButton.transform = CGAffineTransformMakeRotation(rotation)
            }
    
            self.showActive(false)
        }, completion: {completed in
            if self.active == false {
                self.hideBlur()
            }
        })
    }
    
    private func showActive(active: Bool) {
        if self.active == active {
            self.contentView.alpha = 0.75
            
            if let optionalItems = self.items {
                for (index, item) in optionalItems.enumerate() {
                    let offset = index + 1
                    let translation = self.itemOffset * offset
                    item.view.transform = CGAffineTransformMakeTranslation(0, CGFloat(translation))
                    item.view.alpha = 1
                }
            }
        } else {
            self.contentView.alpha = 0.0
            
            if let optionalItems = self.items {
                for item in optionalItems {
                    item.view.transform = CGAffineTransformMakeTranslation(0, 0)
                    item.view.alpha = 0
                }
            }
        }
    }
    
    private func showBlur() {
        self.parentView.insertSubview(self.contentView, belowSubview: self.floatButton)
    }
    
    private func hideBlur() {
        self.contentView.removeFromSuperview()
    }
    
    /**
        Animates the button pressing, by the default this method just scales the button down when it's pressed and returns to its normal size when the button is no longer pressed
    
        - parameter scale: how much the button should be scaled
    */
    private func animatePressingWithScale(scale: CGFloat) {
        UIView.animateWithDuration(0.2, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.1, options: UIViewAnimationOptions.AllowAnimatedContent, animations: {
            self.floatButton.transform = CGAffineTransformMakeScale(scale, scale)
        }, completion: nil)
    }
}




