import Flutter
import UIKit

/// Full-screen UIViewController that shows a native profile.
///
/// Presented by Flutter through a MethodChannel — not embedded as a PlatformView.
final class ProfileViewController: UIViewController {
  private let avatarView = UIImageView()

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor(red: 0.94, green: 0.99, blue: 0.98, alpha: 1)

    let titleLabel = UILabel()
    titleLabel.text = "Native iOS profile"
    titleLabel.font = .boldSystemFont(ofSize: 14)
    titleLabel.textColor = UIColor(red: 0.06, green: 0.46, blue: 0.43, alpha: 1)
    titleLabel.textAlignment = .center

    avatarView.translatesAutoresizingMaskIntoConstraints = false
    avatarView.backgroundColor = UIColor(red: 0.70, green: 0.87, blue: 0.86, alpha: 1)
    avatarView.contentMode = .scaleAspectFill
    avatarView.clipsToBounds = true
    avatarView.layer.cornerRadius = 60
    NSLayoutConstraint.activate([
      avatarView.widthAnchor.constraint(equalToConstant: 120),
      avatarView.heightAnchor.constraint(equalToConstant: 120),
    ])

    let nameLabel = UILabel()
    nameLabel.text = "Alex Rivera"
    nameLabel.font = .boldSystemFont(ofSize: 24)
    nameLabel.textColor = UIColor(red: 0.07, green: 0.31, blue: 0.29, alpha: 1)
    nameLabel.textAlignment = .center

    let ageLabel = UILabel()
    ageLabel.text = "Age: 29"
    ageLabel.font = .systemFont(ofSize: 16)
    ageLabel.textColor = UIColor(red: 0.06, green: 0.46, blue: 0.43, alpha: 1)
    ageLabel.textAlignment = .center

    let summaryLabel = UILabel()
    summaryLabel.text =
      "Mobile engineer who builds Flutter samples that call " +
      "Kotlin Activities and Swift view controllers."
    summaryLabel.font = .systemFont(ofSize: 15)
    summaryLabel.textColor = UIColor(red: 0.07, green: 0.37, blue: 0.35, alpha: 1)
    summaryLabel.textAlignment = .center
    summaryLabel.numberOfLines = 0

    let closeButton = UIButton(type: .system)
    closeButton.setTitle("Close", for: .normal)
    closeButton.setTitleColor(.white, for: .normal)
    closeButton.backgroundColor = UIColor(red: 0.06, green: 0.46, blue: 0.43, alpha: 1)
    closeButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 28, bottom: 12, right: 28)
    closeButton.layer.cornerRadius = 8
    closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)

    let stack = UIStackView(arrangedSubviews: [
      titleLabel,
      avatarView,
      nameLabel,
      ageLabel,
      summaryLabel,
      closeButton,
    ])
    stack.axis = .vertical
    stack.alignment = .center
    stack.spacing = 16
    stack.translatesAutoresizingMaskIntoConstraints = false

    let scrollView = UIScrollView()
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    scrollView.addSubview(stack)
    view.addSubview(scrollView)

    NSLayoutConstraint.activate([
      scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      stack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 32),
      stack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 24),
      stack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -24),
      stack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -32),
    ])

    loadProfileImage()
  }

  @objc private func closeTapped() {
    dismiss(animated: true)
  }

  private func loadProfileImage() {
    guard let url = URL(string: "https://picsum.photos/240") else {
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
}
