import UIKit

class ListViewController: UICollectionViewController {

    private var viewModel: GitUserViewModel?
    private var githubUsers = [GitUser]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewModel = GitUserViewModel(gitUser: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getAllUsers()
    }
    
    func getAllUsers() {
        viewModel?.fetchAllGitUsers { [weak self] allGithubUsers in
            self?.githubUsers = allGithubUsers
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
        }
    }
}

extension ListViewController {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return githubUsers.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GitUsersCell.getCellIdentifier(), for: indexPath) as! GitUsersCell
        cell.viewModel = GitUsersCellViewModel(githubUser: githubUsers[indexPath.row])
        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let cell = sender as? GitUsersCell, let githubUser = cell.viewModel?.githubUser else { return }
        guard let profileViewController = segue.destination as? DetailsViewController else { return }
        profileViewController.gitUser = githubUser
    }
}

extension ListViewController: UICollectionViewDelegateFlowLayout {
    private var insets: UIEdgeInsets { UIEdgeInsets(top: 10.0, left: 20.0, bottom: 10.0, right: 20.0) }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: view.frame.width - 2 * insets.left, height: 100)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return insets
    }
}
