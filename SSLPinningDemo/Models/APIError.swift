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
    
    public var errorDescription: String? {
        switch self {
        case .unknown(let message):
            if let message = message {
                return message
            } else {
                return "An unknown Error occurred."
            }
        case .api(let apiErrorObject):
            return apiErrorObject.statusMessage
        }
    }
}

struct APIErrorObject: Decodable {
    let statusCode: Int
    let statusMessage: String
}
