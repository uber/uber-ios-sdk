//
//  AsyncDispatcher.swift
//  UberRides
//
//  Copyright © 2018 Uber Technologies, Inc. All rights reserved.
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

/// A helper class to execute dependent asynchronous methods on an array of elements serially
class AsyncDispatcher<T, U> {

    typealias AsyncCompletion = ((T) -> Void)?
    typealias AsyncContinue = (T) -> Bool

    /// Executes the given asyncMethod for each element in the list serially. Allows for aborting the list early if required.
    ///
    /// - Parameters:
    ///   - elements: The list with which to execute asyncMethod.
    ///   - with: block called just prior to executing asyncMethod with the given element.
    ///   - asyncMethod: the async method to execute.
    ///   - continue: block called with the results of asyncMethod; return true to move onto the next element, or false to abort the loop.
    ///   - finally: block called after the asyncMethod loop has completed, either due to reaching the end of the list or aborting early.
    static func exec(for elements: [U],
                     with: @escaping (U) -> (),
                     asyncMethod: @escaping (U, AsyncCompletion) -> (),
                     continue: @escaping AsyncContinue,
                     finally: @escaping () -> ()) {
        if elements.first != nil {
            execHelper(for: elements, currentIndex: 0, with: with, asyncMethod: asyncMethod, continue: `continue`, finally: finally)
        }
    }

    private static func execHelper(for elements: [U],
                                   currentIndex: Int,
                                   with: @escaping (U) -> (),
                                   asyncMethod: @escaping (U, AsyncCompletion) -> (),
                                   continue: @escaping AsyncContinue,
                                   finally: @escaping () -> ()) {
        let element = elements[currentIndex]
        with(element)
        asyncMethod(element) { (result: T) in
            let next = `continue`(result)
            if next && currentIndex < elements.count - 1 {
                execHelper(for: elements, currentIndex: (currentIndex + 1), with: with, asyncMethod: asyncMethod, continue: `continue`, finally: finally)
            } else {
                finally()
            }
        }
    }
}
