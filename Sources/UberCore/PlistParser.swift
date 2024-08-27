//
//  PlistParser.swift
//  UberCore
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

public struct PlistParser {
    
    private let contents: [String: Any]
    
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
            self.contents = [:]
            return
        }
        
        guard let contents = (try? NSDictionary(contentsOf: plistUrl, error: ())) as? [String: Any] else {
            self.contents = [:]
            return
        }
        
        self.contents = contents
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
        let contents = (try NSDictionary(contentsOf: plistUrl, error: ())) as? [String: Any] ?? [:]
        self.contents = contents
    }
    
    public subscript<T>(key: String) -> T? {
        contents[key] as? T
    }
    
    public enum ParserError: Error {
        
        // A plist with the supplied name was not found
        case noResourceFound
        
        // An `UberAuth` object was not found in the plist
        case missingContents
    }
}
