//
//  ModalTransition.swift
//  Evexia
//
//  Created by  Artem Klimov on 22.06.2021.
//

import UIKit

class ModalTransition: NSObject {

    var animator: AnimatorProtocol?
    var isAnimated: Bool = true

    var modalTransitionStyle: UIModalTransitionStyle
    var modalPresentationStyle: UIModalPresentationStyle

    var completionHandler: (() -> Void)?

    weak var viewController: UIViewController?

    init(animator: AnimatorProtocol? = nil,
         isAnimated: Bool = true,
         modalTransitionStyle: UIModalTransitionStyle = .coverVertical,
         modalPresentationStyle: UIModalPresentationStyle = .overCurrentContext) {
        self.animator = animator
        self.isAnimated = isAnimated
        self.modalTransitionStyle = modalTransitionStyle
        self.modalPresentationStyle = modalPresentationStyle
    }
}

// MARK: - Transition

extension ModalTransition: Transition {

    func open(_ viewController: UIViewController) {
        viewController.transitioningDelegate = self
        viewController.modalTransitionStyle = modalTransitionStyle
        viewController.modalPresentationStyle = modalPresentationStyle

        self.viewController?.present(viewController, animated: isAnimated, completion: completionHandler)
    }

    func close(_ viewController: UIViewController) {
        viewController.dismiss(animated: isAnimated, completion: completionHandler)
    }
}

// MARK: - UIViewControllerTransitioningDelegate

extension ModalTransition: UIViewControllerTransitioningDelegate {

    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let animator = animator else {
            return nil
        }
        animator.isPresenting = true
        return animator
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let animator = animator else {
            return nil
        }
        animator.isPresenting = false
        return animator
    }
}
