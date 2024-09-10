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
    public static let alertPath: String = "/api/v1/alert"
    public static let versionPath: String = "/api/v1/version"
    
    public static let 공지사항_주소: URL = URL(string: "https://www.notion.so/POKIT-d97c81534b354cfebe677fbf1fbfe2b2")!
    public static let 서비스_이용약관_주소: URL = URL(string: "https://www.notion.so/3bddcd6fd00043abae6b92a50c39b132?pvs=4")!
    public static let 개인정보_처리방침_주소: URL = URL(string: "https://www.notion.so/de3468b3be1744538c22a333ae1d0ec8")!
    public static let 마케팅_정보_수신_주소: URL = URL(string: "https://www.notion.so/bb6d0d6569204d5e9a7b67e5825f9d10")!
    public static let 고객문의_주소: URL = URL(string: "https://www.instagram.com/pokit.official/")!
    
    
    public static var mockImageUrl: String { "https://picsum.photos/\(Int.random(in: 150...250))" }
}
