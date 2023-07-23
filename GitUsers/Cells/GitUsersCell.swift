
import UIKit

class GitUsersCell: UICollectionViewCell {
    
    @IBOutlet weak private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var loginLabel: UILabel!
    @IBOutlet weak private var githubLabel: UILabel!
    
    static func getCellIdentifier() -> String {
        String(describing: GitUsersCell.self)
    }
    
    var  viewModel: GitUsersCellViewModel? {
        didSet {
            githubUser = viewModel?.githubUser
        }
    }

    private var startActivityIndicator: Bool? {
        get {
            activityIndicator.isAnimating
        }
        set {
            if let startAnimation = newValue, startAnimation {
                activityIndicator.startAnimating()
            } else {
                activityIndicator.stopAnimating()
            }
        }
    }
    private var login: String? {
        get {
            loginLabel.text
        }
        set {
            loginLabel.text = newValue
        }
    }

    private var github: String? {
        get {
            githubLabel.text
        }
        set {
            githubLabel.text = "GitHub: \(newValue ?? "N/A")"
        }
    }

    private var image: UIImage? {
        get {
            imageView.image
        }
        set {
            DispatchQueue.main.async { [weak self] in
                self?.activityIndicator.stopAnimating()
                self?.imageView.image = newValue
            }
        }
    }
    
    private var githubUser: GitUser? {
        didSet {
            login = githubUser?.login
            github = githubUser?.html_url
            activityIndicator.startAnimating()
            viewModel?.getImage(delegate: self){}
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        contentView.backgroundColor = .lightGray.withAlphaComponent(0.2)
        contentView.layer.cornerRadius = 5.0
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        imageView.layer.cornerRadius = imageView.bounds.width / 2
        imageView.clipsToBounds = true
    }
    
    override func prepareForReuse() {
        image = nil
        login = nil
        github = nil
        activityIndicator.startAnimating()
    }
}

extension GitUsersCell: GitUsersCellViewModelDelegate {
    
    func fetchStopped() {
        DispatchQueue.main.async { [weak self] in
            self?.activityIndicator.stopAnimating()
        }
    }
    
    func fetchImage() {
        DispatchQueue.main.async { [weak self] in
            self?.activityIndicator.stopAnimating()
            guard let urlString = self?.viewModel?.githubUser?.avatar_url else { return }
            self?.image = GitUsersDownloader.shared.getCachedImageData(for:  urlString)?.getImage()
        }
    }
}

