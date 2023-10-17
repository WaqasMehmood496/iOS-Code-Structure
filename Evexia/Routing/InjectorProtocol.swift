//
//  InjectorProtocol.swift
//  Evexia
//
//  Created by  Artem Klimov on 22.06.2021.
//

import Swinject

protocol InjectorProtocol {
    var injector: Container { get set }
}
