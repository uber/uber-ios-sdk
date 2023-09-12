//
//  Copyright © Uber Technologies, Inc. All rights reserved.
//


import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var authUtility: AuthUtility
    
    @State var path: NavigationPath = .init()
    
    @State var copied: Bool = false
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 0) {
                Form {
                    input(parameter: Parameter.clientID, text: $authUtility.clientId)
                    input(parameter: Parameter.redirectURI, text: $authUtility.redirectURI)
                    input(parameter: Parameter.resposeType, text: $authUtility.responseType)
                    input(parameter: Parameter.codeChallenge, text: $authUtility.codeChallenge)
                    input(parameter: Parameter.codeChallengeMethod, text: $authUtility.codeChallengeMethod)
                }
                
                linkPreview(
                    url: authUtility.url,
                    copied: copied
                )
                
                loginButton
            }
            .onOpenURL { url in
                handleAuthCode(from: url)
            }
            .navigationDestination(for: String.self) { authCode in
                AuthCodeExchangeView(authCode: authCode)
            }
            .navigationTitle("Uber - Universal Link Example")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private var loginButton: some View {
        Button("Login") {
            self.authUtility.openURL()
        }
        .buttonStyle(.borderedProminent)
        .disabled(!authUtility.canSubmit)
    }
    
    private func handleAuthCode(from url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return
        }
        
        // Get authorization code
        guard let code = components.queryItems?.first(where: {
            $0.name == "code"
        })?.value else {
            return
        }
        
        path.append(code)
    }
    
    private func linkPreview(url: URL, copied: Bool) -> some View {
        let text = copied ? "Copied" : url.absoluteString
        
        return VStack {
            Divider()
            ScrollView(.horizontal, showsIndicators: true) {
                Text(text)
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .padding()
                    .onTapGesture {
                        UIPasteboard.general.string = url.absoluteString
                        
                        self.copied = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                            self.copied = false
                        }
                    }
            }
        }
    }
    
    private func input(parameter: Parameter, text: Binding<String>) -> some View {
        Section(
            content: {
                TextField(
                    parameter.title,
                    text: text
                )
                .disabled(!parameter.isEditable)
                .foregroundColor(parameter.isEditable ? .primary : .secondary)
            },
            header: {
                Text(parameter.title)
            },
            footer: {
                Text(parameter.description)
            }
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AuthUtility())
    }
}
