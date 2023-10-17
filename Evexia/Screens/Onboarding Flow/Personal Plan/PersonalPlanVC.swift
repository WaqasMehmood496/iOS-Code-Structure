//
//  PersonalPlanVC.swift
//  Evexia
//
//  Created by  Artem Klimov on 08.07.2021.
//

import UIKit
import Foundation
import Combine
import Reachability

class PersonalPlanVC: BaseViewController, StoryboardIdentifiable {
    
    // MARK: - IBOutlets
    @IBOutlet var targetViews: [TargetView]!
    @IBOutlet var backgroundViews: [FocusBackgroundView]!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var buildPlanButton: RequestButton!
    
    private var tempTargetViews: [Focus] = []
    
    // MARK: - IBActions
    @IBAction func buildPlanButtonDidTap(_ sender: RequestButton) {
        
        if reachability.connection == .unavailable {
            modalAlert(modalStyle: ServerError(errorCode: .networkConnectionError).errorCode, completion: {})
            return
        }
        
        var dict: [Int: Focus?] = [:]
       
        targetViews.enumerated().forEach { index, targetView in
            if let focus = targetView.focus {
                dict[index] = focus
            }
        }
        
        let tempFocus = targetViews.compactMap { $0.focus }
        
        if tempFocus != tempTargetViews {
            UserDefaults.focusCard = dict
        }
        
        self.buildPlanButton.isUserInteractionEnabled = false
        self.viewModel.setPersonalPlan(dict: dict)
        tempTargetViews = targetViews.compactMap { $0.focus }
    }
    
    // MARK: - Properties
    var lock = NSLock()
    var cardViews: [FocusCardView] = []
    var cancellables = Set<AnyCancellable>()
    var viewModel: PersonalPlanVMType!
    private let reachability = try! Reachability()
    
    // MARK: - Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupCardViews()
        (self.tabBarController as? TabBarController)?.setTabBarHidden(true, animated: false)
        
        if UserDefaults.isOnboardingDone {
            let backButton = UIBarButtonItem(image: UIImage(named: "arrow_left"), style: .plain, target: self, action: #selector(backNavigation(_:)))
            backButton.tintColor = .gray700
            self.navigationController?.visibleViewController?.navigationItem.leftBarButtonItems?.insert(backButton, at: 0)
            self.navigationController?.visibleViewController?.navigationItem.leftBarButtonItems?[1].tintColor = UIColor.clear
        } else {
            self.navigationController?.visibleViewController?.navigationItem.leftBarButtonItem?.tintColor = UIColor.clear
        }
        self.navigationController?.navigationBar.topItem?.title = "Personal plan".localized()
        self.buildPlanButton.isUserInteractionEnabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if UserDefaults.isOnboardingDone {
            self.navigationController?.visibleViewController?.navigationItem.leftBarButtonItems?.remove(at: 0)
        }
        self.navigationController?.visibleViewController?.navigationItem.leftBarButtonItem?.tintColor = .gray700
        self.navigationController?.visibleViewController?.navigationItem.leftBarButtonItem?.isEnabled = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.layoutIfNeeded()
        self.setupViews()
        self.binding()
        self.navigationController?.navigationBar.topItem?.title = "Personal plan"
        
        checkInternetState()
    }
    
    @objc private func backNavigation(_ sender: Any?) {
        (self.tabBarController as? TabBarController)?.setTabBarHidden(false, animated: false)
        self.navigationController?.popViewController(animated: true)
    }
    
