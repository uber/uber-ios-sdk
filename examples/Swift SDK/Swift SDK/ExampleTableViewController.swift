//
//  ExampleTableViewController.swift
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

import UIKit
import UberRides

class ExampleTableViewController: UITableViewController {
    
    let authorizationCodeGrantSegueIdentifier = "AuthorizationCodeGrantSegue"
    let implicitGrantSegueIdentifier = "ImplicitGrantSegue"

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "basicCell")
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("basicCell", forIndexPath: indexPath)
        
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Deeplink Request Buttons"
                cell.textLabel?.textColor = UIColor.blackColor()
                cell.accessoryType = .DisclosureIndicator
            case 1:
                cell.textLabel?.text = "Ride Request Widget Button"
                cell.textLabel?.textColor = UIColor.blackColor()
                cell.accessoryType = .DisclosureIndicator
            case 2:
                cell.textLabel?.text = "Implicit Grant / Login Manager"
                cell.textLabel?.textColor = UIColor.blackColor()
                cell.accessoryType = .DisclosureIndicator
            case 3:
                cell.textLabel?.text = "Authorization Code Grant / Login Manager"
                cell.textLabel?.textColor = UIColor.blackColor()
                cell.accessoryType = .DisclosureIndicator
            case 4:
                cell.textLabel?.text = "Native Login"
                cell.textLabel?.textColor = UIColor.blackColor()
                cell.accessoryType = .DisclosureIndicator
            default:
                break
            }
        case 1:
            fallthrough
        default:
            cell.textLabel?.text = "Logout"
            cell.textLabel?.textColor = UIColor.redColor()
            cell.accessoryType = .None
        }
        
        
        return cell
    }
    
    //MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        var viewControllerToPush: UIViewController?
        
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                viewControllerToPush = DeeplinkExampleViewController()
            case 1:
                viewControllerToPush = RideRequestWidgetExampleViewController()
            case 2:
                performSegueWithIdentifier(implicitGrantSegueIdentifier, sender: self)
                return
            case 3:
                performSegueWithIdentifier(authorizationCodeGrantSegueIdentifier, sender: self)
                return
            case 4:
                viewControllerToPush = NativeLoginExampleViewController()
            default:
                break
            }
        case 1:
            viewControllerToPush = nil
            TokenManager.deleteToken()
        default:
            viewControllerToPush = nil
        }
        
        
        if let viewController = viewControllerToPush {
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    //MARK: UITableViewDataSource Methods
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 5
        case 1:
            return 1
        default:
            return 0
        }
    }
}
