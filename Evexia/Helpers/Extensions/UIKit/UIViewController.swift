//
//  UIViewController.swift
//  Evexia
//
//  Created by  Artem Klimov on 05.07.2021.
//

import UIKit
import NBBottomSheet

extension UIViewController {
    
    var navBarHeight: CGFloat {
        UIApplication.shared.windows.filter { $0.isKeyWindow }.first?.windowScene?.statusBarManager?.statusBarFrame.size.height ?? 0 + (navigationController?.navigationBar.frame.height ?? 0.0)
    }
    
    func customizeBackButton() {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(image: UIImage(), style: .plain, target: nil, action: nil)
    }
    
    func modalAlert(modalStyle: ModalAlertDecorator, completion: (() -> Void)? = nil, cancel: (() -> Void)? = nil, image: UIImage? = nil) {
        let alert = modalStyle.alert
        
        if cancel != nil || modalStyle.isDismissNeeded {
            let cancelAction = AlertAction(title: modalStyle.dismissTitle ?? "Cancel", style: modalStyle.cancelStyle, action: {
                alert.dismiss(animated: true) {
                    cancel?()
                }
            })
            alert.addAction(cancelAction)
        }
        
        let action = AlertAction(title: modalStyle.actionTitle ?? "Ok", style: modalStyle.actionStyle, action: {
            alert.dismiss(animated: true) {
                modalStyle.action?() ?? completion?()
            }
        })
        alert.addAction(action)
        
        self.present(alert, animated: true)
    }
    
    func showPicker(style: [PickerDataModel], defaultSelected: String? = nil, returns: ((String) -> Void)?) {
        var config = NBBottomSheetConfiguration()
        config.animationDuration = 0.5
        let inserts = self.view.safeAreaInsets.top
        config.sheetSize = .fixed(self.view.bounds.height - inserts)
        
        let sc = NBBottomSheetController(configuration: config)
        let pickerView = PickerBuilder.build(viewStyle: style, defaultSelected: defaultSelected, dataClouser: returns)
        
        sc.present(pickerView, on: self)
    }
    
    func showPermissionDeclineWarning(with message: String) {
        let alert = UIAlertController(title: "Warning".localized(), message: message, preferredStyle: .alert)
        let enableButton = UIAlertAction(title: "Settings".localized(), style: .default, handler: { _ in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
        })
        let cancelButton = UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: nil)
        alert.addAction(cancelButton)
        alert.addAction(enableButton)
        self.present(alert, animated: true)
    }
}
