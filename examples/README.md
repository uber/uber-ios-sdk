# Example Apps

Requires Xcode 9

There are two sample apps, one written in Objective-C, and another written in Swift.

The sample apps use [Cocoapods](https://cocoapods.org) for package management. To set up and open the sample apps, navigate to either the `Obj-C SDK` or `Swift SDK` folder and run the following command:

```bash
$ pod install
```

After Cocoapods installs the Uber dependencies, open `xcworkspace`, and run!

For the Objective-C project, you may run into a compilation error. If so, click on your Pods project and select the `UberRides` target. Search for the `Swift Language Version` property, and change it to "Swift 4.0". Do the same thing for `UberCore`. [See Cocoapods issue](https://github.com/CocoaPods/CocoaPods/issues/6791).

