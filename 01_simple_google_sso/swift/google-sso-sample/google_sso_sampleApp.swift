import GoogleSignIn
import SwiftUI

@main
struct google_sso_sampleApp: App {
    @StateObject private var viewModel = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}
