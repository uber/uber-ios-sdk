//
//  AuthorizationBaseViewController.swift
//  Swift SDK
//
//  Copyright © 2015 Uber Technologies, Inc. All rights reserved.
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

import UberCore
import UberRides

class AuthorizationBaseViewController: UIViewController {
    
    func delay(_ delay: Int, closure: @escaping ()->()) {
        let deadlineTime = DispatchTime.now() + DispatchTimeInterval.seconds(delay)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            closure()
        }
    }
    
    func showMessage(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okayAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil)
        alert.addAction(okayAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func checkError(_ response: Response) {
        // Unauthorized
        if response.statusCode == 401 {
            _ = TokenManager.deleteToken()
            DispatchQueue.main.async {
                self.reset()
            }
        }
    }
    
    func reset() {
    }
}
