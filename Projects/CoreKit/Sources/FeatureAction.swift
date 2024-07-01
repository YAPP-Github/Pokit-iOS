//
//  FeatureAction.swift
//  CoreKit
//
//  Created by 김민호 on 7/1/24.
//

import Foundation

public protocol FeatureAction {
    associatedtype ViewAction
    associatedtype InnerAction
    associatedtype AsyncAction
    associatedtype ScopeAction
    associatedtype DelegateAction
    
    static func view(_: ViewAction) -> Self
    static func inner(_: InnerAction) -> Self
    static func async(_: AsyncAction) -> Self
    static func scope(_: ScopeAction) -> Self
    static func delegate(_: DelegateAction) -> Self
}
