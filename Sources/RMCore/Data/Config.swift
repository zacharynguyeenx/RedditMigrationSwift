public struct Config {
    let sourceUser: UserCredentials
    let destinationUser: UserCredentials
    let clientCredentials: ClientCredentials
    
    public init(sourceUser: UserCredentials, destinationUser: UserCredentials, clientCredentials: ClientCredentials) {
        self.sourceUser = sourceUser
        self.destinationUser = destinationUser
        self.clientCredentials = clientCredentials
    }
}
