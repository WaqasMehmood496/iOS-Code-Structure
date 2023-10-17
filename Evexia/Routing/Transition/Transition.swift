//
//  Transition.swift
//  Evexia
//
//  Created by  Artem Klimov on 22.06.2021.
//

import Foundation
import UIKit

protocol Transition: AnyObject {
    var viewController: UIViewController? { get set }

    func open(_ viewController: UIViewController)
    func close(_ viewController: UIViewController)
}
