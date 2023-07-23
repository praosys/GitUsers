import UIKit

class DetailsViewController: UIViewController {

    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var usernameLabel: UILabel!
    @IBOutlet weak private var githubLabel: UILabel!
    @IBOutlet weak private var detailsStackView: UIStackView!

    var gitUser: GitUser?
    
    private var activityIndicator = UIActivityIndicatorView()
    private var viewModel: GitUserViewModel?

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let gitUser = gitUser else { return }
        print(gitUser)
        viewModel = GitUserViewModel(gitUser: gitUser)
        loadDetails()
    }

    private func loadDetails() {
        
        viewModel?.getUserImage(completion: { image in
            if let image = image {
                DispatchQueue.main.async { [weak self] in
                    self?.imageView.image = image
                }
            }
        })
        
        usernameLabel.text = gitUser?.login
        githubLabel.text = "GitHub:\n\(gitUser?.html_url ?? "")"
        
        detailsStackView.addArrangedSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        viewModel?.getAllDataLabels(completion: { [weak self] allLabelTexts in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                self?.activityIndicator.removeFromSuperview()
                allLabelTexts.forEach { labelText in
                    if let label = self?.makeLabel(text: labelText) {
                        self?.detailsStackView.addArrangedSubview(label)
                    }
                }
            }
        })
    }
        
    private func makeLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.numberOfLines = 0

        return label
    }
}

