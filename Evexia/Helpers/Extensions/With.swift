//
//  With.swift
//  Evexia
//
//  Created by Oleksandr Kovalov on 05.09.2021.
//

import Foundation

func with<T>(_ o: T?, doAction: (T) -> Void) {
    if let o = o {
        doAction(o)
    }
}

func with<T>(_ o: inout T, doAction: (T) -> Void) {
    doAction(o)
}

func with<T: Sequence>(_ os: T, doAction: (T.Iterator.Element) -> Void) {
    os.forEach(doAction)
}
