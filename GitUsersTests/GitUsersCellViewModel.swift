import XCTest

@testable import GitUsers

final class GitUsersCellViewModelTests: XCTestCase {
    
    let gitUser = GitUser(login: "PPrao", id: 101, avatar_url: "https://avatars.githubusercontent.com/u/2?v=4", url: "https://api.github.com/users/PPrao", repos_url: "https://api.github.com/users/PPrao/repos", html_url: "https://github.com/PPrao", followers_url: "https://api.github.com/users/PPrao/followers")
    var sut:GitUsersCellViewModel?
    var gotImage = false
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()
        sut = GitUsersCellViewModel(githubUser: gitUser)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
        try super.tearDownWithError()
    }
    
    func testGetImage() {
        gotImage = false
        
        // Set expectation to test async code.
        let exp = expectation(description: "response")
        
        sut?.getImage(delegate: self) {
            exp.fulfill()
        }
        wait(for: [exp], timeout: 5)
        
        XCTAssertTrue(gotImage, "Expected to get image response")
    }
}

extension GitUsersCellViewModelTests: GitUsersCellViewModelDelegate {
    func fetchImage() {
        gotImage = true
    }
    
    func fetchStopped() {
        gotImage = false
    }
}