    func checkInternetState() {
        do {
            try self.reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
    private func binding() {
        Publishers.CombineLatest4(targetViews[0].isEmptyTarget,
                                  targetViews[1].isEmptyTarget,
                                  targetViews[2].isEmptyTarget,
                                  targetViews[3].isEmptyTarget)
            .debounce(for: 0.2, scheduler: DispatchQueue.main)
            .sink(receiveValue: { [weak self] value in
                self?.buildPlanButton.isEnabled = !value.0 && !value.1 && !value.2 && !value.3
            }).store(in: &cancellables)
    }
    
    private func setupViews() {
        DispatchQueue.main.async {
            self.cardViews.enumerated().forEach({ $0.element.focusImageView.image = UIImage(named: Focus.allCases[$0.offset].image_key)
                $0.element.titleLabel.text = Focus.allCases[$0.offset].title
                $0.element.descriptionLabel.text = Focus.allCases[$0.offset].description
                $0.element.focus = Focus.allCases[$0.offset]
            })
            
            self.backgroundViews.enumerated().forEach({ $0.element.imageView.image = UIImage(named: Focus.allCases[$0.offset].image_key)?.withTintColor(.white) })
            
            self.targetViews.enumerated().forEach({
                $0.element.countLabel.text = ($0.offset + 1).description
            })
        }
        
    }
    
    private func handleCardleGesture(cardView: FocusCardView, state: UIGestureRecognizer.State, location: CGPoint) {
        switch state {
        case .began:
            cardViews.forEach { $0.isUserInteractionEnabled = false }
            guard let targetView = targetViews.first(where: { $0.frame.contains(cardView.currentCenter) }) else {
                UIView.animate(withDuration: 0.2, animations: {
                    DispatchQueue.main.async {
                        cardView.rotate(radians: -0.04)
                        cardView.view.layer.borderColor = UIColor.orange.cgColor
                    }
                })
                return }
            
            self.buildPlanButton.isEnabled = false
            targetView.isEmptyTarget.value = true
            
            UIView.animate(withDuration: 0.2, animations: {
                DispatchQueue.main.async {
                    cardView.rotate(radians: -0.04)
                    cardView.view.layer.borderColor = UIColor.orange.cgColor
                }
            })
            
        case .changed:
            guard let targetView = targetViews.first(where: { $0.frame.contains(location) }) else {
                DispatchQueue.main.async {
                    self.targetViews.forEach({
                        $0.countLabel.textColor = .gray400
                        $0.dashBorder.strokeColor = UIColor.gray500.cgColor
                        $0.dashPatternView.backgroundColor = .clear
                        $0.view.backgroundColor = .white
                    })
                }
                return
            }
            
            DispatchQueue.main.async {
                targetView.view.backgroundColor = .lightOrange
                
                self.targetViews.forEach {
                    $0.dashBorder.strokeColor = UIColor.orange.cgColor
                    $0.countLabel.textColor = .orange
                }
            }
            
            if !targetView.isEmptyTarget.value {
                
                UIView.animate(withDuration: 0.2, animations: {
                    if let targetToMove = self.targetViews.first(where: { $0.isEmptyTarget.value == true }) {
                        let moveCard = self.cardViews.first(where: { return $0.frame.contains(targetView.center) && $0 != cardView })
                        moveCard?.center = targetToMove.center
                        moveCard?.currentCenter = targetToMove.center
                        targetToMove.isEmptyTarget.value = false
                        targetView.isEmptyTarget.value = true
                        targetToMove.focus = moveCard?.focus
                    }
                    self.lock.unlock()
                })
            }
            
        case .ended:
            cardViews.forEach { $0.isUserInteractionEnabled = true }
            let targetView = targetViews.first(where: { view in view.frame.contains(location) })
            guard let target = targetView else {
                cardView.center = cardView.originCenter
                cardView.view.layer.borderColor = UIColor.clear.cgColor
                cardView.rotate(radians: 0)
                cardView.currentCenter = .zero
                return
            }
            
            cardView.center = target.center
            cardView.currentCenter = target.center
            cardView.view.layer.borderColor = UIColor.connect.cgColor
            target.focus = cardView.focus
            target.isEmptyTarget.value = false
            targetViews.forEach({
                $0.countLabel.textColor = .gray400
                $0.dashBorder.strokeColor = UIColor.gray500.cgColor
            })
            cardView.rotate(radians: 0)
            cardView.layer.borderColor = UIColor.feel.cgColor
        case .possible:
            break
        case .cancelled:
            cardViews.forEach { $0.isUserInteractionEnabled = true }
            break
        case .failed:
            cardViews.forEach { $0.isUserInteractionEnabled = true }
            break
        @unknown default:
            break
        }
    }
    
    private func setupCardViews() {
        if cardViews.isEmpty {
            self.backgroundViews.forEach({ view in
                let cardView = FocusCardView(frame: view.frame)
                cardView.isSelected
                    .sink(receiveValue: { cardView, state, location in
                        self.handleCardleGesture(cardView: cardView, state: state, location: location)
                    }).store(in: &cancellables)
                self.container.addSubview(cardView)
                self.cardViews.append(cardView)
            })
        }
    }
}
