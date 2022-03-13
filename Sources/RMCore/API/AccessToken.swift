import Foundation

struct AccessToken {
    let userCredentials: UserCredentials
    let clientCredentials: ClientCredentials
    let session: URLSession
    
    init(userCredentials: UserCredentials, clientCredentials: ClientCredentials, session: URLSession = .shared) {
        self.userCredentials = userCredentials
        self.clientCredentials = clientCredentials
        self.session = session
    }
    
    struct Request {
        let userCredentials: UserCredentials
        let clientCredentials: ClientCredentials
        
        var authorization: String {
            let loginString = "\(clientCredentials.identifier):\(clientCredentials.secret)".data(using: .utf8)!.base64EncodedString()
            return "Basic \(loginString)"
        }
        
        var username: String {
            userCredentials.username.formURLEncodedString
        }
        
        var password: String {
            userCredentials.password.formURLEncodedString
        }
        
        var httpBody: Data {
            let body = "grant_type=password&username=\(username)&password=\(password)"
            return body.data(using: .utf8)!
        }
        
        var request: URLRequest {
            var request = URLRequest(url: URL(string: "https://www.reddit.com/api/v1/access_token")!)
            request.httpMethod = "POST"
            request.setValue(authorization, forHTTPHeaderField: "Authorization")
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.httpBody = httpBody
            
            return request
        }
    }
    
    struct Response: Decodable {
        let accessToken: String
        
        enum CodingKeys: String, CodingKey {
            case accessToken = "access_token"
        }
    }
    
    func getAccessToken() async throws -> String {
        let request = Request(userCredentials: userCredentials, clientCredentials: clientCredentials)
        let (data, networkResponse) = try await session.data(for: request.request)
        
        guard let networkResponse = networkResponse as? HTTPURLResponse, networkResponse.statusCode >= 200, networkResponse.statusCode < 299 else {
            throw RMError.network(String(data: data, encoding: .utf8))
        }
        
        do {
            let response = try JSONDecoder().decode(Response.self, from: data)
            return response.accessToken
        } catch {
            throw RMError.decoding(String(data: data, encoding: .utf8))
        }
    }
}

private extension String {
    // https://stackoverflow.com/a/58919912
    var formURLEncodedString: String {
        var characterSet = CharacterSet.alphanumerics
        characterSet.insert(charactersIn: "-._* ")
        return addingPercentEncoding(withAllowedCharacters: characterSet)!
            .replacingOccurrences(of: " ", with: "+")
    }
}
