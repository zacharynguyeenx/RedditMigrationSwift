import RMCore

struct MigrateSavedPostFeature {
    let useCase: MigrateSavedPostsUseCase
    
    init(
        config: Config,
        useCase: (Config, @escaping (MigrateSavedPostsUseCase.Progress) -> Void) -> MigrateSavedPostsUseCase = MigrateSavedPostsUseCase.init
    ) {
        self.useCase = useCase(config) {
            switch $0 {
            case .willGetSourceAccessToken:
                print("Authenticating source account")
            case .willGetDestinationAccessToken:
                print("Authenticating destination account")
            case .willGetDestinationSavedPosts:
                print("Getting existing saved posts in destination account")
            case .willUnsaveDestinationSavedPosts(let count):
                print("Clearing \(count) existing saved posts in destination account")
            case .didUnsaveDestinationSavedPost(let index, let count):
                print("Unsaved post \(index + 1)/\(count)")
            case .willGetSourceSavedPosts:
                print("Getting saved posts in source account")
            case .willSavePosts(let count):
                print("Saving \(count) posts to destination account")
            case .didSavePost(let index, let count):
                print("Saved post \(index + 1)/\(count)")
            }
        }
    }
    
    func start() async {
        do {
            try await useCase.migrateSavedPosts()
        } catch {
            print("An error occurred: \(error)")
        }
    }
}
