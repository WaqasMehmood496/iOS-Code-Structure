//
//  RecoveryVerification.swift
//  Evexia
//
//  Created by  Artem Klimov on 05.07.2021.
//

import UIKit
import Combine
import Atributika

class RecoveryVerificationVC: BaseViewController, StoryboardIdentifiable {
    
    // MARK: - IBOutlets
    @IBOutlet weak var notificationView: NotificationView!
    
    // MARK: - Properties
    var viewModel: RecoveryVerificationVMType!
    
    private var cancellables: [AnyCancellable] = []

    // MARK: - VC life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        Log.info(Configuration().environment)
        
        self.setupUI()
        self.binding()
    }
}

// MARK: - Private Methods
private extension RecoveryVerificationVC {
    func setupUI() {
        self.localizeStrings()
        self.setupNotificationView()
    }
    
    func localizeStrings() {
        self.notificationView.descriptionLabel.attributedText = "An email has been sent.\nPlease click the link when you get it.".localized().styleAll(self.notificationView.descriptionStyle).attributedString
        
        self.notificationView.titleLabel.attributedText = "Password recovery".localized().styleAll(self.notificationView.titleStyle).attributedString
        
        self.notificationView.resendButton.setTitle("Back to home".localized(), for: .normal)
    }
    
    func setupNotificationView() {
        self.notificationView.backButton.isHidden = true
        self.notificationView.buttonsStackView.isLayoutMarginsRelativeArrangement = true
        self.notificationView.buttonsStackView.layoutMargins = UIEdgeInsets(top: 0.0, left: 50.0, bottom: 0.0, right: 50.0)
        self.notificationView.buttonsStackView.isLayoutMarginsRelativeArrangement = true
    }
    
    func binding() {
        self.notificationView.actionButtonDidTap
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.viewModel.navigateToSignUp()
            }).store(in: &self.cancellables)
    }
}
