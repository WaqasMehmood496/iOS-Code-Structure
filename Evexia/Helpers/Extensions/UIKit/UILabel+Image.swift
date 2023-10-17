//
//  UILabel+Image.swift
//  Evexia
//
//  Created by Oleksandr Kovalov on 30.08.2021.
//

import UIKit

extension UILabel {
    func addImageToTrailing(image: UIImage?) {
        guard let image = image, let text = self.text else { return }
        
        let attachment = NSTextAttachment()
        attachment.image = image
        attachment.bounds = CGRect(x: 0, y: -10.0, width: attachment.image!.size.width, height: attachment.image!.size.height)
        
        let attachmentString = NSAttributedString(attachment: attachment)
        let string = NSMutableAttributedString(string: text, attributes: [:])
        
        string.append(attachmentString)
        self.attributedText = string
    }
}
