//
//  ModalAlertDecorator.swift
//  Evexia
//
//  Created by  Artem Klimov on 07.07.2021.
//

import UIKit

protocol ModalAlert: AnyObject {
    func addAction(_ action: AlertAction)
}

protocol ModalAlertDecorator {
    var alert: ModalAlertController { get }
    var actionTitle: String? { get }
    var dismissTitle: String? { get }
    var actionStyle: AlertActionStyle { get }
    var cancelStyle: AlertActionStyle { get }
    var action: (() -> Void)? { get }
    var isDismissNeeded: Bool { get }
}
