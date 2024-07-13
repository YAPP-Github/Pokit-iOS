//
//  TuistRelease.swift
//  ProjectDescriptionHelpers
//
//  Created by 김도형 on 7/13/24.
//

import Foundation

public enum TuistRelease {
    public static let tuistRelease = ProcessInfo.processInfo.environment["TUIST_RELEASE"]
    public static let isRelease = tuistRelease == "Release"
}
