//
//  MockURLProtocol.swift
//  GitUsers
//
//  Created by Prasanna Rao.
//

import XCTest
@testable import GitUsers

class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool {
        // Handle all types of requests
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        // Required to be implemented here. Just return what is passed
        return request
    }

    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            XCTFail("Received unexpected request with no handler set")
            return
        }
        do {
            let (response, data) = try handler(request)
            // Return specified mock response
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            // We have mocked data specified so return it.
            client?.urlProtocol(self, didLoad: data)
            // We are done after sending mock
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            // We return mocked error
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {
        // Required to be implemented but nothing to send here
    }
}
