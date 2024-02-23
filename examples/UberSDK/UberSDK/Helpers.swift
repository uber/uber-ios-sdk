//
//  Copyright © Uber Technologies, Inc. All rights reserved.
//


import Foundation
import SwiftUI

extension NavigationLink where Label == EmptyView, Destination == EmptyView {
   static var empty: NavigationLink {
       self.init(destination: EmptyView(), label: { EmptyView() })
   }
}
