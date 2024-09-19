//
//  ContentView.swift
//  UniversalLinkExample
//
//  Copyright © 2024 Uber Technologies, Inc. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.


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
