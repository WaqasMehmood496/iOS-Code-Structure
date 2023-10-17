//
//  SettingsVC.swift
//  Evexia
//
//  Created by  Artem Klimov on 09.08.2021.
//

import Foundation
import UIKit
import Combine
import BiometricAuthentication

class SettingsVC: BaseViewController, StoryboardIdentifiable {
    
    // MARK: - IBOutlet
    @IBOutlet weak var settingsTableView: UITableView!
    
    // Properties
    var viewModel: SettingsVMType!
    
    private var cancellables: [AnyCancellable] = []
    private let appear = PassthroughSubject<Void, Never>()
    private let delete = PassthroughSubject<Void, Never>()
    private let logout = PassthroughSubject<Void, Never>()
    private let navigateToSetting = PassthroughSubject<Settings, Never>()

    private lazy var dataSource = self.configDataSource()
    
    // MARK: - VC life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.bind(to: self.viewModel)
        self.appear.send()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        (self.tabBarController as? TabBarController)?.setTabBarHidden(false, animated: true)
    }
    
    deinit {
        Log.info("deinit -> \(self)")
    }
}

private extension SettingsVC {
    
    private func setupUI() {
        self.navigationItem.title = "Settings"
        self.setupTableView()
    }
    
    private func setupTableView() {
        self.settingsTableView.dataSource = self.dataSource
        self.settingsTableView.delegate = self
        self.settingsTableView.layer.masksToBounds = false
        self.settingsTableView.register(SettingsContentCell.nib, forCellReuseIdentifier: SettingsContentCell.identifier)
        if #available(iOS 15.0, *) {
            self.settingsTableView.sectionHeaderTopPadding = 0
        }
    }
    
    func bind(to viewModel: SettingsVMType) {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        
        let input = SettingsVMInput(appear: appear.eraseToAnyPublisher(),
                                    deleteAccount: delete.eraseToAnyPublisher(),
                                    logout: logout.eraseToAnyPublisher(),
                                    navigateToSetting: navigateToSetting.eraseToAnyPublisher())
        
        let output = viewModel.transform(input: input)
        
        output.sink(receiveValue: { [unowned self] state in
            self.render(state)
        }).store(in: &cancellables)
    }
    
    func configDataSource() -> UITableViewDiffableDataSource<Int, [Settings]> {
        let dataSource = UITableViewDiffableDataSource<Int, [Settings]>(
            tableView: self.settingsTableView,
            cellProvider: { [weak self] tableView, indexPath, model in
                
                let cell = tableView.dequeueReusableCell(withIdentifier: SettingsContentCell.identifier, for: indexPath) as! SettingsContentCell
                cell.configCell(with: model)
                
                cell.settingsNavigationPublisher
                    .sink(receiveValue: { setting in
                        self?.applyNavigation(for: setting)
                    }).store(in: &cell.cancellables)
                
                cell.switchPublisher
                    .sink(receiveValue: { type, isOn in
                        if type == .gamefication {
                            self?.viewModel.changeAchievementsApearence(isShow: isOn)
                        } else if type == .faceTouchId {
                            self?.setupBiometric(isOn: isOn)
                        }
                    }).store(in: &cell.cancellables)
                return cell
            }
        )
        return dataSource
    }
    
    func update(with data: [[Settings]], animate: Bool = false) {
        DispatchQueue.main.async { [weak self] in
            var snapshot = NSDiffableDataSourceSnapshot<Int, [Settings]>()
            snapshot.appendSections([0])
            snapshot.appendItems(data)
            
            self?.dataSource.apply(snapshot, animatingDifferences: animate)
        }
    }
    
    func render(_ state: SettingsVCState) {
        switch state {
        case let .idle(data):
            self.update(with: data)
            return
        case .loading:
            return
        case let .failure(error):
            self.modalAlert(modalStyle: error.errorCode)
        case let .failureBiometric(error):
            handleBiometricError(with: error)
        case .success:
            return
        }
    }
    
    func applyNavigation(for setting: Settings) {
        switch setting {
        case .delete:
            self.modalAlert(modalStyle: ModalAlertViewStyles.deleteAccount,
                            completion: { [weak self] in
                                self?.delete.send()
                            }, cancel: {})
        case .logout:
            self.modalAlert(modalStyle: ModalAlertViewStyles.logout,
                            completion: { [weak self] in
                                self?.logout.send()
                            }, cancel: {})
        default:
            self.navigateToSetting.send(setting)
        }
    }
    
    private func handleBiometricError(with error: Error) {
        guard let error = error as? AuthenticationError else {
            return
        }
        
        switch error {
        case .canceledBySystem, .canceledByUser:
            KeychainProvider().cleanSomeKeychain(with: .userBiometricSettings)
        case .biometryNotEnrolled, .biometryNotAvailable:
            showPermissionDeclineWarning(with: "Enable biometric authentication for MyDay in Settings.")
        default:
            break
        }
    }

    private func setupBiometric(isOn: Bool) {
        if UserDefaults.isFirstAccessiNSettingsToBiometric {
            UserDefaults.isFirstAccessiNSettingsToBiometric = !(KeychainProvider().getBiometricSettings()?.access == true) // проверяем при входе есть ли в кейчейне
        }

        if !UserDefaults.isFirstAccessiNSettingsToBiometric {
            self.viewModel.setupBiometric(isOn: isOn)
        } else {
            let actions = [
                AlertButton(title: "Ok".localized(), style: .default) { [weak self] in
                    guard let self = self else { return }
                    UserDefaults.isFirstAccessiNSettingsToBiometric = false
                    self.viewModel.setupBiometric(isOn: isOn)
                },
                AlertButton(title: "Cancel".localized(), style: .cancel) {
                    KeychainProvider().cleanSomeKeychain(with: .userBiometricSettings)
                }
            ]
            showAllert(alertStyle: .alert, message: "Your biometric data will be used along with the password. If biometrics is not accessible, the password will be used instead.".localized(), actions: actions)
        }
    }
}

extension SettingsVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let count = self.dataSource.itemIdentifier(for: indexPath)?.count ?? 0
        let height = CGFloat(count) * 57.0 + 16.0 + 16.0 - 1.0
        return height
    }
}
