//
//  RootTransition.swift
//  Evexia
//
//  Created by  Artem Klimov on 30.06.2021.
//

import UIKit

extension UIWindow {
    
    func switchRootViewController(_ viewController: UIViewController, removeNavigation: Bool = false, animated: Bool = true, duration: TimeInterval = 0.35, options: UIView.AnimationOptions = .transitionCrossDissolve, completion: (() -> Void)? = nil) {
        
        if !removeNavigation {
            guard animated else {
                self.rootViewController = UINavigationController(rootViewController: viewController)
                return
            }
            
            UIView.transition(with: self, duration: duration, options: options, animations: {
                let oldState = UIView.areAnimationsEnabled
                UIView.setAnimationsEnabled(false)
                self.rootViewController = UINavigationController(rootViewController: viewController)
                UIView.setAnimationsEnabled(oldState)
            }, completion: { _ in
                completion?()
            })
        } else {
            guard animated else {
                self.rootViewController = viewController
                return
            }
            
            UIView.transition(with: self, duration: duration, options: options, animations: {
                let oldState = UIView.areAnimationsEnabled
                UIView.setAnimationsEnabled(false)
                self.rootViewController = viewController
                UIView.setAnimationsEnabled(oldState)
            }, completion: { _ in
                completion?()
            })
        }
    }
}

class RootTransition: NSObject {
    
    var animator: AnimatorProtocol?
    var isAnimated: Bool = true
    var removeNavigation: Bool = false
    
    var modalTransitionStyle: UIModalTransitionStyle
    var modalPresentationStyle: UIModalPresentationStyle
    
    weak var viewController: UIViewController?
    
    init(animator: AnimatorProtocol? = nil,
         isAnimated: Bool = true,
         modalTransitionStyle: UIModalTransitionStyle = .coverVertical,
         modalPresentationStyle: UIModalPresentationStyle = .fullScreen,
         removeNavigation: Bool = false) {
        self.animator = animator
        self.isAnimated = isAnimated
        self.modalTransitionStyle = modalTransitionStyle
        self.modalPresentationStyle = modalPresentationStyle
        self.removeNavigation = removeNavigation
    }
}

// MARK: - Transition

extension RootTransition: Transition {
    
    func open(_ viewController: UIViewController) {
        viewController.transitioningDelegate = self
        viewController.modalTransitionStyle = modalTransitionStyle
        viewController.modalPresentationStyle = modalPresentationStyle
        
        let mainWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow == true })
        mainWindow?.switchRootViewController(viewController, removeNavigation: self.removeNavigation)
        mainWindow?.rootViewController?.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    func close(_ viewController: UIViewController) {
    }
}

// MARK: - UIViewControllerTransitioningDelegate

extension RootTransition: UIViewControllerTransitioningDelegate {
    
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
