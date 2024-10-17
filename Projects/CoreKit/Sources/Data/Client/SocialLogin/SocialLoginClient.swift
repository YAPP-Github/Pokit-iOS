//
//  SocialLoginClient.swift
//  CoreKit
//
//  Created by 김민호 on 6/25/24.
//

import Foundation
import DependenciesMacros
import UIKit

@DependencyClient
public struct SocialLoginClient {
    public var appleLogin: @Sendable () async throws -> SocialLoginInfo
    public var googleLogin: @Sendable (
        _ root: UIViewController?
    ) async throws -> SocialLoginInfo
    public var getClientSceret: @Sendable () -> String = { "" }
}
