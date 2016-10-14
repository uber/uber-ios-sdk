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
    case empty
    case doneButton
    case backButton
}

/**
 Possible color style for the ModalViewController
 
 - Default: Default dark style, dark navigation bar with light text
 - Light:   Light color style, light navigation bar with dark text
 */
@objc public enum ModalViewControllerColorStyle : Int {
    case `default`
    case light
}

/**
 *  The ModalViewControllerDelegate protocol
 */
@objc(UBSDKModalViewControllerDelegate) public protocol ModalViewControllerDelegate {
    /**
     Called before the ModalViewController dismisses the modal.
     
     - parameter modalViewController: The ModalViewController that will be dismissed
     */
    @objc func modalViewControllerWillDismiss(_ modalViewController: ModalViewController)
    
    /**
     Called after the ModalViewController is dismissed.
     
     - parameter modalViewController: The ModalViewController that was dismissed
     */
    @objc func modalViewControllerDidDismiss(_ modalViewController: ModalViewController)
}

/// Convenience to wrap a ViewController in a UINavigationController and add the appropriate buttons. Allows you to modally present a view controller w/ Uber branding.
@objc(UBSDKModalViewController) open class ModalViewController : UIViewController {
    /// The ModalViewControllerDelegate
    open var delegate: ModalViewControllerDelegate?
    
    open var colorStyle: ModalViewControllerColorStyle = .default {
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
        self.init(childViewController: childViewController, buttonStyle: .doneButton)
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
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addChildViewController(wrappedNavigationController)
        self.view.addSubview(self.wrappedNavigationController.view)
        
        self.wrappedNavigationController.didMove(toParentViewController: self)
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.delegate?.modalViewControllerDidDismiss(self)
    }
    
    //MARK: Public
    
    /**
     Function to dimiss the modalViewController.
    */
    open func dismiss() {
        self.delegate?.modalViewControllerWillDismiss(self)
        self.dismiss(animated: true, completion: nil)
    }
    
    open override var preferredStatusBarStyle : UIStatusBarStyle {
        switch colorStyle {
        case .light:
            return UIStatusBarStyle.default
        case .default:
            return UIStatusBarStyle.lightContent
        }
        
    }
    
    //MARK: Button Actions
    
    func doneButtonPressed(_ button: UIButton) {
        dismiss()
    }
    
    func backButtonPressed(_ button: UIButton) {
        dismiss()
    }
    
    //MARK: Private Helpers
    
    fileprivate func setupStyle() {
        let bundle = Bundle(for: RideRequestButton.self)
        self.wrappedViewController.navigationItem.leftBarButtonItem = nil
        self.wrappedViewController.navigationItem.rightBarButtonItem = nil
        var iconTintColor = UIColor.white
        switch colorStyle {
        case .light:
            iconTintColor = UIColor.black
            wrappedViewController.navigationController?.navigationBar.barStyle = .default
        case .default:
            wrappedViewController.navigationController?.navigationBar.barStyle = .black
            break
        }
        
        switch buttonStyle {
        case .empty:
            break
        case .doneButton:
            let doneButton = UIBarButtonItem(barButtonSystemItem: .done , target: self, action: #selector(doneButtonPressed(_:)))
            doneButton.tintColor = iconTintColor
            self.wrappedViewController.navigationItem.rightBarButtonItem = doneButton
        case .backButton:
            let backImage =  UIImage(named: "ic_back_arrow_white", in: bundle, compatibleWith: nil)
            let backButton = UIBarButtonItem(image: backImage, style: .plain, target: self, action: #selector(backButtonPressed(_:)))
            backButton.tintColor = iconTintColor
            self.wrappedViewController.navigationItem.leftBarButtonItem = backButton
        }
        
        let logoImage = UIImage(named: "ic_logo_white", in: bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        let logoImageView = UIImageView(image: logoImage)
        logoImageView.tintColor = iconTintColor
        
        wrappedViewController.navigationItem.titleView = logoImageView
    }
}
