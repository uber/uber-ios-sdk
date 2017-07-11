//
//  KeychainWrapper.swift
//  UberRides
//
//  Copyright © 2016 Uber Technologies, Inc. All rights reserved.
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

/// Wraps saving and retrieving objects from keychain.
class KeychainWrapper: NSObject {
    private static let serviceName = "com.uber.rides-ios-sdk"
    private var accessGroup = ""
    
    private let Class = kSecClass as String
    private let AttrAccount = kSecAttrAccount as String
    private let AttrService = kSecAttrService as String
    private let AttrAccessGroup = kSecAttrAccessGroup as String
    private let AttrGeneric = kSecAttrGeneric as String
    private let AttrAccessible = kSecAttrAccessible as String
    private let ReturnData = kSecReturnData as String
    private let ValueData = kSecValueData as String
    private let MatchLimit = kSecMatchLimit as String
    
    /**
     Set the access group for keychain to use.
     
     - parameter group: String representing name of keychain access group.
     */
    func setAccessGroup(_ accessGroup: String) {
        self.accessGroup = accessGroup
    }
    
    /**
     Save an object to keychain.
     
     - parameter object: object conforming to NSCoding to save to keychain.
     - parameter key:    key for the object.
     
     - returns: true if object was successfully added to keychain.
     */
    func setObject(_ object: NSCoding, key: String) -> Bool {
        var keychainItemData = getKeychainItemData(key)

        let value = NSKeyedArchiver.archivedData(withRootObject: object)
        keychainItemData[AttrAccessible] = kSecAttrAccessibleWhenUnlocked
        keychainItemData[ValueData] = value as AnyObject?
        
        var result: OSStatus = SecItemAdd(keychainItemData as CFDictionary, nil)
        
        if result == errSecDuplicateItem {
            result = SecItemUpdate(keychainItemData as CFDictionary, [ValueData: value] as CFDictionary)
        }

        return result == errSecSuccess
    }
    
    /**
     Get an object from the keychain.
     
     - parameter key: the key associated to the object to retrieve.
     
     - returns: the object in keychain or nil if none exists for the given key.
     */
    func getObjectForKey(_ key: String) -> NSCoding? {
        var keychainItemData = getKeychainItemData(key)
        
        keychainItemData[MatchLimit] = kSecMatchLimitOne
        keychainItemData[ReturnData] = kCFBooleanTrue
        
        var data: AnyObject?
        let result = withUnsafeMutablePointer(to: &data) {
            SecItemCopyMatching(keychainItemData as CFDictionary, UnsafeMutablePointer($0))
        }
        
        var object: AnyObject?
        
        if let data = data as? Data {
            object = NSKeyedUnarchiver.unarchiveObject(with: data) as AnyObject?
        }
        
        return result == noErr ? object as? NSCoding : nil
    }
    
    /**
     Remove an object from keychain
     
     - parameter key: key for object to remove.
     
     - returns: true if object was successfully deleted.
     */
    func deleteObjectForKey(_ key: String) -> Bool {
        let keychainItemData = getKeychainItemData(key)
        
        let result = SecItemDelete(keychainItemData as CFDictionary)
        
        return result == noErr
    }
    
    /**
     Helper method to build keychain query dictionary.
     
     - returns: dictionary of base attributes for keychain query.
     */
    private func getKeychainItemData(_ key: String) -> [String: AnyObject] {
        var keychainItemData = [String: AnyObject]()
        
        let identifier = key.data(using: String.Encoding.utf8)
        keychainItemData[AttrGeneric] = identifier as AnyObject?
        keychainItemData[AttrAccount] = identifier as AnyObject?
        keychainItemData[AttrService] = type(of: self).serviceName as AnyObject?
        keychainItemData[Class] = kSecClassGenericPassword
        
        if !accessGroup.isEmpty {
            keychainItemData[AttrAccessGroup] = accessGroup as AnyObject?
        }
        
        return keychainItemData
    }
}
