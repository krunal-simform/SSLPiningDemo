//
//  KeychainError.swift
//  SSLPinningDemo
//
//  Created by Krunal Patel on 19/06/24.
//

import Foundation

enum KeychainError: LocalizedError {
    case duplicateEntry
    case unknown(OSStatus)
    
    var errorDescription: String? {
        switch self {
        case .duplicateEntry:
            "Provided data entry already exist."
        case .unknown(let osStatus):
            "Unknown error with status code \(osStatus)"
        }
    }
}
