//
//  UIViewController+Camera+ImagePicker.swift
//  Evexia
//
//  Created by Oleksandr Kovalov on 15.09.2021.
//

import AVFoundation
import Photos
import UIKit

// MARK: - Setting Image & Photo Picker
extension UIViewController {
    
    func showActionSheet(picker: ImagePicker) {
        let actions = [
            AlertButton(title: "Take a photo".localized(), style: .default) { [weak self] in
                self?.applyCameraPickerFlow(picker: picker)
            },
            AlertButton(title: "Select from camera roll".localized(), style: .default) { [weak self] in
                self?.applyImagePickerFlow(picker: picker)
            },
            AlertButton(title: "Cancel".localized(), style: .cancel) { }
        ]
        
        showAllert(alertStyle: .actionSheet, actions: actions)
    }
    
    private func applyCameraPickerFlow(picker: ImagePicker) {
        switch PermissionService.getCameraPickerPermissions() {
        case .authorized:
            self.showCamera(picker: picker)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { [weak self] accessed in
                DispatchQueue.main.async {
                    if accessed {
                        self?.showCamera(picker: picker)
                    } else {
                        self?.showPermissionDeclineWarning(with: "Application doesn’t have permission to use camera or choose image from your photo gallery.".localized())
                    }
                }
            })
        default:
            self.showPermissionDeclineWarning(with: "Application doesn’t have permission to use camera or choose image from your photo gallery.".localized())
        }
    }
    
    private func applyImagePickerFlow(picker: ImagePicker) {
        switch PermissionService.getPhotoLibraryPermissions() {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({ [weak self] newStatus in
                switch newStatus {
                case .authorized, .limited:
                    DispatchQueue.main.async {
                        self?.showImagePicker(picker: picker)
                    }
                default:
                    break
                }
            })
        case .authorized, .limited:
            DispatchQueue.main.async {
                self.showImagePicker(picker: picker)
            }
        default:
            self.showPermissionDeclineWarning(with: "Application doesn’t have permission to use camera or choose image from your photo gallery.".localized())
        }
    }
    
    private func showCamera(picker: ImagePicker) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
            present(picker, animated: true, completion: nil)
        }
    }
    
    private func showImagePicker(picker: ImagePicker) {
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
}
