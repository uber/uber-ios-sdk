//
//  ModalViewController.swift
//  UberRides
//
//  Copyright © 2015 Uber Technologies, Inc. All rights reserved.
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

/**
Possible Styles for the ModalViewController

- Empty:       Presents the view modally without any BarButtonItems
- DoneButton:  Presents the view mdoally with a Done BarButtonItem in the top right corner
*/
@objc public enum ModalViewControllerButtonStyle : Int {
    case Empty
    case DoneButton
    case BackButton
}

/**
 Possible color style for the ModalViewController
 
 - Default: Default dark style, dark navigation bar with light text
 - Light:   Light color style, light navigation bar with dark text
 */
@objc public enum ModalViewControllerColorStyle : Int {
    case Default
    case Light
}

/**
 *  The ModalViewControllerDelegate protocol
 */
@objc(UBSDKModalViewControllerDelegate) public protocol ModalViewControllerDelegate {
    /**
     Called before the ModalViewController dismisses the modal.
     
     - parameter modalViewController: The ModalViewController that will be dismissed
     */
    @objc func modalViewControllerWillDismiss(modalViewController: ModalViewController)
    
    /**
     Called after the ModalViewController is dismissed.
     
     - parameter modalViewController: The ModalViewController that was dismissed
     */
    @objc func modalViewControllerDidDismiss(modalViewController: ModalViewController)
}

/// Convenience to wrap a ViewController in a UINavigationController and add the appropriate buttons. Allows you to modally present a view controller w/ Uber branding.
@objc(UBSDKModalViewController) public class ModalViewController : UIViewController {
    /// The ModalViewControllerDelegate
    public var delegate: ModalViewControllerDelegate?
    
    public var colorStyle: ModalViewControllerColorStyle = .Default {
        didSet {
            setupStyle()
        }
    }
    
    var buttonStyle: ModalViewControllerButtonStyle
    var wrappedViewController: UIViewController
    var wrappedNavigationController: UINavigationController
    
    //MARK: Initializers
    
    /**
    Initializes a ModalViewController for the given childViewController and style inside a UINavigationController
    with the appropriate buttons.
    
    - parameter childViewController: The child UIViewController to wrap
    - parameter buttonStyle:         The ModalViewControllerButtonStyle to use
    
    - returns: An initialized ModalViewController
    */
    @objc public init(childViewController: UIViewController, buttonStyle: ModalViewControllerButtonStyle) {
        wrappedViewController = childViewController
        wrappedNavigationController = UINavigationController(rootViewController: childViewController)
        self.buttonStyle = buttonStyle
        super.init(nibName: nil, bundle: nil)
        setupStyle()
    }
    
    /**
     Initializes a ModalViewController for the given childViewController and style inside a UINavigationController
     with the appropriate buttons. 
     
     Defaults to the .DoneButton ModalViewControllerButtonStyle style
     
     - parameter childViewController: The child UIViewController to wrap
     
     - returns: An initialized ModalViewController
     */
    @objc public convenience init(childViewController: UIViewController) {
        self.init(childViewController: childViewController, buttonStyle: .DoneButton)
    }

    /**
     Unavailable. ModalViewController doesn't support being initialized via
     init(coder:)
     
     - throws: Fatal Error
     */
    @objc required public init?(coder aDecoder: NSCoder) {
        fatalError("ModalViewController doesn't support init(coder:)")
    }
    
    //MARK: View Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addChildViewController(wrappedNavigationController)
        self.view.addSubview(self.wrappedNavigationController.view)
        
        self.wrappedNavigationController.didMoveToParentViewController(self)
    }
    
    public override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.delegate?.modalViewControllerDidDismiss(self)
    }
    
    //MARK: Public
    
    /**
     Function to dimiss the modalViewController.
    */
    public func dismiss() {
        self.delegate?.modalViewControllerWillDismiss(self)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    public override func preferredStatusBarStyle() -> UIStatusBarStyle {
        switch colorStyle {
        case .Light:
            return UIStatusBarStyle.Default
        case .Default:
            return UIStatusBarStyle.LightContent
        }
        
    }
    
    //MARK: Button Actions
    
    func doneButtonPressed(button: UIButton) {
        dismiss()
    }
    
    func backButtonPressed(button: UIButton) {
        dismiss()
    }
    
    //MARK: Private Helpers
    
    private func setupStyle() {
        let bundle = NSBundle(forClass: RideRequestButton.self)
        self.wrappedViewController.navigationItem.leftBarButtonItem = nil
        self.wrappedViewController.navigationItem.rightBarButtonItem = nil
        var iconTintColor = UIColor.whiteColor()
        switch colorStyle {
        case .Light:
            iconTintColor = UIColor.blackColor()
            wrappedViewController.navigationController?.navigationBar.barStyle = .Default
        case .Default:
            wrappedViewController.navigationController?.navigationBar.barStyle = .Black
            break
        }
        
        switch buttonStyle {
        case .Empty:
            break
        case .DoneButton:
            let doneButton = UIBarButtonItem(barButtonSystemItem: .Done , target: self, action: #selector(doneButtonPressed(_:)))
            doneButton.tintColor = iconTintColor
            self.wrappedViewController.navigationItem.rightBarButtonItem = doneButton
        case .BackButton:
            let backImage =  UIImage(named: "ic_back_arrow_white", inBundle: bundle, compatibleWithTraitCollection: nil)
            let backButton = UIBarButtonItem(image: backImage, style: .Plain, target: self, action: #selector(backButtonPressed(_:)))
            backButton.tintColor = iconTintColor
            self.wrappedViewController.navigationItem.leftBarButtonItem = backButton
        }
        
        let logoImage = UIImage(named: "ic_logo_white", inBundle: bundle, compatibleWithTraitCollection: nil)?.imageWithRenderingMode(.AlwaysTemplate)
        let logoImageView = UIImageView(image: logoImage)
        logoImageView.tintColor = iconTintColor
        
        wrappedViewController.navigationItem.titleView = logoImageView
    }
}
