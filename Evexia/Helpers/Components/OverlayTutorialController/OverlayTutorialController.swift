//
//  OverlayTutorialView.swift
//  Evexia
//
//  Created by admin on 10.09.2021.
//

import Foundation
import UIKit
import Combine

enum Tutorials: Codable {
    
    // Diary
    case start
    case completeTask
    case swipeLeft
    case undoTask
//    case deleteTask
    
    // Library
    case favorite
    
    var imageKey: String? {
        switch self {
        case .start:
            return "rightSwipe"
        case .swipeLeft:
            return "leftSwipe"
        case .completeTask:
            return nil
        case .undoTask:
            return nil
//        case .deleteTask:
//            return nil
        case .favorite:
           return nil
        }
    }
    
    var title: String {
        switch self {
        case .start:
            return "Here’s your first goal".localized()
        case .swipeLeft:
            return "Swipe left to undo or skip your goal".localized()
        case .completeTask:
            return "Complete the goal".localized()
        case .undoTask:
            return "Swipe left to undo or skip your goal".localized()
//        case .deleteTask:
//            return "Swipe left to undo or skip your goal".localized()
        case .favorite:
            return "Add to My favourites".localized()
        }
    }
    
    var description: String {
        switch self {
        case .start:
            return "Swipe right to complete the goal".localized()
        case .swipeLeft:
            return "You won’t be penalised for skipping, but only skip for a good reason.".localized()
        case .completeTask:
            return "Tap the green buttons if you complete or exceed the goal".localized()
        case .undoTask:
            return "You won’t be penalised for skipping, but only skip for a good reason.".localized()
//        case .deleteTask:
//            return "If you would like to try something different or our selection does not fit. Swipe left for more options until it fits for you".localized()
        case .favorite:
            return "You've saved your first piece of content! Click here to access them at any time".localized()
        }
    }
}

class OverlayTutorialController: UIViewController {
    var hitableArea: CGRect = .zero
    var cancellables = Set<AnyCancellable>()
    var originRect: CGRect = .zero
    
    deinit {
        Log.error("DEINIT TUTORIAL")
    }
    
    func showInViewController(_ viewController: UIViewController, for rect: CGRect) {
        self.binding()
        
        guard let window = UIApplication.shared.windows.first else {
            return
        }
        
        // config view
        let view = TouchDelegatingView()
        self.view = view
        self.view.frame = window.bounds
        window.addSubview(self.view)
        viewController.addChild(self)
        self.didMove(toParent: viewController)
        view.touchDelegate = self.view
        view.hitableArea = rect
        
        guard let tutorial = UserDefaults.currentTutorial else {
            self.removeTutorialView()
            return
        }
        
        // prepare focus rect
        self.originRect = rect.insetBy(dx: 8.0, dy: -4.0)
        
        self.showTutorial(for: tutorial, rect: self.originRect)
    }
    
    private func binding() {
        UserDefaults.$currentTutorial
            .receive(on: DispatchQueue.main)
            .subscribe(on: DispatchQueue.main)
            .sink(receiveValue: { [unowned self] tut in
                guard let tutorial = tut, tut != .start else {
                    self.closeTutorialMode()
                    return
                }
                self.showTutorial(for: tutorial, rect: originRect)
            }).store(in: &cancellables)
    }
    
    func closeTutorialMode() {
        removeTutorialView()
        self.willMove(toParent: nil)
        self.view.removeFromSuperview()
        self.removeFromParent()
        self.cancellables.forEach { $0.cancel() }
        self.cancellables.removeAll()
    }
    
