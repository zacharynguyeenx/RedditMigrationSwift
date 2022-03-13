import Foundation

struct UnsavePost {
    let accessToken: String
    
    struct Request {
        let accessToken: String
        let postID: String
        
        var authorization: String {
            "Bearer \(accessToken)"
        }
        
        var httpBody: Data {
            let body = "id=\(postID)"
            return body.data(using: .utf8)!
        }
        
        var request: URLRequest {
            var request = URLRequest(url: URL(string: "https://oauth.reddit.com/api/unsave")!)
            request.httpMethod = "POST"
            request.setValue(authorization, forHTTPHeaderField: "Authorization")
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.httpBody = httpBody
            return request
        }
    }
    
    func unsavePost(_ postID: String) async throws {
        let (data, networkResponse) = try await URLSession.shared.data(for: Request(accessToken: accessToken, postID: postID).request)
        guard let networkResponse = networkResponse as? HTTPURLResponse, networkResponse.statusCode >= 200, networkResponse.statusCode < 299 else {
            throw RMError.network(String(data: data, encoding: .utf8))
        }
    }
    
    func unsavePosts(_ postIDs: [String], progress: (Int, Int) -> Void) async throws {
        for (index, postID) in postIDs.enumerated() {
            try await unsavePost(postID)
            progress(index, postIDs.count)
        }
    }
}
