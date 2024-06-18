//
//  APIError.swift
//  SSLPinningDemo
//
//  Created by Krunal Patel on 18/06/24.
//

import Foundation

enum APIError: LocalizedError {
    case unknown(String?)
    case api(APIErrorObject)
    case certificateFailed(String?)
    
    public var errorDescription: String? {
        switch self {
        case .unknown(let message):
            message ?? "An unknown Error occurred."
        case .api(let apiErrorObject):
            apiErrorObject.statusMessage
        case .certificateFailed:
            "Certificate pinning failed."
        }
    }
}

struct APIErrorObject: Decodable {
    let statusCode: Int
    let statusMessage: String
}
