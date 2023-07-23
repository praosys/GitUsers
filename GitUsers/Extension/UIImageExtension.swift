import UIKit

extension UIImage {
    func getDataImage(for imageData: Data?) -> UIImage? {
        guard let imageData = imageData else { return nil }
        return UIImage(data: imageData)
    }
}

extension Data {
    func getImage() -> UIImage? {
        UIImage(data: self)
    }
}
