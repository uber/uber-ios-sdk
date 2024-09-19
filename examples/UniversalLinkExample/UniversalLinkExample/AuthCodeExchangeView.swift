//
//  AuthCodeExchangeView.swift
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

struct AuthCodeExchangeView: View {
    
    @EnvironmentObject var authUtility: AuthUtility

    @State var authTokenResponse: String = "(Request Access Token to get response)"
    
    let authCode: String
        
    init(authCode: String) {
        self.authCode = authCode
    }
    
    var body: some View {
        VStack {
            
            Form {
                Section(
                    content: { },
                    footer: { Text(description) }
                )
                Section(
                    content: { Text(authCode) },
                    header: { Text("Authorization Code") },
                    footer: { Text("The authorization code returned in the /authorize response") }
                )

                Section(
                    content: { Text(authUtility.codeVerifier) },
                    header: { Text("Code Verifier") },
                    footer: { Text("The UUID that will be sent to the /oauth/v2/token endpoint to verify the original client is exchanging the auth code") }
                )
                
                Section(
                    content: { Text(authTokenResponse) },
                    header: { Text("Access Token") },
                    footer: { Text("The response from the /oauth/v2/token request") }
                )
            }
                                    
            Spacer()
            
            Button("Request Access Token") {
                Task { await makeTokenRequest() }
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
        .navigationTitle("Exchange Auth Code")
    }
    
    private func makeTokenRequest() async {
        let token = await authUtility.getAuthToken(withAuthCode: authCode)
        authTokenResponse = token
    }
    
    private let description = """
Once you have recieved an authorization code back from the /authorize endpoint, you may exchange this code for a valid access token that can be used to authenticate with Uber's backend services.

To do this, you must make a request to the /oauth/v2/token endpoint and supply the previously generate code_verifier that corresponds with the code_challenge passed into the original /authorize request.
"""
}

struct AuthCodeExchangeView_Previews: PreviewProvider {
    static var previews: some View {
        AuthCodeExchangeView(authCode: "123")
    }
}
