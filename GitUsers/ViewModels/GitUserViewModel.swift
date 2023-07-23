
import Foundation
import UIKit

protocol GitUserViewModelImageProtocol {
    func getUserImage(urlString: String?, completion: @escaping (UIImage?) -> ())
}

protocol GitUserViewModelUsersProtocol {
    func fetchAllGitUsers(completion: @escaping ([GitUser]) -> ())
    func getAllDataLabels(completion: @escaping ([String]) -> ())
}

struct GitUserViewModel {
    let gitUser: GitUser?
    var session: URLSessionProtocol? = URLSession.shared
    var networkService: NetworkServiceProtocol? = NetworkService()
}

extension GitUserViewModel: GitUserViewModelImageProtocol {
    func getUserImage(urlString: String? = nil, completion: @escaping (UIImage?) -> () ) {
        guard let avatar_url = urlString ?? gitUser?.avatar_url,
              let url = URL(string: avatar_url) else {
            completion(nil)
            return
        }
        
        GitUsersDownloader.shared.downloadGitUsersImageData(for: url) { result in
            switch result {
            case .success(let data):
                guard let image = UIImage(data: data) else { completion(nil); return}
                completion(image)
            case .failure:
                completion(nil)
            }
        }
    }
}

extension GitUserViewModel: GitUserViewModelUsersProtocol {
    func fetchAllGitUsers(completion: @escaping ([GitUser]) -> ()) {
        _ = networkService?.get(urlString: .allGithubUsersEndpoint, resultType: [GitUser].self) {result in
            switch result {
            case .failure:
                completion([])
            case .success(let users):
               completion(users)
            }
        }
    }
    
    func getAllDataLabels(completion: @escaping ([String]) -> ()) {
        fetchAllData { rtnDict in
            guard rtnDict.count > 0 else {
                completion([])
                return }
            
            // Always want label in same order. Sorting dictionary key in Asc order ie. 1, 2, 3, 4
            let sortedArray = rtnDict.sorted(by: {$0.key < $1.key })

            var allLabelTexts:[String] = []
            sortedArray.forEach { eachDict in
                if let labelText = rtnDict[eachDict.key] {
                    allLabelTexts.append(labelText)
                }
            }
            completion(allLabelTexts)
        }
    }
    
    private func fetchAllData(completion: @escaping ([Int: String]) -> ()) {
        var detailLabelsTexts = [Int: String]()
        let downloadQueue = DispatchQueue(label: "com.githubuser.urlDownloader", attributes: .concurrent)
        let downloadGroup = DispatchGroup()
        
        if let followers_url = gitUser?.followers_url {
            downloadGroup.enter()
            _ = networkService?.get(urlString: followers_url, resultType: [GitUser].self) { result in
                downloadQueue.async {
                    switch result {
                    case .success(let followers):
                        detailLabelsTexts[1] = "Followers: \(followers.count)"
                    case .failure:
                        detailLabelsTexts[1] = "Followers: N/A"
                  }
                    downloadGroup.leave()
                }
            }
        }

        if let following_url = gitUser?.following_url {
            downloadGroup.enter()
            _ = networkService?.get(urlString: following_url, resultType: [GitUser].self) { result in
                downloadQueue.async {
                    switch result {
                    case .success(let followers):
                        detailLabelsTexts[2] = "Following: \(followers.count)"
                    case .failure:
                        detailLabelsTexts[2] = "Following: N/A"
                    }
                    downloadGroup.leave()
                }
            }
        }

        if let repos_url = gitUser?.repos_url {
            downloadGroup.enter()
            _ = networkService?.get(urlString: repos_url, resultType: [Repo].self) { result in
                downloadQueue.async {
                    switch result {
                    case .success(let repositories):
                        detailLabelsTexts[3] = "Repositories count: \(repositories.count)"
                    case .failure:
                        detailLabelsTexts[3] = "Repositories count: N/A"
                    }
                    downloadGroup.leave()
                }
            }
       }

        if let gists_url = gitUser?.gists_url {
            downloadGroup.enter()
            _ = networkService?.get(urlString: gists_url, resultType: [Gist].self) { result in
                downloadQueue.async {
                    switch result {
                    case .success(let gists):
                        detailLabelsTexts[4] = "Gists count: \(gists.count)"
                    case .failure:
                        detailLabelsTexts[4] = "Gists count: N/A"
                    }
                    downloadGroup.leave()
                }
            }
        }

        downloadGroup.notify(queue: .global()) {
            completion(detailLabelsTexts)
        }
    }

}
