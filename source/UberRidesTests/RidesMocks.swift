//
//  RidesMocks.swift
//  UberRides
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

import WebKit
@testable import UberRides

class RideRequestViewMock : RideRequestView {
    var testClosure: (() -> ())?
    init(rideRequestView: RideRequestView, testClosure: (() -> ())?) {
        self.testClosure = testClosure
        super.init(rideParameters: rideRequestView.rideParameters, accessToken: rideRequestView.accessToken, frame: rideRequestView.frame)
    }
    
    required init(rideParameters: RideParameters?, accessToken: AccessToken?, frame: CGRect) {
        fatalError("init(rideParameters:accessToken:frame:) has not been implemented")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func load() {
        self.testClosure?()
    }
    
    override func cancelLoad() {
        self.testClosure?()
    }
}

class RideRequestViewControllerMock : RideRequestViewController {
    var loadClosure: (() -> ())?
    var networkClosure: (() -> ())?
    var notSupportedClosure: (() -> ())?
    var presentViewControllerClosure: ((UIViewController, Bool, (() -> Void)?) -> ())?
    var executeNativeClosure: (() -> ())?
    
    init(rideParameters: RideParameters, loginManager: LoginManager, loadClosure: (() -> ())? = nil, networkClosure: (() -> ())? = nil, presentViewControllerClosure: ((UIViewController, Bool, (() -> Void)?) -> ())? = nil, notSupportedClosure: (() -> ())? = nil) {
        self.loadClosure = loadClosure
        self.networkClosure = networkClosure
        self.notSupportedClosure = notSupportedClosure
        self.presentViewControllerClosure = presentViewControllerClosure
        super.init(rideParameters: rideParameters, loginManager: loginManager)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func load() {
        if let loadClosure = loadClosure {
            loadClosure()
        } else {
            super.load()
        }
    }
    
    override func displayNetworkErrorAlert() {
        if let networkClosure = networkClosure {
            networkClosure()
        } else {
            super.displayNetworkErrorAlert()
        }
    }
    
    override func displayNotSupportedErrorAlert() {
        if let notSupportedClosure = notSupportedClosure {
            notSupportedClosure()
        } else {
            super.displayNotSupportedErrorAlert()
        }
    }
    
    override func presentViewController(viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
        if let presentViewControllerClosure = presentViewControllerClosure {
            presentViewControllerClosure(viewControllerToPresent, flag, completion)
        } else {
            super.presentViewController(viewControllerToPresent, animated: flag, completion: completion)
        }
    }
    
    override func executeNativeLogin() {
        if let closure = executeNativeClosure {
            closure()
        } else {
            super.executeNativeLogin()
        }
    }

}

class LoginViewMock : LoginView {
    var testClosure: (() -> ())?
    init(loginBehavior: LoginViewAuthenticator, testClosure: (() -> ())?) {
        self.testClosure = testClosure
        super.init(loginAuthenticator: loginBehavior, frame: CGRectZero)
    }
    
    required override init(loginAuthenticator: LoginViewAuthenticator, frame: CGRect) {
        fatalError("init(scopes:frame:) has not been implemented")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func load() {
        self.testClosure?()
    }
    
    override func cancelLoad() {
        self.testClosure?()
    }
}

class OAuthViewControllerMock : OAuthViewController {
    var presentViewControllerClosure: ((UIViewController, Bool, (() -> Void)?) -> ())?
    
    init(loginView: LoginView, presentViewControllerClosure: ((UIViewController, Bool, (() -> Void)?) -> ())?) {
        self.presentViewControllerClosure = presentViewControllerClosure
        super.init(loginAuthenticator: loginView.loginAuthenticator)
        self.loginView = loginView
    }

    @objc required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func presentViewController(viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
        if let presentViewControllerClosure = presentViewControllerClosure {
            presentViewControllerClosure(viewControllerToPresent, flag, completion)
        } else {
            super.presentViewController(viewControllerToPresent, animated: flag, completion: completion)
        }
    }
}

class WebViewMock : WKWebView {
    var testClosure: ((NSURLRequest) -> ())?
    init(frame: CGRect, configuration: WKWebViewConfiguration, testClosure: ((NSURLRequest) -> ())?) {
        self.testClosure = testClosure
        super.init(frame: frame, configuration: configuration)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadRequest(request: NSURLRequest) -> WKNavigation? {
        testClosure?(request)
        return nil
    }
}

class RequestDeeplinkMock : RequestDeeplink {
    var testClosure: ((NSURL?) -> (Bool))?
    init(rideParameters: RideParameters, testClosure: ((NSURL?) -> (Bool))?) {
        self.testClosure = testClosure
        super.init(rideParameters: rideParameters)
    }
    
