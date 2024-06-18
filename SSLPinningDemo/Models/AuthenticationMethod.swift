//
//  AuthenticationMethod.swift
//  SSLPinningDemo
//
//  Created by Krunal Patel on 18/06/24.
//

enum AuthenticationMethod {
    case noPinning
    case certificate
    case publicKey
}

extension AuthenticationMethod {
    
    var failureMessage: String {
        switch self {
        case .noPinning:
            "No pinning."
        case .certificate:
            "Invalid certificate."
        case .publicKey:
            "Invalid public key."
        }
    }
}
