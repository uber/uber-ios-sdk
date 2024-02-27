//
//  URLComponentsExtensionsTests.swift
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

import Foundation
import XCTest
@testable import UberRides

class URLComponentsExtensionsTests: XCTestCase {

    // MARK: - FragmentItems

    func testFragmentItems_returnsNil_whenNoFragment() {
        let urlString = "https://test.uber.com"
        guard let url = URL(string: "\(urlString)"),
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            XCTFail("Unable to create URL")
            return
        }

        XCTAssertNil(components.fragmentItems)
    }

    func testFragmentItems_returnsEmpty_whenEmptyFragment() {
        let urlString = "https://test.uber.com"
        let fragment: String? = ""
        guard let url = URL(string: "\(urlString)"),
            var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
                XCTFail("Unable to create URL")
                return
        }
        components.fragment = fragment

        XCTAssertTrue(components.fragmentItems?.isEmpty ?? false)
    }

    func testFragmentItems_returnsQueryItems_whenFragmentQueryItems() {
        let urlString = "https://test.uber.com"
        let expectedQueryItems = [
            URLQueryItem(name: "name1", value: "value1"),
            URLQueryItem(name: "name2", value: "value2"),
        ]

        guard let url = URL(string: "\(urlString)"),
            var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
                XCTFail("Unable to create URL")
                return
        }
        components.queryItems = expectedQueryItems
        components.fragment = components.query
        components.queryItems = nil

        guard let fragmentItems = components.fragmentItems else {
            XCTFail("Unable to create queryItems")
            return
        }

        XCTAssertEqual(expectedQueryItems, fragmentItems)
    }

    // MARK: - AllItems

    func testAllItems_returnsNil_whenNoFragmentAndNoQuery() {
        let urlString = "https://test.uber.com"
        guard let url = URL(string: "\(urlString)"),
            var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
                XCTFail("Unable to create URL")
                return
        }
        components.fragment = nil
        components.query = nil

        XCTAssertNil(components.allItems)
    }

    func testAllItems_returnsQueryItems_whenQuery() {
        let urlString = "https://test.uber.com"
        let expectedQueryItems = [
            URLQueryItem(name: "name1", value: "value1"),
            URLQueryItem(name: "name2", value: "value2"),
            ]

        guard let url = URL(string: "\(urlString)"),
            var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
                XCTFail("Unable to create URL")
                return
        }
        components.queryItems = expectedQueryItems
        components.fragment = nil

        guard let allItems = components.allItems else {
            XCTFail("Unable to create allItems")
            return
        }

        XCTAssertEqual(expectedQueryItems, allItems)
    }

    func testAllItems_returnsFragmentItems_whenFragment() {
        let urlString = "https://test.uber.com"
        let expectedFragmentItems = [
            URLQueryItem(name: "name1", value: "value1"),
            URLQueryItem(name: "name2", value: "value2"),
            ]

        guard let url = URL(string: "\(urlString)"),
            var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
                XCTFail("Unable to create URL")
                return
        }
        components.queryItems = expectedFragmentItems
        components.fragment = components.query
        components.queryItems = nil

        guard let allItems = components.allItems else {
            XCTFail("Unable to create allItems")
            return
        }

        XCTAssertEqual(expectedFragmentItems, allItems)
    }

    func testAllItems_returnsFragmentItemsAndQueryItems_whenFragmentAndQuery() {
        let urlString = "https://test.uber.com"
        let expectedQueryItems = [
            URLQueryItem(name: "name1", value: "value1"),
            URLQueryItem(name: "name2", value: "value2"),
            ]
        let expectedFragmentItems = [
            URLQueryItem(name: "name3", value: "value3"),
            URLQueryItem(name: "name4", value: "value4"),
            ]
        let expectedAllItems = expectedQueryItems + expectedFragmentItems
        guard let url = URL(string: "\(urlString)"),
            var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
                XCTFail("Unable to create URL")
                return
        }
        components.queryItems = expectedFragmentItems
        components.fragment = components.query
        components.queryItems = expectedQueryItems

        guard let allItems = components.allItems else {
            XCTFail("Unable to create allItems")
            return
        }

        XCTAssertEqual(expectedAllItems, allItems)
    }
}
