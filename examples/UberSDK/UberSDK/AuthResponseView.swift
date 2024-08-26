//
//  Copyright © Uber Technologies, Inc. All rights reserved.
//


import SwiftUI

struct AuthReponse: Identifiable {
    var id: String { value }
    var value: String
}

struct AuthResponseView: View {
    
    @Binding
    private var response: AuthReponse?
    
    init(response: Binding<AuthReponse?>) {
        self._response = response
    }
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(
                    action: { response = nil },
                    label: {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .tint(.secondary)
                    }
                )
                .padding()
            }
            
            ScrollView(.horizontal) {
                Text(response?.value ?? "")
                    .textSelection(.enabled)
                    .padding()
            }
        }
        Spacer()
    }
}
