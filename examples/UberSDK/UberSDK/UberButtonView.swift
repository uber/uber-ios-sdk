//
//  Copyright © Uber Technologies, Inc. All rights reserved.
//


import Foundation
import SwiftUI
import UberAuth
import UberCore

struct UberButtonView: UIViewRepresentable {
    func makeUIView(context: Context) -> UberCore.UberButton {
        LoginButton()
    }
    
    func updateUIView(_ uiView: UberCore.UberButton, context: Context) {}
}

#Preview {
    VStack {
        UberButtonView()
            .padding()
    }
}
