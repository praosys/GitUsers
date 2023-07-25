//
//  GitUsersCellViewModel.swift
//  GitUsers
//
//  Created by Prasanna Rao.
//

import Foundation

protocol GitUsersCellViewModelDelegate: AnyObject {
    func fetchImage()
    func fetchStopped()
}

struct GitUsersCellViewModel {
    let githubUser: GitUser?
    
    func getImage(delegate: GitUsersCellViewModelDelegate?, completion: @escaping (() -> ())) {
        guard let urlString = githubUser?.avatar_url,
                let avatar_url = URL(string: urlString)
        else {
            delegate?.fetchStopped()
            completion()
            return
        }
        
        GitUsersDownloader.shared.downloadGitUsersImageData(for: avatar_url) { _ in
            delegate?.fetchImage()
            completion()
            return
        }

    }
}
