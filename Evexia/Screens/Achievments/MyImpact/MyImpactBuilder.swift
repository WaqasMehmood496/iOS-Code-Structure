//
//  MyImpactVCFactory.swift
//  Evexia
//
//  Created by Oleksand Kovalov on 15.02.2022.
//  
//

import Foundation
import UIKit
import Swinject

// MARK: - MyImpactVCFactory
final class MyImpactBuilder {
    static func build(injector: Container) -> UIViewController {
        let vc = MyImpactVC.board(name: .impact)
        let repository = MyImpactRepository(achievmentsNetworkProvider: injector.resolve(AchievmentsNetworkProvider.self)!)
        let vm = MyImpactVM(repository: repository)
        
        vc.viewModel = vm

        return vc
    }
}