    private func showTutorial(for tutorial: Tutorials, rect: CGRect) {
        // Remove old tutorial
        self.removeTutorialView()
        
        var hitableRect: CGRect = .zero
        switch tutorial {
        case .start:
            hitableRect = rect
        case .completeTask:
            hitableRect = CGRect(x: rect.minX, y: rect.minY, width: 68.0 + 16.0, height: rect.height)
        case .swipeLeft:
            hitableRect = CGRect(x: rect.minX, y: rect.minY, width: rect.width, height: rect.height)
        case .undoTask:
            hitableRect = CGRect(x: self.view.frame.maxX - 68.0 - 24.0, y: rect.minY, width: 68.0 + 16.0, height: rect.height)
        case .favorite:
            hitableRect = CGRect(x: rect.midX - 30.0, y: rect.midY - 35, width: 60.0, height: 60.0)
        }
        
        self.view.backgroundColor = UIColor.clear
        
        // Add new view for tutorial content
        let bgView = UIView(frame: self.view.bounds)
        bgView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        bgView.tag = 999
        
        // add focus region
        let path = CGMutablePath()
        path.addRect(self.view.bounds)
        
        hitableArea = hitableRect
        
        if hitableRect != CGRect.zero {
            path.addRoundedRect(in: hitableRect, cornerWidth: 8.0, cornerHeight: 8.0)
        }
        
        let maskLayer = CAShapeLayer()
        
        maskLayer.path = path
        maskLayer.cornerRadius = hitableRect.width / 2.0
        maskLayer.fillRule = CAShapeLayerFillRule.evenOdd
        bgView.clipsToBounds = true
        bgView.layer.mask = maskLayer
        
        let tutView = UIView(frame: self.view.bounds)
        tutView.tag = 999
        tutView.backgroundColor = UIColor.clear
        
        let hintView = TutorialHintView()

        hintView.titleLabel.text = tutorial.title
        hintView.descriptionLabel.text = tutorial.description
        hintView.descriptionLabel.sizeToFit()
        
        switch tutorial {
        case .favorite:
            let screenSize: CGRect = UIScreen.main.bounds
            
            if screenSize.maxY > hitableRect.maxY + 98 + 25 {
                hintView.frame = CGRect(x: 16.0, y: rect.maxY + 25.0, width: self.view.bounds.width - 32.0, height: hintView.titleLabel.frame.height + hintView.descriptionLabel.frame.height + 36.0)
            } else {
                hintView.frame = CGRect(x: 16.0, y: rect.minY - 25.0 - 98.0 - 36, width: self.view.bounds.width - 32.0, height: hintView.titleLabel.frame.height + hintView.descriptionLabel.frame.height + 36.0)
            }
        default:
            hintView.frame = CGRect(x: 16.0, y: rect.maxY + 70.0, width: self.view.bounds.width - 32.0, height: hintView.titleLabel.frame.height + hintView.descriptionLabel.frame.height + 36.0)
        }
        
        tutView.addSubview(hintView)
        
        bgView.alpha = 0.0
        tutView.alpha = 0.0
        self.view.addSubview(bgView)
        self.view.addSubview(tutView)
        self.view.bringSubviewToFront(tutView)
        self.view.sendSubviewToBack(bgView)
        bgView.alpha = 1.0
        self.view.bringSubviewToFront(hintView)
        
        // Set image frame according to current tutorial
        if let image = tutorial.imageKey {
            let imvIcon = UIImageView()
            switch tutorial {
            case .swipeLeft:
                imvIcon.frame = CGRect(origin: CGPoint(x: rect.maxX - 8.0 - 56.0, y: rect.maxY), size: CGSize(width: 56.0, height: 56.0))
            case .start:
                imvIcon.frame = CGRect(origin: CGPoint(x: rect.minX, y: rect.maxY), size: CGSize(width: 56.0, height: 56.0))
            default:
                break
            }

            imvIcon.image = UIImage(named: image)
            imvIcon.contentMode = .scaleAspectFit
            tutView.addSubview(imvIcon)
        }
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        maskLayer.path = path
        CATransaction.commit()
        tutView.alpha = 1.0
    }
    
    func removeTutorialView() {
        for subView in self.view.subviews where subView.tag == 999 {
            subView.removeFromSuperview()
        }
    }
}

class TouchDelegatingView: UIView {
    
    var hitableArea: CGRect?
    
    weak var touchDelegate: UIView?
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // check hit for swipe area
        if (hitableArea?.contains(point)) ?? true {
            return nil
        }
        // Check hit for close button
        for subview in subviews.reversed() {
            let subPoint = subview.convert(point, from: self)
            if let result = subview.hitTest(subPoint, with: event) {
                return result
            }
        }
        return self
    }
}
