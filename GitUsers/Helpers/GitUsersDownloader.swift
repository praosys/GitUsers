
import UIKit

protocol GitUsersDataDownloaderProtocol {
    var imageDataCache: NSCache<NSString, NSData> { get }
    func getCachedImageData(for urlString: String) -> Data?
    func downloadGitUsersImageData(for imageURL: URL, completion: @escaping (Result<Data, Error>) -> (Void))
}

enum GitUsersDownloaderError: Error {
    case noData
    case notImageData
    case error(Error)
}

class GitUsersDownloader {
    
    static var shared = GitUsersDownloader()
    // Caching data, using NSCache so system can purge the cached data instead of closing the app
    internal var imageDataCache = NSCache<NSString, NSData>()
    var session: URLSessionProtocol = URLSession.shared
    
    private init(imageDataCache: NSCache<NSString, NSData> = NSCache<NSString, NSData>()) {
        self.imageDataCache = imageDataCache
    }
}

extension GitUsersDownloader: GitUsersDataDownloaderProtocol {
    
    func getCachedImageData(for urlString: String) -> Data? {
        guard let imageData = imageDataCache.object(forKey: urlString as NSString) as Data? else { return nil }
        return imageData
    }

    func downloadGitUsersImageData(for imageURL: URL, completion: @escaping (Result<Data, Error>) -> (Void)) {
        
        if let cachedData = getCachedImageData(for: imageURL.absoluteString) {
            completion(.success(cachedData))
            return
        }

        let dataTask: URLSessionDataTaskProtocol = session.dataTask(with: imageURL) { imageData , _ , error in
           if let error {
               completion(.failure(GitUsersDownloaderError.error(error)))
               return
           }

           guard let imageData else {
               completion(.failure(GitUsersDownloaderError.noData))
               return
           }
            
            self.imageDataCache.setObject(imageData as NSData, forKey: imageURL.absoluteString as NSString)
            completion(.success(imageData))
       }
       
         dataTask.resume()
     }
    
}
