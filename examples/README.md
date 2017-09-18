# Example Apps

Example apps can be found in the `examples` folder. To build them, you can use Carthage or Cocoapods. 

## Carthage
From inside the `examples/Swift SDK` or `examples/Obj-C SDK` folder, run:

```
carthage update --platform iOS
```
This will build the required dependencies. Once you do that, open `Swift SDK.xcodeproj` or `Obj-C SDK.xcodeproj` in Xcode and run it.

## CocoaPods
First, you will have to remove Carthage dependencies. Navigate to the project folder and remove `Cartfile` and `Cartfile.resolved`. If you see a `Carthage` folder, remove that as well. Open .xcworkspace and navigate to  **General** tab, scroll to **Embedded Binaries** select `ObjectMapper.framework` and click the `-` button, do the same for `UberRides.framework`. Now go to  **Build Settings** tab and scroll to **Search Paths**, click on **Framework Search Paths** and remove the line $(PROJECT_DIR)/Carthage/Build/iOS.
Now go to **Build Phases** find the **Copy Carthage Frameworks** and remove it.

Now, still inside either `examples/Swift SDK` or `examples/Obj-C SDK`, create a new **Podfile** by running `pod init`, then add `pod 'UberRides'` to your main target. If you are using the Swift SDK, make sure to add the line `use_frameworks!`. Your **Podfile** should contain the following information:


```ruby
target 'Obj-C SDK' do
  use_frameworks!
  pod 'UberRides'
end
```

Then, run the following command to install the dependency:

```bash
$ pod install
```

Now you can build the project.

<p align="center">
  <img src="https://github.com/uber/rides-ios-sdk/blob/master/img/example_app.png?raw=true" alt="Example App Screenshot"/>
</p>
