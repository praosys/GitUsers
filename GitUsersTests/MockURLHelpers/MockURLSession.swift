//
//  MockURLSession.swift
//  GitUsers
//
//  Created by Prasanna Rao.
//

import Foundation
@testable import GitUsers

class MockURLSessionDataTask: URLSessionDataTaskProtocol {
    
    private let resumeHandler: () -> Void
    
    init(resumeHandler: @escaping () -> Void) {
        self.resumeHandler = resumeHandler
    }
    
    func resume() {
        resumeHandler()
    }
}

class MockURLSession: URLSessionProtocol {
    
    typealias CompletionHandler = (Data?, URLResponse?, Error?) -> Void
    
    var data:Data? = nil
    var error:Error? = nil
    
    func dataTask(with url: URL, completionHandler: @escaping CompletionHandler) -> URLSessionDataTaskProtocol {
        let data = self.data
        let error = self.error
        
        return MockURLSessionDataTask {
            completionHandler(data, nil, error)
        }
    }
    
    func dataTask(with request: URLRequest, completionHandler: @escaping CompletionHandler) -> GitUsers.URLSessionDataTaskProtocol {
        let data = self.data
        let error = self.error
        
        return MockURLSessionDataTask {
            completionHandler(data, nil, error)
        }
    }
    
}
