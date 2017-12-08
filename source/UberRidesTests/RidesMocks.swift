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
@testable import UberCore
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
    
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
        if let presentViewControllerClosure = presentViewControllerClosure {
            presentViewControllerClosure(viewControllerToPresent, flag, completion)
        } else {
            super.present(viewControllerToPresent, animated: flag, completion: completion)
        }
    }

}

class WebViewMock : WKWebView {
    var testClosure: ((URLRequest) -> ())?
    init(frame: CGRect, configuration: WKWebViewConfiguration, testClosure: ((URLRequest) -> ())?) {
        self.testClosure = testClosure
        super.init(frame: frame, configuration: configuration)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func load(_ request: URLRequest) -> WKNavigation? {
        testClosure?(request)
        return nil
    }
}

class RequestDeeplinkMock : RequestDeeplink {
    var testClosure: ((URL?) -> (Bool))?
    init(rideParameters: RideParameters, testClosure: ((URL?) -> (Bool))?) {
        self.testClosure = testClosure
        super.init(rideParameters: rideParameters, fallbackType: .mobileWeb)
    }
    
    override func execute(completion: ((NSError?) -> ())? = nil) {
        guard let testClosure = testClosure else {
            completion?(nil)
            return
        }
        _ = testClosure(url)
    }
}

class DeeplinkRequestingBehaviorMock: DeeplinkRequestingBehavior {
    var testClosure: ((URL?) -> (Bool))?
    init(testClosure: ((URL?) -> (Bool))?) {
        self.testClosure = testClosure
        super.init()
    }
    
    override func createDeeplink(rideParameters: RideParameters) -> RequestDeeplink {
        return RequestDeeplinkMock(rideParameters: rideParameters, testClosure: testClosure)
    }
}

@objc class RideRequestViewControllerDelegateMock : NSObject, RideRequestViewControllerDelegate {
    let testClosure: (RideRequestViewController, NSError) -> ()
    init(testClosure: @escaping (RideRequestViewController, NSError) -> ()) {
        self.testClosure = testClosure
    }
    @objc func rideRequestViewController(_ rideRequestViewController: RideRequestViewController, didReceiveError error: NSError) {
        self.testClosure(rideRequestViewController, error)
    }
}

@objc class DeeplinkingProtocolMock : NSObject, Deeplinking {
    
    let deeplinkingObject: Deeplinking
    
    var executeClosure: ((((NSError?) -> ())?) -> ())?
    var backingDeeplinkURL: URL?
    
    var overrideExecute: Bool = false
    var overrideExecuteValue: NSError? = nil
    
    var url: URL {
        get {
            return backingDeeplinkURL ?? deeplinkingObject.url
        }
        set(newDeeplinkURL) {
            backingDeeplinkURL = newDeeplinkURL
        }
    }

    var fallbackURLs: [URL] = []

    @objc func execute(completion: ((NSError?) -> ())?) {
        if let closure = executeClosure {
            closure(completion)
        } else if overrideExecute {
            completion?(overrideExecuteValue)
        } else {
            deeplinkingObject.execute(completion: completion)
        }
    }
    
    init(deeplinkingObject: Deeplinking) {
        self.deeplinkingObject = deeplinkingObject
        super.init()
    }
}
