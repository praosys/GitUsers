//
//  NetworkService.swift
//  GitUsers
//
//  Created by Prasanna Rao.
//

import Foundation

enum NetworkError: Error {
    case noData, invalidURL, error(String)
}

protocol NetworkServiceProtocol {
    func get<Object: Codable>(
        urlString: String,
        resultType: Object.Type,
        completion: @escaping (Result<Object, Error>) -> Void
    ) -> URLSessionDataTaskProtocol
    
    func get(
        urlString: String,
        completion: @escaping (Result<Data, NetworkError>) -> Void
    ) -> URLSessionDataTaskProtocol
}

final class NetworkService: NetworkServiceProtocol {
    
    private let session: URLSessionProtocol
    
    init() {
        let config = URLSessionConfiguration.default
        self.session = URLSession(configuration: config)
    }
    
    init(session: URLSessionProtocol = URLSession.shared) {
        self.session = session
    }

    @discardableResult
    func get<Object: Codable>(urlString: String, resultType: Object.Type = Object.self, completion: @escaping (Result<Object, Error>) -> Void) -> URLSessionDataTaskProtocol {
        
        get(urlString: urlString) { data in
            let result: Result<Object, Error>
            defer { completion(result) }

            switch data {
            case .success(let data):
                do {
                    let object = try JSONDecoder().decode(Object.self, from: data)
                    result = .success(object)
                } catch {
                    result = .failure(error)
                }
            case .failure(let error):
                result = .failure(error)
            }
        }
    }

    @discardableResult
    func get(urlString: String, completion: @escaping (Result<Data, NetworkError>) -> Void) -> URLSessionDataTaskProtocol {
        
         guard let url = URL(string: urlString) else {
            let returnTask: URLSessionDataTaskProtocol = session.dataTask(with: URL(string: "www.google.com")!) {_,_,_ in }
            let result: Result<Data, NetworkError>
            result = .failure(NetworkError.invalidURL)
            completion(result)
            return returnTask
        }
        
        let request = URLRequest(url: url)
         
        let task: URLSessionDataTaskProtocol = session.dataTask(with: request) { data, _, error in
            
            let result: Result<Data, NetworkError>
            defer { completion(result) }

            if let error = error {
                result = .failure(NetworkError.error(error.localizedDescription))
                return
            }

            guard let data else {
                result = .failure(NetworkError.noData)
                return
            }

            result = .success(data)
        }

        task.resume()
        return task
    }
}