    override func execute(completion: ((NSError?) -> ())? = nil) {
        guard let testClosure = testClosure else {
            completion?(nil)
            return
        }
        testClosure(deeplinkURL)
    }
}

class DeeplinkRequestingBehaviorMock : DeeplinkRequestingBehavior {
    var testClosure: ((NSURL?) -> (Bool))?
    init(testClosure: ((NSURL?) -> (Bool))?) {
        self.testClosure = testClosure
        super.init()
    }
    
    override func createDeeplink(rideParameters: RideParameters) -> RequestDeeplink {
        return RequestDeeplinkMock(rideParameters: rideParameters, testClosure: testClosure)
    }
}

@objc class RideRequestViewControllerDelegateMock : NSObject, RideRequestViewControllerDelegate {
    let testClosure: (RideRequestViewController, NSError) -> ()
    init(testClosure: (RideRequestViewController, NSError) -> ()) {
        self.testClosure = testClosure
    }
    @objc func rideRequestViewController(rideRequestViewController: RideRequestViewController, didReceiveError error: NSError) {
        self.testClosure(rideRequestViewController, error)
    }
}

@objc class DeeplinkingProtocolMock : NSObject, Deeplinking {
    
    let deeplinkingObject: Deeplinking
    
    var executeClosure: (((NSError?) -> ())? -> ())?
    var backingScheme: String?
    var backingDomain: String?
    var backingPath: String?
    var backingQueryItems: [NSURLQueryItem]?
    var backingDeeplinkURL: NSURL?
    
    var overrideExecute: Bool = false
    var overrideExecuteValue: NSError? = nil

    var scheme: String {
        get {
            return backingScheme ?? deeplinkingObject.scheme
        }
        set(newScheme) {
            backingScheme = newScheme
        }
    }
    
    var domain: String {
        get {
            return backingDomain ?? deeplinkingObject.domain
        }
        set(newDomain) {
            backingDomain = newDomain
        }
    }
    
    var path: String? {
        get {
            return backingPath ?? deeplinkingObject.path
        }
        set(newPath) {
            backingPath = newPath
        }
    }
    
    var queryItems: [NSURLQueryItem]? {
        get {
            return backingQueryItems ?? deeplinkingObject.queryItems
        }
        set(newQueryItems) {
            backingQueryItems = newQueryItems
        }
    }
    
    var deeplinkURL: NSURL {
        get {
            return backingDeeplinkURL ?? deeplinkingObject.deeplinkURL
        }
        set(newDeeplinkURL) {
            backingDeeplinkURL = newDeeplinkURL
        }
    }

    @objc func execute(completion: ((NSError?) -> ())?) {
        if let closure = executeClosure {
            closure(completion)
        } else if overrideExecute {
            completion?(overrideExecuteValue)
        } else {
            deeplinkingObject.execute(completion)
        }
    }
    
    init(deeplinkingObject: Deeplinking) {
        self.deeplinkingObject = deeplinkingObject
        super.init()
    }
}

@objc class LoginManagingProtocolMock : NSObject, LoginManaging {
    
    var loginClosure: (([RidesScope], UIViewController?, ((accessToken: AccessToken?, error: NSError?) -> Void)?) -> Void)?
    var openURLClosure: ((UIApplication, NSURL, String?, AnyObject?) -> Bool)?
    var didBecomeActiveClosure: (() -> ())?

    var backingManager: LoginManaging?
    
    init(loginManaging: LoginManaging? = nil) {
        backingManager = loginManaging
        super.init()
    }
    
    func login(requestedScopes scopes: [RidesScope], presentingViewController: UIViewController?, completion: ((accessToken: AccessToken?, error: NSError?) -> Void)?) {
        if let closure = loginClosure {
            closure(scopes, presentingViewController, completion)
        } else if let manager = backingManager {
            manager.login(requestedScopes: scopes, presentingViewController: presentingViewController, completion: completion)
        }
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        if let closure = openURLClosure {
            return closure(application, url, sourceApplication, annotation)
        } else if let manager = backingManager {
            return manager.application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
        } else {
            return false
        }
    }
    
    func applicationDidBecomeActive() {
        if let closure = didBecomeActiveClosure {
            closure()
        } else if let manager = backingManager {
            manager.applicationDidBecomeActive()
        }
    }
}

@objc class LoginManagerPartialMock : LoginManager {
    
    var executeLoginClosure: (() -> ())?
    
    override func executeLogin() {
        if let closure = executeLoginClosure {
            closure()
        } else {
            super.executeLogin()
        }
    }
}

@objc class NativeAuthenticatorPartialMock : NativeAuthenticator {
    
    var handleRedirectClosure: ((NSURLRequest) -> (Bool))?
    
    override func handleRedirectRequest(request: NSURLRequest) -> Bool {
        if let closure = handleRedirectClosure {
            return closure(request)
        } else {
            return super.handleRedirectRequest(request)
        }
    }
    
}
