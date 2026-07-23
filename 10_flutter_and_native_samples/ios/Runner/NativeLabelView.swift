import Flutter
import UIKit

/// A view built entirely with UIKit (Swift).
///
/// Flutter embeds it, but every pixel here is drawn by native iOS code.
final class NativeLabelView: NSObject, FlutterPlatformView {
  private let container: UIView
  private let avatarView: UIImageView

  init(frame: CGRect) {
    container = UIView(frame: frame)
    avatarView = UIImageView()
    super.init()

    container.backgroundColor = UIColor(red: 0.91, green: 0.96, blue: 0.91, alpha: 1)

    let title = UILabel()
    title.text = "Rendered by iOS"
    title.font = .boldSystemFont(ofSize: 22)
    title.textColor = UIColor(red: 0.11, green: 0.37, blue: 0.13, alpha: 1)

    let subtitle = UILabel()
    subtitle.text = "UIKit views built in Swift"
    subtitle.font = .systemFont(ofSize: 14)

    avatarView.translatesAutoresizingMaskIntoConstraints = false
    avatarView.backgroundColor = UIColor(red: 0.78, green: 0.90, blue: 0.79, alpha: 1)
    avatarView.contentMode = .scaleAspectFill
    avatarView.clipsToBounds = true
    avatarView.layer.cornerRadius = 48
    NSLayoutConstraint.activate([
      avatarView.widthAnchor.constraint(equalToConstant: 96),
      avatarView.heightAnchor.constraint(equalToConstant: 96),
    ])

    let nameLabel = UILabel()
    nameLabel.text = "Alex Rivera"
    nameLabel.font = .systemFont(ofSize: 16, weight: .semibold)
    nameLabel.textColor = UIColor(red: 0.11, green: 0.37, blue: 0.13, alpha: 1)

    let roleLabel = UILabel()
    roleLabel.text = "Native profile card"
    roleLabel.font = .systemFont(ofSize: 13)
    roleLabel.textColor = UIColor(red: 0.22, green: 0.56, blue: 0.24, alpha: 1)

    let stack = UIStackView(arrangedSubviews: [title, subtitle, avatarView, nameLabel, roleLabel])
    stack.axis = .vertical
    stack.alignment = .center
    stack.spacing = 12
    stack.translatesAutoresizingMaskIntoConstraints = false

    container.addSubview(stack)
    NSLayoutConstraint.activate([
      stack.centerXAnchor.constraint(equalTo: container.centerXAnchor),
      stack.centerYAnchor.constraint(equalTo: container.centerYAnchor),
      stack.leadingAnchor.constraint(greaterThanOrEqualTo: container.leadingAnchor, constant: 16),
      stack.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -16),
    ])

    loadProfileImage()
  }

  private func loadProfileImage() {
    guard let url = URL(string: "https://picsum.photos/120") else {
      return
    }

    URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
      guard let data, let image = UIImage(data: data) else {
        return
      }
      DispatchQueue.main.async {
        self?.avatarView.image = image
      }
    }.resume()
  }

  func view() -> UIView {
    container
  }
}
