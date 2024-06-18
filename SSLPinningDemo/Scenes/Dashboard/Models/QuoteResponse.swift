//
//  QuoteResponse.swift
//  SSLPinningDemo
//
//  Created by Krunal Patel on 18/06/24.
//

import Foundation

// MARK: - QuoteResponse
struct QuoteResponse: Decodable {
    let content: String
    let author: String
}
