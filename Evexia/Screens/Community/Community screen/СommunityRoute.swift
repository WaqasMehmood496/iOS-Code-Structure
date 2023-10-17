//
//  СommunityRoute.swift
//  Evexia
//
//  Created by Oleksandr Kovalov on 03.09.2021.
//

import UIKit

// MARK: - СommunityRoute
protocol СommunityRoute {
    var communityTransition: Transition { get }
    
    func showCommunity()
}

// MARK: - Extension СommunityRoute
extension СommunityRoute where Self: RouterProtocol {
    func showCommunity() {
        let vc = СommunityBuilder.build(injector: injector)
        open(vc, transition: communityTransition)
    }
}
