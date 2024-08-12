//
//  KeychainClient.swift
//  Data
//
//  Created by 김민호 on 7/30/24.
//

import Foundation

import Dependencies

public enum KeychainKey: String {
    case accessToken
    case refreshToken
    case serverRefresh
}

// MARK: - Dependency Values
extension DependencyValues {
    public var keychain: KeychainClient {
        get { self[KeychainClient.self] }
        set { self[KeychainClient.self] = newValue }
    }
}

// MARK: - KeychainClient Client
public struct KeychainClient {
    public var save: @Sendable (KeychainKey, String) -> Void
    public var read: @Sendable (KeychainKey) -> (String?)
    public var delete: @Sendable (KeychainKey) -> Void
}

extension KeychainClient: DependencyKey {
    public static let liveValue: Self = {
        let controller = KeychainController()
        return Self(
            save: {
                let data = $1.data(using: .utf8)
                if let _ = controller.read($0) {
                    controller.update(data, key: $0)
                    return
                }
                controller.create(data, key: $0)
            },
            read: {
                guard let tokenData = controller.read($0) else { return nil }
                return String(data: tokenData, encoding: .utf8)
            },
            delete: {
                controller.delete($0)
            }
        )
    }()
}

private struct KeychainController {
    let service: String = "Pokit"

    func create(_ data: Data?, key: KeychainKey) {
        guard let data = data else {
            print("🗝️ '\(key)' 값이 없어요.")
            return
        }

        let query: NSDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: key.rawValue,
            kSecValueData: data
        ]

        let status = SecItemAdd(query, nil)
        guard status == errSecSuccess else {
            print("🗝️ '\(key)' 상태 = \(status)")
            return
        }
        print("🗝️ '\(key)' 성공!")
    }

    // MARK: Read Item

    func read(_ key: KeychainKey) -> Data? {
        let query: NSDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: key.rawValue,
            kSecMatchLimit: kSecMatchLimitOne,
            kSecReturnData: true
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query, &result)
        guard status != errSecItemNotFound else {
            print("🗝️ '\(key)' 항목을 찾을 수 없어요.")
            return nil
        }
        guard status == errSecSuccess else {
            return nil
        }
        print("🗝️ '\(key)' 성공!")
        return result as? Data
    }

    // MARK: Update Item

    func update(_ data: Data?, key: KeychainKey) {
        guard let data = data else {
            print("🗝️ '\(key)' 값이 없어요.")
            return
        }

        let query: NSDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: key.rawValue
        ]
        let attributes: NSDictionary = [
            kSecValueData: data
        ]

        let status = SecItemUpdate(query, attributes)
        guard status == errSecSuccess else {
            print("🗝️ '\(key)' 상태 = \(status)")
            return
        }
        print("🗝️ '\(key)' 성공!")
    }

    // MARK: Delete Item

    func delete(_ key: KeychainKey) {
        let query: NSDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: key.rawValue
        ]

        let status = SecItemDelete(query)
        guard status != errSecItemNotFound else {
            print("🗝️ '\(key)' 항목을 찾을 수 없어요.")
            return
        }
        guard status == errSecSuccess else {
            return
        }
        print("🗝️ '\(key)' 성공!")
    }
}
