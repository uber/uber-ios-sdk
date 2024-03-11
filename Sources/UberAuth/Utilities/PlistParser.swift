//
//  Copyright © Uber Technologies, Inc. All rights reserved.
//


import Foundation

/// @mockable
public protocol ConfigurationProviding {
    var clientID: String? { get }
    var redirectURI: String? { get }
}

public struct PlistParser {
    
    private let dict: [String: Any]
    
    /// A non-throwing initializer. Any invalid parameters will result in 
    /// empty storage and all keys will return nil.
    /// All keys are checked against the `UberAuth` object contained in the plist.
    ///
    /// - Parameters:
    ///   - name: The name of the plist to access
    ///   - bundle: The bundle the plist is contained in
    public init(plistName: String,
         bundle: Bundle = .main) {
        guard let plistUrl = bundle.url(forResource: plistName, withExtension: "plist") else {
            self.dict = [:]
            return
        }
        
        guard let contents = try? NSDictionary(contentsOf: plistUrl, error: ()),
              let dict = contents["UberAuth"] as? Dictionary<String, Any> else {
            self.dict = [:]
            return
        }
        
        self.dict = dict
    }
    
    /// A throwing initializer. Any invalid parameters will result in
    /// a thrown ParserError indicating the failure.
    /// All keys are checked against the `UberAuth` object contained in the plist.
    ///
    /// - Parameters:
    ///   - name: The name of the plist to access
    ///   - bundle: The bundle the plist is contained in
    public init(name: String,
         bundle: Bundle = .main) throws {
        guard let plistUrl = bundle.url(forResource: name, withExtension: "plist") else {
            throw ParserError.noResourceFound
        }
        let contents = try NSDictionary(contentsOf: plistUrl, error: ())
        guard let dict = contents["UberAuth"] as? Dictionary<String, Any> else {
            throw ParserError.missingContents
        }
        self.dict = dict
    }
    
    public subscript<T>(key: String) -> T? {
        dict[key] as? T
    }
    
    public enum ParserError: Error {
        
        // A plist with the supplied name was not found
        case noResourceFound
        
        // An `UberAuth` object was not found in the plist
        case missingContents
    }
}

extension PlistParser: ConfigurationProviding {
    
    public var clientID: String? {
        self["ClientID"]
    }
    
    public var redirectURI: String? {
        self["RedirectURI"]
    }
}
