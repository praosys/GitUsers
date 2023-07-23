import XCTest

@testable import GitUsers

final class Test1: XCTestCase {
    
    var sut: GitUsersDownloader!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()
        sut = GitUsersDownloader.shared
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
        try super.tearDownWithError()
    }
        
    func test_getCachedImageData() throws {
        // given
        let mockData = Data("GithubUsers_PPRao".utf8)
        
        // when
        let urlString = "https://avatars.githubusercontent.com/u/1?v=4"
        sut.imageDataCache.setObject(mockData as NSData, forKey: urlString as NSString)

        // then
        let cachedImageData = sut.getCachedImageData(for: urlString)
        XCTAssertNotNil(cachedImageData)
    }

    func test_downloadGitUsersImageData_getCachedImageData() throws {
        // given
        let mockData = Data("GithubUsers_PPRao".utf8)
        let urlString = "https://avatars.githubusercontent.com/u/1?v=4"
        
        sut.imageDataCache.setObject(mockData as NSData, forKey: urlString as NSString)

        let cachedMockData = sut.getCachedImageData(for: urlString)
        XCTAssertNotNil(cachedMockData)
        
        guard let url = URL(string: urlString) else {
            XCTFail("Failed to convert urlstring to URL")
            return
        }

        let sessionConfiguration = URLSessionConfiguration.ephemeral
        sessionConfiguration.protocolClasses = [MockURLProtocol.self]
        sut.session = URLSession(configuration: sessionConfiguration)
        
        let exp = expectation(description: "Loading URL")
        
        // when
        sut.downloadGitUsersImageData(for: url) { result in
            exp.fulfill()
        }
        wait(for: [exp], timeout: 10)
    }

    func test_downloadGitUsersImageData() throws {
        // given
        let mockValue = "GithubUsers_PPRao"
        let mockData = Data(mockValue.utf8)
        let imageUrlString = "https://avatars.githubusercontent.com/u/1?v=4"
        
        let sessionConfiguration = URLSessionConfiguration.ephemeral
        sessionConfiguration.protocolClasses = [MockURLProtocol.self]
        let mockSession = URLSession(configuration: sessionConfiguration)
        sut.session = mockSession
        
        // Return data in mock request handler
        MockURLProtocol.requestHandler = { request in
            return (HTTPURLResponse(), mockData)
        }
        
        guard let url = URL(string: imageUrlString) else {
            XCTFail("Failed to convert urlstring to URL")
            return
        }

        // Set expectation to test async code.
        let exp = expectation(description: "response")
        
        // when
        sut.downloadGitUsersImageData(for: url) { result in
            switch result {
            case .success(let data):
                XCTAssertNotNil(data, "Data received nil")
                let returnedValue = String(decoding: data, as: UTF8.self)
                XCTAssertEqual(returnedValue, mockValue, "Value mismatched")
                exp.fulfill()
            case .failure(let error):
                XCTAssertNotNil(error, "Error in receiving data")
                exp.fulfill()
            }
        }
        wait(for: [exp], timeout: 10)
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
}
