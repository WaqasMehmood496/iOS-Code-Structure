//
//  Closure+Generic.swift
//  Evexia
//
//  Created by Oleksandr Kovalov on 30.08.2021.
//

import Foundation

typealias Closure = () -> Void
typealias Closure1<T> = (T) -> Void
typealias Closure2<T, L> = (T, L) -> Void
typealias Closure3<T, L, K> = (T, L, K) -> Void
typealias Closure4<T, L, K, M> = (T, L, K, M) -> Void
