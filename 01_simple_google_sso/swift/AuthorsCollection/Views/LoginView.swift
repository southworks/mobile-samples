import SwiftUI

struct LoginView: View {
    let isSigningIn: Bool
    let errorMessage: String?
    let onSignInTap: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "person.crop.circle.badge.checkmark")
                .font(.system(size: 54))
                .foregroundStyle(.appPrimary)

            Text("Authors Collection")
                .font(.title.weight(.semibold))

            Text("Inicia sesion con Google para ver los datos del usuario autenticado.")
                .font(.body)
                .foregroundStyle(.appTextSecondary)
                .multilineTextAlignment(.center)

            if let errorMessage, !errorMessage.isEmpty {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }

            Button(action: onSignInTap) {
                HStack(spacing: 10) {
                    if isSigningIn {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: "globe")
                    }

                    Text(isSigningIn ? "Autenticando..." : "Continuar con Google")
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .foregroundStyle(.white)
            .background(Color.appPrimary)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .disabled(isSigningIn)
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
