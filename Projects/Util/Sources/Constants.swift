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
    
    public static let 공지사항_주소: URL = URL(string: "https://www.naver.com")!
    public static let 서비스_이용약관_주소: URL = URL(string: "https://www.naver.com")!
    public static let 개인정보_처리방침_주소: URL = URL(string: "https://www.naver.com")!
    public static let 고객문의_주소: URL = URL(string: "https://www.naver.com")!
    
    
    public static var mockImageUrl: String { "https://picsum.photos/\(Int.random(in: 150...250))" }
}
