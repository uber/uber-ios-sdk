//
//  AppDelegate.swift
//  TutorialBase - Basic Button Finished

import UIKit
import UberRides

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // If true, all requests will hit the sandbox, useful for testing
        Configuration.setSandboxEnabled(true)
        
        return true
    }
}

