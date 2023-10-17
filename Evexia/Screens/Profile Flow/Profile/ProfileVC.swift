//
//  ProfileVC.swift
//  Evexia
//
//  Created by  Artem Klimov on 17.08.2021.
//

import UIKit
import Combine
import BiometricAuthentication

class ProfileVC: BaseViewController, StoryboardIdentifiable {
    
    @IBOutlet weak var profileTableView: IntrinsicTableView!
    
    internal var viewModel: ProfileVM!
    
    private lazy var dataSource = self.configDataSource()
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupBiometric()
        self.binding()
        self.setupUI()
    }
    
    deinit {
        Log.info("deinit -> \(self)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.syncData()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        profileTableView.reloadData()
    }
    
    private func setupUI() {
        self.setupTableView()
        self.setupNavigationItem()
    }
    
    private func setupNavigationItem() {
        
        self.navigationItem.title = "Profile".localized()
        let settingsButton = UIBarButtonItem(image: UIImage(named: "settings"), style: .plain, target: self, action: #selector(navigateToSettings(_:)))
        
        let editButton = UIBarButtonItem(image: UIImage(named: "edit"), style: .plain, target: self, action: #selector(navigateToProfileEdit(_:)))
        
        self.navigationItem.leftBarButtonItem = settingsButton
        self.navigationItem.rightBarButtonItem = editButton
    }

    @objc
    func navigateToSettings(_ sender: Any?) {
        self.viewModel.navigateToSettings()
    }
    
    @objc
    func navigateToProfileEdit(_ sender: Any?) {
        self.viewModel.navigateToEditProfile()
    }
    
    private func binding() {
        self.viewModel.dataSource
            .sink(receiveValue: { [weak self] data in
                self?.update(with: data)
            }).store(in: &cancellables)
        
        self.viewModel.biometricPublisher
            .sink { [weak self] result in
                switch result {
                case let .success(access):
                    if access {
                        self?.tabBarController?.view.removeBlur()
                        
                        UIView.animate(withDuration: 1) {
                            self?.view.layer.opacity = 1
                        }
                    }
                case let .failure(error):
                    self?.handleBiometricError(with: error)
                }
            }.store(in: &cancellables)
    }
    
    private func setupTableView() {
        self.profileTableView.delegate = self

        self.profileTableView.dataSource = self.configDataSource()
        self.profileTableView.showsHorizontalScrollIndicator = false
        self.profileTableView.showsVerticalScrollIndicator = false
        self.profileTableView.separatorStyle = .none
        self.profileTableView.register(UserCell.nib, forCellReuseIdentifier: UserCell.identifier)
        self.profileTableView.register(StatisticContentCell.nib, forCellReuseIdentifier: StatisticContentCell.identifier)
        self.profileTableView.register(ProfileSettingsContentCell.nib, forCellReuseIdentifier: ProfileSettingsContentCell.identifier)
        self.profileTableView.register(DevicesCell.nib, forCellReuseIdentifier: DevicesCell.identifier)
        self.profileTableView.register(DevelopmentCell.nib, forCellReuseIdentifier: DevelopmentCell.identifier)

        self.profileTableView.rowHeight = UITableView.automaticDimension
        self.profileTableView.estimatedRowHeight = UITableView.automaticDimension
    }
    
    private func handleBiometricError(with error: Error) {
        guard let error = error as? AuthenticationError else {
            return
        }
        
        switch error {
        case .canceledBySystem, .canceledByUser:
            viewModel.logOut()
        default:
            break
        }
    }
    
    private func setupBiometric() {
        if UserDefaults.isFirstAccessToBiometric {
            UserDefaults.isFirstAccessToBiometric = !(KeychainProvider().getBiometricSettings()?.access == true) // проверяем при входе есть ли в кейчейне
        }

        if !UserDefaults.isFirstAccessToBiometric {
            if KeychainProvider().getBiometricSettings()?.access == true, BiometricdService.isNeedAuth {
                self.tabBarController?.view.addBlur(blurRadius: 5)
                self.view.layer.opacity = 0.4
                self.viewModel.setupBiometric(isOn: BiometricdService.isOn)
            }
        } else {
            UserDefaults.isFirstAccessToBiometric = false

            let actions = [
                AlertButton(title: "Ok".localized(), style: .default) { [weak self] in
                    guard let self = self else { return }
                    self.viewModel.setupBiometric(isOn: true)
                },
                AlertButton(title: "Cancel".localized(), style: .cancel) {
                    KeychainProvider().cleanSomeKeychain(with: .userBiometricSettings)
                }
            ]
            showAllert(alertStyle: .alert, message: "Your biometric data will be used along with the password. If biometrics is not accessible, the password will be used instead.".localized(), actions: actions)
        }
    }
}

extension ProfileVC: UITableViewDelegate {
    
    func update(with data: [ProfileCellContentType], animate: Bool = false) {
        DispatchQueue.main.async { [weak self] in
            var snapshot = NSDiffableDataSourceSnapshot<Int, ProfileCellContentType>()
            snapshot.appendSections([0])
            snapshot.appendItems(data)
            
                if #available(iOS 15.0, *) {
                    self?.dataSource.applySnapshotUsingReloadData(snapshot)
                } else {
                    self?.dataSource.apply(snapshot, animatingDifferences: animate)
                }
            }
    }
    
    func configDataSource() -> UITableViewDiffableDataSource<Int, ProfileCellContentType> {
        let dataSource = UITableViewDiffableDataSource<Int, ProfileCellContentType>(
            tableView: self.profileTableView,
            cellProvider: { [unowned self] tableView, indexPath, model in
                switch model {
                case .devices:
                    let cell = tableView.dequeueReusableCell(withIdentifier: DevicesCell.identifier, for: indexPath) as! DevicesCell
                    cell.configCell(with: model)
                    return cell
                case let .user(user):
                    let cell = tableView.dequeueReusableCell(withIdentifier: UserCell.identifier, for: indexPath) as! UserCell
                    cell.configCell(with: user)
                    return cell
                case .statistic(content: let content):
                    let cell = tableView.dequeueReusableCell(withIdentifier: StatisticContentCell.identifier, for: indexPath) as! StatisticContentCell
                    
                    cell.statisticNavigationPublisher
                        .sink(receiveValue: { [weak self] type in
                            self?.viewModel.navigateToStatistic(type: type)
                        })
                        .store(in: &cell.cancellables)
                    
                    cell.configCell(with: content)
                    return cell
                case let .settings(content):
                    let cell = tableView.dequeueReusableCell(withIdentifier: ProfileSettingsContentCell.identifier, for: indexPath) as! ProfileSettingsContentCell
                    cell.configCell(with: content)

                    cell.settingsNavigationPublisher
                        .sink(receiveValue: { [weak self] benefit in
                            self?.viewModel.navigateToBenefit(type: benefit)
                        })
                        .store(in: &cell.cancellables)
                    
                    return cell
                case .achievments:
                    let cell = tableView.dequeueReusableCell(withIdentifier: DevelopmentCell.identifier, for: indexPath) as! DevelopmentCell
                    cell.configCell(with: .achievments)
                    return cell
                case let .personalDevelopment(type):
                    let cell = tableView.dequeueReusableCell(withIdentifier: DevelopmentCell.identifier, for: indexPath) as! DevelopmentCell
                    cell.configCell(with: type)

                    return cell
                }
            })
        return dataSource
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch dataSource.itemIdentifier(for: indexPath) {

        case .statistic:
            let width = (self.view.frame.width - 32.0 * 2.0 - 16.0) / 2.0
            let height = width / 148.0 * 78.0
            return 60.0 + 72.0 + height * 2.0 + 40.0 + 16 + 78
        case let .settings(content):
            return CGFloat(content.count) * 56 + CGFloat(content.count - 1) + 16.0 + 16.0
        case .personalDevelopment:
            return 130.0
        default:
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO: RERATE
        switch indexPath.row {
        case 2:
            if UserDefaults.isShowAchieve {
                self.viewModel.navigateToAchievments()
            }
        case 3:
            self.viewModel.navigateToPersonalDevelopment()
        default:
            return
        }
    }
}
