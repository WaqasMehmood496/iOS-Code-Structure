//
//  ReplacePushTransition.swift
//  Evexia
//
//  Created by  Artem Klimov on 02.07.2021.
//

import Foundation
import UIKit

class ReplacingPushTransition: NSObject {

    var animator: AnimatorProtocol?
    var isAnimated: Bool = true
    var completionHandler: (() -> Void)?

    weak var viewController: UIViewController?

    init(animator: AnimatorProtocol? = nil, isAnimated: Bool = true) {
        self.animator = animator
        self.isAnimated = isAnimated
    }
    
}

// MARK: - Transition

extension ReplacingPushTransition: Transition {

    func open(_ targetViewController: UIViewController) {
        self.viewController?.navigationController?.delegate = self
        // it's replacing transition - so we need to get previos last, remove it and after it replace navigation stack with new list of viewcontroller without it
        guard var viewControllers = self.viewController?.navigationController?.viewControllers else {
            self.viewController?.navigationController?.pushViewController(targetViewController, animated: isAnimated)
            return
        }
        _ = viewControllers.popLast()

        // Push targetViewController
        viewControllers.append(targetViewController)
        self.viewController?.navigationController?.setViewControllers(viewControllers, animated: true)
    }

    func close(_ viewController: UIViewController) {
        viewController.navigationController?.popViewController(animated: isAnimated)
    }
}

// MARK: - UINavigationControllerDelegate

extension ReplacingPushTransition: UINavigationControllerDelegate {

    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        completionHandler?()
    }

    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationController.Operation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch operation {
        case .pop:
            return nil
        default:
            guard let animator = animator else {
                return nil
            }
            if operation == .push {
                animator.isPresenting = true
                return animator
            } else {
                animator.isPresenting = false
                return animator
            }
        }
        
    }
}
