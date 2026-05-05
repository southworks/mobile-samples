import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: AuthViewModel

    var body: some View {
        if viewModel.isInitializing {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.appBackground.ignoresSafeArea())
        } else if let user = viewModel.user {
            NavigationStack {
                VStack(spacing: 20) {
                    ProfileAvatar(photoURL: user.photoURL)

                    Text(user.displayName)
                        .font(.title2.weight(.semibold))
                        .multilineTextAlignment(.center)

                    Text(user.email)
                        .font(.body)
                        .foregroundStyle(.appTextSecondary)
                        .multilineTextAlignment(.center)

                    if let errorMessage = viewModel.errorMessage, !errorMessage.isEmpty {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                    }

                    Button(action: viewModel.signOut) {
                        HStack(spacing: 10) {
                            if viewModel.isSigningOut {
                                ProgressView()
                            } else {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                            }

                            Text(viewModel.isSigningOut ? "Cerrando sesion..." : "Cerrar sesion")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .foregroundStyle(.white)
                    .background(Color.appPrimary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .disabled(viewModel.isSigningOut)
                }
                .padding(24)
                .frame(maxWidth: 360)
                .background(Color.appCardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.appBorder, lineWidth: 1)
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.appBackground.ignoresSafeArea())
                .navigationTitle("Authors Collection")
                .navigationBarTitleDisplayMode(.inline)
            }
        } else {
            VStack(spacing: 24) {
                Image(systemName: "person.crop.circle.badge.checkmark")
                    .font(.system(size: 54))
                    .foregroundStyle(.appPrimary)

                Text("Authors Collection")
                    .font(.title.weight(.semibold))

                Text("Inicia sesion con Google para ver la foto de perfil y el mail del usuario autenticado.")
                    .font(.body)
                    .foregroundStyle(.appTextSecondary)
                    .multilineTextAlignment(.center)

                if let errorMessage = viewModel.errorMessage, !errorMessage.isEmpty {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                }

                Button(action: viewModel.signInWithGoogle) {
                    HStack(spacing: 10) {
                        if viewModel.isSigningIn {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "globe")
                        }

                        Text(viewModel.isSigningIn ? "Autenticando..." : "Continuar con Google")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .foregroundStyle(.white)
                .background(Color.appPrimary)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .disabled(viewModel.isSigningIn)
            }
            .padding(24)
            .frame(maxWidth: 360)
            .background(Color.appCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.appBorder, lineWidth: 1)
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.appBackground.ignoresSafeArea())
        }
    }
}

private struct ProfileAvatar: View {
    let photoURL: String?

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.appBackground)
                .frame(width: 76, height: 76)

            if let photoURL, let url = URL(string: photoURL), !photoURL.isEmpty {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    default:
                        Image(systemName: "person.fill")
                            .font(.system(size: 34, weight: .semibold))
                            .foregroundStyle(.appPrimary)
                    }
                }
                .frame(width: 76, height: 76)
                .clipShape(Circle())
            } else {
                Image(systemName: "person.fill")
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundStyle(.appPrimary)
            }
        }
    }
}

extension Color {
    static let appBackground = Color(red: 0.965, green: 0.973, blue: 0.984)
    static let appPrimary = Color(red: 0.059, green: 0.463, blue: 0.431)
    static let appTextSecondary = Color(red: 0.376, green: 0.424, blue: 0.478)
    static let appCardBackground = Color.white
    static let appBorder = Color.black.opacity(0.05)
}

#Preview {
    ContentView(viewModel: AuthViewModel())
}
