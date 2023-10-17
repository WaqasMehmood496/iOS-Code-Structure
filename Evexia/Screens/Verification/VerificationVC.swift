//
//  VerificationVC.swift
//  Evexia
//
//  Created by  Artem Klimov on 01.07.2021.
//

import Foundation
import UIKit
import Atributika
import Combine

class VerificationVC: BaseViewController, StoryboardIdentifiable {
    
    @IBOutlet private weak var notificationView: NotificationView!
    
    // MARK: - Properties
    var viewModel: VerificationVMType!
    
    private let retry = PassthroughSubject<Void, Never>()
    private let appear = PassthroughSubject<Void, Never>()
    
    private var cancellables: [AnyCancellable] = []
    
    // MARK: - VC life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        Log.info(Configuration().environment)
        
        self.setupUI()
        self.bind(to: self.viewModel)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        appear.send()
    }
}

// MARK: - Private Methods
private extension VerificationVC {
    func setupUI() {
        self.localizeStrings()
    }
    
    func localizeStrings() {
        self.notificationView.descriptionLabel.attributedText = "Please check your inbox and click on the activation link to complete registration process. If you don’t get an email within a few minutes, please retry.".localized().styleAll(self.notificationView.descriptionStyle).attributedString
        self.notificationView.titleLabel.attributedText = "Activation mail has been sent to".localized().styleAll(self.notificationView.titleStyle).attributedString + "  “\(self.viewModel.email)”".styleAll(self.notificationView.titleStyle).attributedString
        self.notificationView.backButton.setTitle("Back".localized(), for: .normal)
        self.notificationView.resendButton.setTitle("Retry".localized(), for: .normal)
    }
    
    func bind(to viewModel: VerificationVMType) {
        self.cancellables.forEach { $0.cancel() }
        self.cancellables.removeAll()
        
        let input = VerificationVMInput(retry: retry.eraseToAnyPublisher(),
                                        appear: appear.eraseToAnyPublisher())
        
        let output = viewModel.transform(input: input)
        
        output.sink(receiveValue: { [unowned self] state in
            self.render(state)
        }).store(in: &cancellables)
        
        self.notificationView.actionButtonDidTap
            .sink(receiveValue: { [weak self] in
                self?.retry.send(())
            }).store(in: &self.cancellables)
        
        self.notificationView.backButtonDidTap
            .sink(receiveValue: { [weak self] in
                self?.viewModel.navigateToSignUp()
            }).store(in: &self.cancellables)
    }
    
    func render(_ state: VerificationVCState) {
        switch state {
        case .loading:
            self.notificationView.resendButton.isRequestAction.send(true)
        case let .failure(error):
            self.modalAlert(modalStyle: error.errorCode)
            self.notificationView.resendButton.isRequestAction.send(false)
        case .success:
            self.notificationView.resendButton.isRequestAction.send(false)
        case .idle:
            return
        }
    }
}
