//
//  KeychainManager.swift
//  SSLPinningDemo
//
//  Created by Krunal Patel on 19/06/24.
//

import Foundation

class KeychainManager {
    
    // MARK: - Methods
    static func saveCertificate(_ certificate: Data, label: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassCertificate,
            kSecAttrLabel as String: label,
            kSecValueData as String: certificate
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status != errSecDuplicateItem else {
            throw KeychainError.duplicateEntry
        }
        
        guard status == errSecSuccess else {
            throw KeychainError.unknown(status)
        }
        
        print("Saved item successfully.")
    }
    
    static func getCertificate(label: String) -> SecCertificate? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassCertificate,
            kSecAttrLabel as String: label,
            kSecReturnRef as String: kCFBooleanTrue as Any
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        guard status == errSecSuccess else {
            return nil
        }
        
        return (item as! SecCertificate)
    }
    
    @discardableResult
    static func deleteCertificate(label: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassCertificate,
            kSecAttrLabel as String: label
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess
    }
}
