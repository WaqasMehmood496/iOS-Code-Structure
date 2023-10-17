//
//  Publishers+Keyboard.swift
//  Evexia
//
//  Created by Oleksandr Kovalov on 08.09.2021.
//

import Combine
import UIKit

extension Publishers {
    static var keyboardHeightPublisher: AnyPublisher<(CGFloat, Double), Never> {
        let willShow = NotificationCenter.default.publisher(for: UIApplication.keyboardWillShowNotification)
            .map { notification -> (CGFloat, Double) in
                let height = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height ?? 0
                let durationKey = UIResponder.keyboardAnimationDurationUserInfoKey
                let duration = notification.userInfo![durationKey] as! Double
                return (height, duration)
            }
        
        let willHide = NotificationCenter.default.publisher(for: UIApplication.keyboardWillHideNotification)
            .map { notification -> (CGFloat, Double) in
                let durationKey = UIResponder.keyboardAnimationDurationUserInfoKey
                let duration = notification.userInfo![durationKey] as! Double
                return (CGFloat(0), duration)
            }
        
        return Merge(willShow, willHide)
            .eraseToAnyPublisher()
    }
}
