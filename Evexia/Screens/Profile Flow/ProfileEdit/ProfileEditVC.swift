//
//  ProfileVC.swift
//  Evexia
//
//  Created by  Artem Klimov on 28.07.2021.
//

import UIKit
import Combine
import AVFoundation
import Kingfisher
import Photos

class ProfileEditVC: BaseViewController, StoryboardIdentifiable {
    
    deinit {
        Log.info("deinit -----> \(self)")
    }
    
    // MARK: - IBOutlets
    @IBOutlet private weak var setAvatarButton: UIButton!
    @IBOutlet private weak var shadowView: UIView!
    @IBOutlet private weak var avatarImageView: UIImageView!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var avatarBackgroundView: UIView!
    @IBOutlet private weak var profileTableView: IntrinsicTableView!
    @IBOutlet private weak var setProfileButton: RequestButton!
    
    private let picker = ImagePicker()
    
    @IBAction func uploadPhotoButtonDidTap(_ sender: UIButton) {
        self.showActionSheet()
    }
    
    @IBAction func finishButtonDidTap(_ sender: RequestButton) {
        self.finishOnboarding.send()
    }
    
    // MARK: - Properties
    internal var viewModel: ProfileVEditMType!
    private var cancellables = Set<AnyCancellable>()
    private let load = PassthroughSubject<Void, Never>()
    private let nextAction = PassthroughSubject<Void, Never>()
    private let saveAvatar = PassthroughSubject<UIImage, Never>()
    private let setGender = PassthroughSubject<Gender?, Never>()
    private let deleteAvatar = PassthroughSubject<Void, Never>()
    private let finishOnboarding = PassthroughSubject<Void, Never>()

    private let navigateToParameter = PassthroughSubject<ProfileCellModel, Never>()
    private var isAvatarSet: Bool = false
    private let rowHeight: CGFloat = 56.0
    private lazy var dataSource = self.configDataSource()
    
    // MARK: - VC life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.binding()
        self.load.send()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let navTitle = self.viewModel.profileFlow == .edit ? "Edit profile".localized() : "Profile set up".localized()
        self.navigationController?.visibleViewController?.navigationItem.title = navTitle
        (self.tabBarController as? TabBarController)?.setTabBarHidden(false, animated: true)
    }
}

// MARK: - Private Methods
private extension ProfileEditVC {
    func setupUI() {
        self.setupTableView()
        self.setupScrollView()
        self.setupShadows()
        self.setupAvatarViews()
        self.picker.delegate = self
        self.picker.allowsEditing = true

        self.setProfileButton.isHidden = viewModel.profileFlow == .edit ? true : false
    }
    
