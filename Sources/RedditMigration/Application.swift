@main
struct Application {
    static func main() async {
        let feature = MigrateSavedPostFeature(config: config)
        await feature.start()
    }
}
