//
//  Copyright © Uber Technologies, Inc. All rights reserved.
//


import SwiftUI
import UberAuth

@Observable
class Content {
    var isAuthTypeSheetPresented: Bool = false
    var authType: AuthType? = .authorizationCode
}

struct ContentView: View {
    
    @Bindable var content: Content = .init()
    @State var isAuthTypeSheetPresented: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                Section(
                    "Login",
                    content: { loginSection }
                )
            }
            .navigationTitle("Uber iOS SDK")
        }
        .sheet(isPresented: $content.isAuthTypeSheetPresented, content: {
            SelectionView(
                selection: $content.authType,
                options: AuthType.allCases
            )
            .presentationDetents([.height(200)])
        })
    }
    
    // MARK: Uber Auth
    
    private func login() {
        UberAuth.login { result in
            switch result {
            case .success(let client):
                print(client)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    // MARK: Subviews
    
    @ViewBuilder
    private var loginSection: some View {
        row(
            item: Item.authType,
            content: {
                Text(content.authType?.description ?? "")
                    .foregroundStyle(.gray)
            },
            tapHandler: {
                content.isAuthTypeSheetPresented = true
            }
        )
        Button(
            action: { login() },
            label: {
                Text("Login")
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        )
        .padding()
    }
    
    private func row(item: Item? = nil,
                     @ViewBuilder content: () -> (some View),
                     tapHandler: (() -> Void)? = nil) -> some View {
        Button(
            action: { tapHandler?() },
            label: {
                HStack(spacing: 0) {
                    if let item { Text(item.rawValue) }
                    Spacer()
                    content()
                    emptyNavigationLink
                }
            }
        )
        .tint(.black)
    }
    
    private let emptyNavigationLink: some View = NavigationLink.empty
        .frame(width: 17, height: 0)
        .frame(alignment: .leading)
    
    enum Item: String, Hashable {
        case authType = "Auth Type"
    }
}

enum AuthType: String, Hashable, Identifiable, CaseIterable, CustomStringConvertible {
    case authorizationCode = "Authorization Code"

    var description: String { rawValue }
    var id: String { rawValue }
}

#Preview {
    ContentView()
}