    func setupTableView() {
        self.profileTableView.dataSource = self.dataSource
        self.profileTableView.delegate = self
        self.profileTableView.register(ProfileCell.nib, forCellReuseIdentifier: ProfileCell.identifier)
        self.profileTableView.register(EmptyFooterView.self, forHeaderFooterViewReuseIdentifier: EmptyFooterView.identifier)
        self.profileTableView.register(MyAvailabilityHeaderView.self, forHeaderFooterViewReuseIdentifier: MyAvailabilityHeaderView.identifier)
        self.profileTableView.isScrollEnabled = false
        self.profileTableView.separatorInset = UIEdgeInsets(top: 0, left: 16.0, bottom: 0, right: 16.0)
        self.profileTableView.separatorColor = .gray300
        self.profileTableView.showsVerticalScrollIndicator = false
        self.profileTableView.rowHeight = self.rowHeight
        
        if #available(iOS 15.0, *) {
            self.profileTableView.sectionHeaderTopPadding = 0
        }
    }
    
    func setupShadows() {
        self.shadowView.layer.cornerRadius = 16.0
        self.shadowView.dropShadow(radius: 20, xOffset: 0, yOffset: 2, shadowOpacity: 0.5, shadowColor: .gray400)
        
        self.profileTableView.layer.cornerRadius = 16.0
        self.profileTableView.layer.masksToBounds = true
    }
    
    private func setupAvatarViews() {
        self.avatarBackgroundView.layer.cornerRadius = 44.0
        self.avatarBackgroundView.dropShadow(radius: 8, xOffset: 0, yOffset: 4, shadowOpacity: 0.5, shadowColor: .gray400)
        
        self.avatarImageView.layer.cornerRadius = 40.0
        self.avatarImageView.layer.masksToBounds = true
    
    }
    
    private func setAvatar(url: String?) {
        let urlString = url ?? ""
        let url = URL(string: urlString)
        self.isAvatarSet = url != nil
        self.avatarImageView.kf.setImage(with: url, placeholder: UIImage(named: "avatar")) { [weak self] completion in
            switch completion {
            case .failure:
                self?.avatarImageView.contentMode = .center
            case .success:
                self?.avatarImageView.contentMode = .scaleAspectFill
            }
        }
        let buttonTitle = self.isAvatarSet ? "Upload new profile photo" : "Upload profile photo"
        self.setAvatarButton.setTitle(buttonTitle, for: .normal)
    }
    
    func setupScrollView() {
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.showsHorizontalScrollIndicator = false
    }
    
    func binding() {
        self.cancellables.forEach { $0.cancel() }
        self.cancellables.removeAll()
        let input = ProfileVMInput(load: self.load.eraseToAnyPublisher(),
                                   nextAction: self.nextAction.eraseToAnyPublisher(),
                                   saveAvatar: self.saveAvatar.eraseToAnyPublisher(),
                                   deleteAvatar: self.deleteAvatar.eraseToAnyPublisher(),
                                   setGender: self.setGender.eraseToAnyPublisher(),
                                   navigateToParameter: self.navigateToParameter.eraseToAnyPublisher(),
                                   finishOnboarding: self.finishOnboarding.eraseToAnyPublisher())
        
        let output = viewModel.transform(input: input)
        
        output
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [unowned self] state in
                self.render(state)
            }).store(in: &cancellables)
    }
    
    func render(_ state: ProfileEditVCState) {
        switch state {
        case let .idle(screenFlow):
            self.setProfileButton.isHidden = screenFlow == .edit
        case let .update(models):
            self.update(with: models)
        case .loading:
            self.setProfileButton.isRequestAction.send(true)
        case let .setProfileAvailabel(isAvailabel):
            self.setProfileButton.isEnabled = isAvailabel
        case let .failure(serverError):
            self.modalAlert(modalStyle: serverError.errorCode)
            self.setProfileButton.isRequestAction.send(false)
        case .success:
            self.setProfileButton.isRequestAction.send(false)
        case let .setAvatar(urlString):
            self.setAvatar(url: urlString)
        case let .finishAvailable(isAvailabel):
            self.setProfileButton.isEnabled = isAvailabel
        }
    }
    
    private func applyCameraPickerFlow() {
        switch PermissionService.getCameraPickerPermissions() {
        case .authorized:
            self.showCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { [weak self] accessed in
                DispatchQueue.main.async {
                    if accessed {
                        self?.showCamera()
                    } else {
                        self?.showPermissionDeclineWarning(with: "Application doesn’t have permission to use camera or choose image from your photo gallery.".localized())
                    }
                }
            })
        default:
            self.showPermissionDeclineWarning(with: "Application doesn’t have permission to use camera or choose image from your photo gallery.".localized())
        }
    }
    
    private func applyImagePickerFlow() {
        switch PermissionService.getPhotoLibraryPermissions() {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({ [weak self] newStatus in
                switch newStatus {
                case .authorized, .limited:
                    DispatchQueue.main.async {
                        self?.showImagePicker()
                    }
                default:
                    break
                }
            })
        case .authorized, .limited:
            DispatchQueue.main.async {
                self.showImagePicker()
            }
        default:
            self.showPermissionDeclineWarning(with: "Application doesn’t have permission to use camera or choose image from your photo gallery.".localized())
        }
    }
    
    private func showCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            self.picker.sourceType = .camera
            self.navigationController?.present(self.picker, animated: true, completion: nil)
        }
    }
    
    private func showImagePicker() {
        self.picker.sourceType = .photoLibrary
        self.present(self.picker, animated: true)
    }
    
    private func showSource(for model: ProfileCellModel) {
        switch model.type {
        case .gender:
            self.showPicker(style: Gender.allCases.map { PickerDataModel(title: $0.title) }, defaultSelected: model.value, returns: { [weak self] value in
                let gender = Gender(rawValue: value)
                self?.setGender.send(gender)
            })
        default:
            if (model.type == .weight || model.type == .height) && UserDefaults.isShowMeasurementPopUp == false {
                UserDefaults.isShowMeasurementPopUp = true
                showAchievementPopUp(type: .measurementSystem, verticalOffset: 150) { }
                return
            }
            self.viewModel.navigateToParameters(for: model)
        }
    }
    
    private func showActionSheet() {
        let alert = UIAlertController()
        
        alert.addAction(UIAlertAction(title: "Take a photo".localized(), style: .default, handler: { [weak self] _ in
            self?.applyCameraPickerFlow()
        }))
        
        alert.addAction(UIAlertAction(title: "Select from camera roll".localized(), style: .default, handler: { [weak self] _ in
            self?.applyImagePickerFlow()
        }))
        
        if isAvatarSet {
            alert.addAction(UIAlertAction(title: "Delete photo".localized(), style: .destructive, handler: { [weak self] _ in
                self?.deleteAvatar.send()
                self?.setAvatar(url: nil)
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: { _ in }))
        
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDiffableDataSource<Int, MyWhyModel>
extension ProfileEditVC: UITableViewDelegate {
    
    func update(with data: [ProfileCellModel], animate: Bool = false) {
        DispatchQueue.main.async {
            var snapshot = NSDiffableDataSourceSnapshot<Int, ProfileCellModel>()
            snapshot.appendSections([0])
            snapshot.appendItems(data)
            
            self.dataSource.apply(snapshot, animatingDifferences: animate)
        }
    }
    
    func configDataSource() -> UITableViewDiffableDataSource<Int, ProfileCellModel> {
        let dataSource = UITableViewDiffableDataSource<Int, ProfileCellModel>(
            tableView: self.profileTableView,
            cellProvider: { tableView, indexPath, model in
                let cell = tableView.dequeueReusableCell(withIdentifier: ProfileCell.identifier, for: indexPath) as! ProfileCell
                cell.configCell(with: model)
                return cell
            }
        )
        return dataSource
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 8.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 8.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return EmptyFooterView()
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return EmptyFooterView()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let model = self.dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        self.showSource(for: model)
    }
}

// MARK: - ProfileVC: UIImagePickerControllerDelegate & UINavigationControllerDelegate
extension ProfileEditVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            picker.dismiss(animated: true, completion: nil)
            return
        }
        
        picker.dismiss(animated: true) { [weak self] in
            self?.avatarImageView.contentMode = .scaleAspectFill
            self?.avatarImageView.image = image
            self?.saveAvatar.send(image)
            self?.isAvatarSet = true
            self?.setAvatarButton.setTitle("Upload new profile photo", for: .normal)
        }
    }
}
