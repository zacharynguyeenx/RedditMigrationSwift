public struct MigrateSavedPostsUseCase {
    let sourceUser: UserCredentials
    let destinationUser: UserCredentials
    let clientCredentials: ClientCredentials
    let progress: (Progress) -> Void
    
    public init(config: Config, progress: @escaping (Progress) -> Void) {
        sourceUser = config.sourceUser
        destinationUser = config.destinationUser
        clientCredentials = config.clientCredentials
        self.progress = progress
    }
    
    public enum Progress {
        case willGetSourceAccessToken
        case willGetDestinationAccessToken
        
        case willGetDestinationSavedPosts
        
        case willUnsaveDestinationSavedPosts(count: Int)
        case didUnsaveDestinationSavedPost(index: Int, count: Int)
        
        case willGetSourceSavedPosts
        
        case willSavePosts(count: Int)
        case didSavePost(index: Int, count: Int)
    }
    
    public func migrateSavedPosts() async throws {
        progress(.willGetSourceAccessToken)
        let sourceAccessToken = try await AccessToken(userCredentials: sourceUser, clientCredentials: clientCredentials).getAccessToken()
        
        progress(.willGetDestinationAccessToken)
        let destinationAccessToken = try await AccessToken(userCredentials: destinationUser, clientCredentials: clientCredentials).getAccessToken()

        progress(.willGetDestinationSavedPosts)
        let destinationSavedPosts = try await SavedPostList(
            accessToken: destinationAccessToken,
            username: destinationUser.username
        ).getAllSavedPosts()
        
        progress(.willUnsaveDestinationSavedPosts(count: destinationSavedPosts.count))
        try await UnsavePost(accessToken: destinationAccessToken).unsavePosts(destinationSavedPosts) {
            progress(.didUnsaveDestinationSavedPost(index: $0, count: $1))
        }
        
        progress(.willGetSourceSavedPosts)
        let sourceSavedPosts = try await SavedPostList(
            accessToken: sourceAccessToken,
            username: sourceUser.username
        ).getAllSavedPosts()
        
        progress(.willSavePosts(count: sourceSavedPosts.count))
        try await SavePost(accessToken: destinationAccessToken).savePosts(Array(sourceSavedPosts.reversed())) {
            progress(.didSavePost(index: $0, count: $1))
        }
    }
}
