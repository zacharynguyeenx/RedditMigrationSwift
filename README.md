# RedditMigrationSwift

## Requirements

* Xcode 13.2
* macOS 12

## Steps

1. Rename `Config.swift.rename` in `Sources/RedditMigration` to `Config.swift`
1. Go to [https://www.reddit.com/prefs/apps](https://www.reddit.com/prefs/apps)
    1. Create a new app
    1. Enter any name for the app
    1. Select `script` app type
    1. Enter any redirect URI
    1. Add username of source and destination accounts as developer of the app
    1. The client ID is below the app name
1. Update `Config.swift` with user and client credentials
1. Run `swift build`
1. Run `swift run`

## Notes

- The app will clear all existing saved posts in the destination account

## Tech

- [Swift Package Manager](https://www.swift.org/package-manager/)
- [Concurrency](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html)
