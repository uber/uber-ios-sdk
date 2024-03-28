//
//  Copyright © Uber Technologies, Inc. All rights reserved.
//


import SwiftUI
import UberAuth
import UberCore

class PrefillBuilder {
    var firstName: String = ""
    var lastName: String = ""
    var email: String = ""
    var phoneNumber: String = ""
    
    var prefill: Prefill {
        .init(
            email: email,
            phoneNumber: phoneNumber,
            firstName: firstName,
            lastName: lastName
        )
    }
}

@Observable
final class Content {
    var selection: Item?
    var type: LoginType? = .authorizationCode
    var destination: LoginDestination? = .inApp
    var isPrefillExpanded: Bool = false
    var response: String?
    var prefillBuilder = PrefillBuilder()
    
    func login() {
        
        let authProvider: AuthProviding = .authorizationCode(
            shouldExchangeAuthCode: false
        )
        
        let authDestination: AuthDestination = {
            guard let destination else { return .inApp }
            switch destination {
            case .inApp: return .inApp
            case .native: return .native(appPriority: [.rides, .eats, .driver])
            }
        }()
        
        UberAuth.login(
            context: .init(
                authDestination: authDestination,
                authProvider: authProvider,
                prefill: isPrefillExpanded ? prefillBuilder.prefill : nil
            ),
            completion: { result in
                switch result {
                case .success(let client):
                    print(client)
                    self.response = "\(client)"
                case .failure(let error):
                    self.response = error.localizedDescription
                }
            }
        )
    }
    
    func openUrl(_ url: URL) {
        UberAuth.handle(url)
    }
    
    enum Item: String, Hashable, Identifiable {
        case type = "Auth Type"
        case destination = "Destination"
        case prefill = "Prefill Values"
        case firstName = "First Name"
        case lastName = "Last Name"
        case email = "Email"
        case phoneNumber = "Phone Number"
        
        
        var id: String { rawValue }
        
        var options: [any SelectionOption] {
            switch self {
            case .type:
                return LoginType.allCases
            case .destination:
                return LoginDestination.allCases
            default:
                return []
            }
        }
    }
}

struct ContentView: View {
    
    @Bindable var content: Content = .init()
    @State var isAuthTypeSheetPresented: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                exampleList
                Divider()
                responseSection
            }
            .navigationTitle("Uber iOS SDK")
        }
        .onOpenURL { content.openUrl($0) }
        .sheet(item: $content.selection, content: { item in
            switch item {
            case .type:
                SelectionView(
                    selection: $content.type,
                    options: LoginType.allCases
                )
                .presentationDetents([.height(200)])
            case .destination:
                SelectionView(
                    selection: $content.destination,
                    options: LoginDestination.allCases
                )
                .presentationDetents([.height(200)])
            default:
                EmptyView()
            }
        })
    }
    
    // MARK: Subviews
    
    private var responseSection: some View {
        VStack {
            Text("Response:")
                .font(.title3)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
            ScrollView(.horizontal) {
                Text(content.response ?? "")
                    .selectionDisabled(false)
                    .padding()
            }
        }
        .frame(maxWidth: .infinity, minHeight: 150)
    }
    
    private var exampleList: some View {
        List {
            Section(
                "Login",
                content: { loginSection }
            )
        }
    }
    
    @ViewBuilder
    private var loginSection: some View {
        
        row(
            item: .type,
            content: {
                Text(content.type?.description ?? "")
                    .foregroundStyle(.gray)
            },
            tapHandler: { content.selection = .type }
        )
        
        row(
            item: .destination,
            content: {
                Text(content.destination?.description ?? "")
                    .foregroundStyle(.gray)
            },
            tapHandler: { content.selection = .destination }
        )
        
        row(
            item: .prefill,
            content: {
                Toggle(isOn: $content.isPrefillExpanded, label: { EmptyView() })
            },
            showDisclosureIndicator: false,
            tapHandler: nil
        )
        
        if content.isPrefillExpanded {
            row(
                content: { 
                    TextField(
                        Content.Item.firstName.rawValue,
                        text: $content.prefillBuilder.firstName
                    )
                },
                showDisclosureIndicator: false
            )
            row(
                content: { 
                    TextField(
                        Content.Item.lastName.rawValue,
                        text: $content.prefillBuilder.lastName
                    )
                },
                showDisclosureIndicator: false
            )
            row(
                content: {
                    TextField(
                        Content.Item.email.rawValue,
                        text: $content.prefillBuilder.email
                    )
                },
                showDisclosureIndicator: false
            )
            row(
                content: {
                    TextField(
                        Content.Item.phoneNumber.rawValue,
                        text: $content.prefillBuilder.phoneNumber
                    )
                },
                showDisclosureIndicator: false
            )
        }
        
        Button(
            action: { content.login() },
            label: {
                Text("Login")
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        )
        .padding()
    }
    
    private func row(item: Content.Item? = nil,
                     @ViewBuilder content: () -> (some View),
                     showDisclosureIndicator: Bool = true,
                     tapHandler: (() -> Void)? = nil) -> some View {
        Button(
            action: { tapHandler?() },
            label: {
                HStack(spacing: 0) {
                    if let item { Text(item.rawValue) }
                    Spacer()
                    content()
                    if showDisclosureIndicator { emptyNavigationLink }
                }
            }
        )
        .tint(.black)
    }
    
    private let emptyNavigationLink: some View = NavigationLink.empty
        .frame(width: 17, height: 0)
        .frame(alignment: .leading)
}

#Preview {
    ContentView()
}
