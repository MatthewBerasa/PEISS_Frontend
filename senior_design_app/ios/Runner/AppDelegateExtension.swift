import Firebase

extension AppDelegate {
    @objc func firebaseSafetyCheck() {
        if FirebaseApp.app() == nil {
            print("Emergency Firebase reinitialization")
            FirebaseApp.configure()
        }
    }
}