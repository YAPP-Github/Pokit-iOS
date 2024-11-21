//
//  VersionClient.swift
//  CoreKit
//
//  Created by 김민호 on 9/10/24.
//

import DependenciesMacros

@DependencyClient
public struct VersionClient {
    public var 버전체크: @Sendable () async throws -> VersionResponse
}

