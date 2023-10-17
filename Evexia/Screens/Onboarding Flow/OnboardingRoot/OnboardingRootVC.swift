//
//  OnboardingRootVC.swift
//  Evexia
//
//  Created by  Artem Klimov on 08.07.2021.
//

import UIKit
import Combine

class OnboardingRootVC: BaseViewController, StoryboardIdentifiable {
    @IBOutlet weak var onboardingProgress: SectionedProgressView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var controllers = [UIViewController]()
    
    var pageController: UIPageViewController!
    var backButton = UIBarButtonItem()
    var cancellabels = Set<AnyCancellable>()
    var viewModel: OnboardingRootVM!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupPageController()
        self.onboardingProgress.setupSections(count: controllers.count)
        self.binding()
    }
    
    private func binding() {
        self.viewModel.currentController
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] screen, direction in
                self?.scrollViewControllers(screen: screen, direction: direction)
            }).store(in: &cancellabels)
        
        self.setupBackButton()
    }
    
    private func scrollViewControllers(screen: OnboardingScreen, direction: UIPageViewController.NavigationDirection) {
        self.pageController.setViewControllers([self.controllers[screen.rawValue]], direction: direction, animated: true)
        self.onboardingProgress.updateProgress(index: screen.rawValue)
    }
    
    private func setupPageController() {
        self.pageController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        self.pageController.view.frame = containerView.bounds
        self.containerView.addSubview(pageController.view)
        self.addChild(self.pageController)
        self.didMove(toParent: pageController)
        self.controllers = viewModel.collectViewControllers()
    }
    
    func setupBackButton() {
//        if viewModel.profileFlow == .changePlanAfterEndPeriod {
//            let close = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(backAction(_:)))
//            close.tintColor = .red
//            self.navigationController?.navigationItem.leftBarButtonItem = close
//        } else {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "arrow_left"), style: .plain, target: self, action: #selector(backNavigation(_:)))
            self.navigationItem.leftBarButtonItem?.tintColor = .clear
            self.navigationItem.leftBarButtonItem?.isEnabled = false
//        }
    }
    
    @objc
    func backNavigation(_ sender: Any?) {
        self.viewModel.showPreviousScreen()
    }
    
//    @objc
//    func backAction(_ sender: Any?) {
//        self.navigationController?.popViewController(animated: true)
//    }
}
