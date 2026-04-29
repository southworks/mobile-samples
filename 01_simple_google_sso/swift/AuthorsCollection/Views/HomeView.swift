import SwiftUI

struct HomeView: View {
    let user: AuthUser
    let isSigningOut: Bool
    let errorMessage: String?
    let onSignOutTap: () -> Void

    var body: some View {
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

                if let errorMessage, !errorMessage.isEmpty {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                }

                Button(action: onSignOutTap) {
                    HStack(spacing: 10) {
                        if isSigningOut {
                            ProgressView()
                        } else {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                        }

                        Text(isSigningOut ? "Cerrando sesion..." : "Cerrar sesion")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .foregroundStyle(.white)
                .background(Color.appPrimary)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .disabled(isSigningOut)
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
            .navigationTitle("Authors Collection")
            .navigationBarTitleDisplayMode(.inline)
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
