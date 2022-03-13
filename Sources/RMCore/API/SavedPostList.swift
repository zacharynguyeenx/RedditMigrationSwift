import Foundation

struct SavedPostList {
    let accessToken: String
    let username: String
    let session: URLSession
    
    init(accessToken: String, username: String, session: URLSession = .shared) {
        self.accessToken = accessToken
        self.username = username
        self.session = session
    }
    
    struct Request {
        let accessToken: String
        let username: String
        let after: String?
        let limit = 100
        
        var authorization: String {
            "Bearer \(accessToken)"
        }
        
        var query: String {
            [
                after.map { "after=\($0)" },
                "limit=\(limit)"
            ]
                .compactMap { $0 }
                .joined(separator: "&")
        }
        
        var request: URLRequest {
            let url = "https://oauth.reddit.com/user/\(username)/saved?\(query)"
            var request = URLRequest(url: URL(string: url)!)
            request.setValue(authorization, forHTTPHeaderField: "Authorization")
            return request
        }
    }
    
    struct Response: Decodable {
        let data: Data
        
        struct Data: Decodable {
            let after: String?
            let children: [Child]
            
            struct Child: Decodable {
                let data: Data
                
                struct Data: Decodable {
                    let name: String
                }
            }
        }
    }
    
    private func getSavedPosts(after: String?) async throws -> [String] {
        let (data, networkResponse) = try await session.data(for: Request(accessToken: accessToken, username: username, after: after).request)
        
        guard let networkResponse = networkResponse as? HTTPURLResponse, networkResponse.statusCode >= 200, networkResponse.statusCode < 299 else {
            throw RMError.network(String(data: data, encoding: .utf8))
        }
        
        let response = try JSONDecoder().decode(Response.self, from: data)
        let names = response.data.children.map { $0.data.name }
        
        if let after = response.data.after {
            return try await names + getSavedPosts(after: after)
        } else {
            return names
        }
    }
    
    func getAllSavedPosts() async throws -> [String] {
        try await getSavedPosts(after: nil)
    }
}
