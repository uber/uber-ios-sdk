//
//  UberMocks.swift
//  UberCoreTests
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


@testable import UberCore

class LoginManagerPartialMock: LoginManager {
    var executeLoginClosure: ((AuthenticationCompletionHandler?) -> ())?

    @objc public override func login(requestedScopes scopes: [UberScope],
                                     presentingViewController: UIViewController?,
                                     prefillValues: Prefill?,
                                     completion: ((_ accessToken: AccessToken?, _ error: NSError?) -> Void)?) {
        executeLoginClosure?(completion)
    }
}

@objc class LoginManagingProtocolMock: NSObject, LoginManaging {

    var loginClosure: (([UberScope], UIViewController?, ((_ accessToken: AccessToken?, _ error: NSError?) -> Void)?) -> Void)?
    var openURLClosure: ((UIApplication, URL, String?, Any?) -> Bool)?
    var didBecomeActiveClosure: (() -> ())?
    var willEnterForegroundClosure: (() -> ())?

    var backingManager: LoginManaging?

    init(loginManaging: LoginManaging? = nil) {
        backingManager = loginManaging
        super.init()
    }

    func login(requestedScopes scopes: [UberScope],
               presentingViewController: UIViewController?,
               prefillValues: Prefill?,
               completion: ((_ accessToken: AccessToken?, _ error: NSError?) -> Void)?) {
        if let closure = loginClosure {
            closure(scopes, presentingViewController, completion)
        } else if let manager = backingManager {
            manager.login(
                requestedScopes: scopes,
                presentingViewController: presentingViewController,
                prefillValues: nil,
                completion: completion
            )
        }
    }

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any?) -> Bool {
        if let closure = openURLClosure {
            return closure(application, url, sourceApplication, annotation)
        } else if let manager = backingManager {
            return manager.application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
        } else {
            return false
        }
    }

    @available(iOS 9.0, *)
    public func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        let sourceApplication = options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String
        let annotation = options[.annotation] as Any?

        return application(app, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }

    func applicationDidBecomeActive() {
        if let closure = didBecomeActiveClosure {
            closure()
        } else if let manager = backingManager {
            manager.applicationDidBecomeActive()
        }
    }

    func applicationWillEnterForeground() {
        if let closure = willEnterForegroundClosure {
            closure()
        } else {
            backingManager?.applicationWillEnterForeground()
        }
    }
}

class RidesNativeAuthenticatorPartialStub: BaseAuthenticator {
    var consumeResponseCompletionValue: (AccessToken?, NSError?)?
    override func consumeResponse(url: URL, completion: AuthenticationCompletionHandler?) {
        completion?(consumeResponseCompletionValue?.0, consumeResponseCompletionValue?.1)
    }
}

class EatsNativeAuthenticatorPartialStub: BaseAuthenticator {
    var consumeResponseCompletionValue: (AccessToken?, NSError?)?
    override func consumeResponse(url: URL, completion: AuthenticationCompletionHandler?) {
        completion?(consumeResponseCompletionValue?.0, consumeResponseCompletionValue?.1)
    }
}

class ImplicitAuthenticatorPartialStub: ImplicitGrantAuthenticator {
    var consumeResponseCompletionValue: (AccessToken?, NSError?)?
    override func consumeResponse(url: URL, completion: AuthenticationCompletionHandler?) {
        completion?(consumeResponseCompletionValue?.0, consumeResponseCompletionValue?.1)
    }
}
