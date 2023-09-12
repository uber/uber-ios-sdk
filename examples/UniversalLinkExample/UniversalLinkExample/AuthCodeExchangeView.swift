//
//  Copyright © Uber Technologies, Inc. All rights reserved.
//


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
