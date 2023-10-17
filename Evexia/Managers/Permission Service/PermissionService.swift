//
//  PermissionService.swift
//  Evexia
//
//  Created by  Artem Klimov on 29.07.2021.
//

import AVFoundation
import Photos
import MediaPlayer

struct PermissionService {
    
    static func getCameraPickerPermissions() -> AVAuthorizationStatus {
        return AVCaptureDevice.authorizationStatus(for: .video)
    }
    
    static func getPhotoLibraryPermissions() -> PHAuthorizationStatus {
        return PHPhotoLibrary.authorizationStatus()
    }
}
