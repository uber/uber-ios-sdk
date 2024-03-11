//
//  Copyright © Uber Technologies, Inc. All rights reserved.
//


import Foundation
import SwiftUI

typealias SelectionOption = Hashable & Identifiable & CustomStringConvertible

struct SelectionView<Value: SelectionOption>: View {
    
    @Environment(\.dismiss) var dismiss: DismissAction
    
    @Binding var selection: Value?
    let options: [Value]
    
    init(selection: Binding<Value?>,
         options: [Value]) {
        self._selection = selection
        self.options = options
    }
    
    var body: some View {
        List(selection: $selection) {
            ForEach(options) { item in
                Button(
                    action: {
                        selection = item
                        dismiss()
                    },
                    label: {
                        HStack {
                            Text(item.description)
                            Spacer()
                            if item == selection {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                )
            }
        }
        .tint(.black)
    }
}
