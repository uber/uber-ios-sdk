//
//  Copyright © Uber Technologies, Inc. All rights reserved.
//


import SwiftUI
import UIKit

@main
struct UniversalLinkExampleApp: App {

    @StateObject var authUtility = AuthUtility()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authUtility)
        }
    }
}
