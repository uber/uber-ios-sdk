//
//  KeychainUtility.swift
//  UberAuth
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

/// @mockable
public protocol KeychainUtilityProtocol {
    
    /// Saves an object in the on device keychain using the supplied `key`
    ///
    /// - Parameters:
    ///   - value: The object to save. Must conform to the Codable protocol.
    ///   - key: A string value used to identify the saved object
    ///   - accessGroup: The accessGroup for which the operation should be performed
    /// - Returns: A boolean indicating whether or not the save operation was successful
    func save<V: Encodable>(_ value: V, for key: String, accessGroup: String?) -> Bool
    
    /// Retrieves an object from the on device keychain using the supplied `key`
    ///
    /// - Parameters:
    ///   - key: The identifier string used when saving the object
    ///   - accessGroup: The accessGroup for which the operation should be performed
    /// - Returns: If found, an optional type conforming to the Codable protocol
    func get<V: Decodable>(key: String, accessGroup: String?) -> V?
    
    /// Removes the object from the on device keychain corresponding to the supplied `key`
    ///
    /// - Parameters:
    ///   - key: The identifier string used when saving the object
    ///   - accessGroup: The accessGroup for which the operation should be performed
    /// - Returns: A boolean indicating whether or not the delete operation was successful
    func delete(key: String, accessGroup: String?) -> Bool
}

public extension KeychainUtilityProtocol {
    
    func save<V: Encodable>(_ value: V, for key: String) -> Bool {
        save(value, for: key, accessGroup: nil)
    }
    
    func get<V: Decodable>(key: String) -> V? {
        get(key: key, accessGroup: nil)
    }
    
    func delete(key: String) -> Bool {
        delete(key: key, accessGroup: nil)
    }
}

public final class KeychainUtility: KeychainUtilityProtocol {
    
    // MARK: Properties
    
    private let serviceName = "com.uber.uber-ios-sdk"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    // MARK: Initializers
    
    public init() {}
    
    // MARK: KeychainUtilityProtocol
    
    // MARK: Save
    
    /// Saves an object in the on device keychain using the supplied `key`
    ///
    /// - Parameters:
    ///   - value: The object to save. Must conform to the Codable protocol.
    ///   - key: A string value used to identify the saved object
    ///   - accessGroup: The accessGroup for which the operation should be performed
    /// - Returns: A boolean indicating whether or not the save operation was successful
    public func save<V: Encodable>(_ value: V, for key: String, accessGroup: String? = nil) -> Bool {
        guard let data = try? encoder.encode(value) else {
            return false
        }
        
        let valueData = NSData(data: data)
        var attributes = attributes(for: key, accessGroup: accessGroup)
        attributes[Attribute.accessible] = kSecAttrAccessibleWhenUnlocked
        attributes[Attribute.valueData] = valueData
        
        var result: OSStatus = SecItemAdd(
            attributes as CFDictionary,
            nil
        )
        
        if result == errSecDuplicateItem {
            result = SecItemUpdate(
                attributes as CFDictionary,
                [Attribute.valueData: valueData] as CFDictionary
            )
        }

        return result == errSecSuccess
    }
    
    // MARK: Get
    
    /// Retrieves an object from the on device keychain using the supplied `key`
    ///
    /// - Parameters:
    ///   - key: The identifier string used when saving the object
    ///   - accessGroup: The accessGroup for which the operation should be performed
    /// - Returns: If found, an optional type conforming to the Codable protocol
    public func get<V: Decodable>(key: String, accessGroup: String? = nil) -> V? {

        var attributes = attributes(for: key, accessGroup: accessGroup)
        attributes[Attribute.matchLimit] = kSecMatchLimitOne
        attributes[Attribute.returnData] = kCFBooleanTrue
        
        var obj: AnyObject?
        let result = SecItemCopyMatching(
            attributes as CFDictionary,
            UnsafeMutablePointer(&obj)
        )

        guard result == noErr else {
            return nil
        }
        
        guard let data = obj as? Data,
              let value = try? decoder.decode(V.self, from: data) else {
            return nil
        }
        
        return value
    }
    
    // MARK: Delete
    
    /// Removes the object from the on device keychain corresponding to the supplied `key`
    ///
    /// - Parameters:
    ///   - key: The identifier string used when saving the object
    ///   - accessGroup: The accessGroup for which the operation should be performed
    /// - Returns: A boolean indicating whether or not the delete operation was successful
    public func delete(key: String, accessGroup: String? = nil) -> Bool {
        SecItemDelete(
            attributes(for: key, accessGroup: accessGroup) as CFDictionary
        ) == noErr
    }
    
    // MARK: Private
    
    /// Builds a base set of attributes used to perform a keychain storage operation
    ///
    /// - Parameters:
    ///   - key: The object identifier
    ///   -  accessGroup: An optional access group identifier
    /// - Returns: A dictionary containing the attributes
    private func attributes(for key: String, accessGroup: String?) -> [String: Any] {

        let identifier = key.data(using: .utf8)
        
        var itemData = [String: Any]()
        itemData[Attribute.generic] = identifier as AnyObject
        itemData[Attribute.account] = identifier as AnyObject
        itemData[Attribute.service] = serviceName as AnyObject
        itemData[Attribute.class] = kSecClassGenericPassword
        
        if let accessGroup,
            !accessGroup.isEmpty {
            itemData[Attribute.accessGroup] = accessGroup as AnyObject
        }
        
        return itemData
    }
    
    // MARK: Constants
    
    enum Attribute {
        static let `class` = kSecClass as String
        static let account = kSecAttrAccount as String
        static let service = kSecAttrService as String
        static let accessControl = kSecAttrAccessControl as String
        static let accessGroup = kSecAttrAccessGroup as String
        static let generic = kSecAttrGeneric as String
        static let accessible = kSecAttrAccessible as String
        static let returnData = kSecReturnData as String
        static let valueData = kSecValueData as String
        static let matchLimit = kSecMatchLimit as String
    }
}
