//
//  Constants.swift
//  Util
//
//  Created by 김민호 on 7/26/24.
//

import Foundation

public enum Constants {
    public static let serverURL: URL = URL(string: "https://pokit.site")!
    public static let userPath: String = "/api/v1/user"
    public static let authPath: String = "/api/v1/auth"
    public static let categoryPath: String = "/api/v1/category"
    public static let contentPath: String = "/api/v1/content"
    public static let remindPath: String = "api/v1/remind"
    
    public static var mockImageUrl: String { "https://picsum.photos/\(Int.random(in: 150...250))" }
}
