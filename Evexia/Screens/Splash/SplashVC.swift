//
//  SplashVC.swift
//  Evexia
//
//  Created by  Artem Klimov on 27.07.2021.
//

import UIKit

class SplashVC: UIViewController, StoryboardIdentifiable {
    internal var viewModel: SplashViewModel!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.checkLoginState()
    }
}
