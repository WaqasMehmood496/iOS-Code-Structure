//
//  UIImage+KF.swift
//  Evexia
//
//  Created by Oleksandr Kovalov on 13.09.2021.
//

import Kingfisher

extension UIImageView {
    
    func setImage(url: URL?) {
        self.kf.setImage(with: url, placeholder: UIImage(named: "avatar")) { [weak self] completion in
            switch completion {
            case .failure:
                self?.self.contentMode = .scaleAspectFit
            case .success:
                self?.self.contentMode = .scaleAspectFill
            }
        }
    }
}

public extension KingfisherWrapper where Base: KFCrossPlatformImageView {
    
    @discardableResult
    func setImage(url: String, sizes: CGSize?, resize: Bool = true, placeholder: UIImage? = nil, completionHandler: ((Result<RetrieveImageResult, KingfisherError>) -> Void)? = nil) -> DownloadTask? {
        var options = KingfisherOptionsInfo()
        if let size = sizes {
            if resize {
                let resizeProcessor = ResizingImageProcessor(referenceSize: sizes!, mode: .aspectFit)
                options.append(.processor(resizeProcessor))
            } else {
                let processor = DownsamplingImageProcessor(size: size)
                options.append(.processor(processor))
            }
        }
        options.append(.scaleFactor(UIScreen.main.scale))
       
        let url = URL(string: url)
        return setImage(with: url, placeholder: placeholder, options: options, progressBlock: nil, completionHandler: completionHandler)
    }
}
