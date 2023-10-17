//
//  Animator.swift
//  Evexia
//
//  Created by  Artem Klimov on 22.06.2021.
//

import UIKit

protocol AnimatorProtocol: UIViewControllerAnimatedTransitioning {
    var isPresenting: Bool { get set }
}
