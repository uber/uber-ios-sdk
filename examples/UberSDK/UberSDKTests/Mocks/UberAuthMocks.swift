///
/// @Generated by Mockolo
///



import AuthenticationServices
import Foundation
import UIKit
@testable import UberAuth
import UberCore


public class AuthorizationCodeResponseParsingMock: AuthorizationCodeResponseParsing {
    public init() { }


    public private(set) var isValidResponseCallCount = 0
    public var isValidResponseHandler: ((URL, String) -> (Bool))?
    public func isValidResponse(url: URL, matching redirectURI: String) -> Bool {
        isValidResponseCallCount += 1
        if let isValidResponseHandler = isValidResponseHandler {
            return isValidResponseHandler(url, redirectURI)
        }
        return false
    }

    public private(set) var callAsFunctionCallCount = 0
    public var callAsFunctionHandler: ((URL) -> (Result<Client, UberAuthError>))?
    public func callAsFunction(url: URL) -> Result<Client, UberAuthError> {
        callAsFunctionCallCount += 1
        if let callAsFunctionHandler = callAsFunctionHandler {
            return callAsFunctionHandler(url)
        }
        fatalError("callAsFunctionHandler returns can't have a default value thus its handler must be set")
    }
}

public class ApplicationLaunchingMock: ApplicationLaunching {
    public init() { }


    public private(set) var openCallCount = 0
    public var openHandler: ((URL, [UIApplication.OpenExternalURLOptionsKey: Any], ((Bool) -> Void)?) -> ())?
    public func open(_ url: URL, options: [UIApplication.OpenExternalURLOptionsKey: Any], completionHandler: ((Bool) -> Void)?)  {
        openCallCount += 1
        if let openHandler = openHandler {
            openHandler(url, options, completionHandler)
        }
        
    }
}

public class ConfigurationProvidingMock: ConfigurationProviding {
    public init() { }
    public init(clientID: String? = nil, redirectURI: String? = nil) {
        self.clientID = clientID
        self.redirectURI = redirectURI
    }


    public private(set) var clientIDSetCallCount = 0
    public var clientID: String? = nil { didSet { clientIDSetCallCount += 1 } }

    public private(set) var redirectURISetCallCount = 0
    public var redirectURI: String? = nil { didSet { redirectURISetCallCount += 1 } }

    public private(set) var isInstalledCallCount = 0
    public var isInstalledHandler: ((UberApp, Bool) -> (Bool))?
    public func isInstalled(app: UberApp, defaultIfUnregistered: Bool) -> Bool {
        isInstalledCallCount += 1
        if let isInstalledHandler = isInstalledHandler {
            return isInstalledHandler(app, defaultIfUnregistered)
        }
        return false
    }
}

class AuthenticationSessioningMock: AuthenticationSessioning {
        private var _anchor: ASPresentationAnchor!
    private var _callbackURLScheme: String!
    private var _completion: AuthCompletion!
    private var _url: URL!
    init() { }
    required init(anchor: ASPresentationAnchor, callbackURLScheme: String = "", url: URL = URL(fileURLWithPath: ""), completion: @escaping AuthCompletion) {
        self._anchor = anchor
        self._callbackURLScheme = callbackURLScheme
        self._url = url
        self._completion = completion
    }


    private(set) var startCallCount = 0
    var startHandler: (() -> ())?
    func start()  {
        startCallCount += 1
        if let startHandler = startHandler {
            startHandler()
        }
        
    }
}

public class AuthProvidingMock: AuthProviding {
    public init() { }


    public private(set) var executeCallCount = 0
    public var executeHandler: ((AuthDestination, Prefill?, @escaping (Result<Client, UberAuthError>) -> ()) -> ())?
    public func execute(authDestination: AuthDestination, prefill: Prefill?, completion: @escaping (Result<Client, UberAuthError>) -> ())  {
        executeCallCount += 1
        if let executeHandler = executeHandler {
            executeHandler(authDestination, prefill, completion)
        }
        
    }

    public private(set) var handleCallCount = 0
    public var handleHandler: ((URL) -> (Bool))?
    public func handle(response url: URL) -> Bool {
        handleCallCount += 1
        if let handleHandler = handleHandler {
            return handleHandler(url)
        }
        return false
    }
}

class AuthManagingMock: AuthManaging {
    init() { }


    private(set) var loginCallCount = 0
    var loginHandler: ((AuthContext, @escaping AuthCompletion) -> ())?
    func login(context: AuthContext, completion: @escaping AuthCompletion)  {
        loginCallCount += 1
        if let loginHandler = loginHandler {
            loginHandler(context, completion)
        }
        
    }

    private(set) var handleCallCount = 0
    var handleHandler: ((URL) -> (Bool))?
    func handle(_ url: URL) -> Bool {
        handleCallCount += 1
        if let handleHandler = handleHandler {
            return handleHandler(url)
        }
        return false
    }
}

