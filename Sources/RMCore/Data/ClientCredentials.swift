public struct ClientCredentials {
    let identifier: String
    let secret: String
    
    public init(identifier: String, secret: String) {
        self.identifier = identifier
        self.secret = secret
    }
}
