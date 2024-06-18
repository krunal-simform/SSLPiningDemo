//
//  NetworkManager.swift
//  SSLPinningDemo
//
//  Created by Krunal Patel on 18/06/24.
//

import Foundation

protocol NetworkRequestable {
    
    func request<T: Decodable>(url: URL) async throws -> T
}


struct URLSessionNetworkManager: NetworkRequestable {
    
    // MARK: - Vars & Lets
    static let shared = URLSessionNetworkManager()
    
    // MARK: - Methods
    func request<T: Decodable>(url: URL) async throws -> T {
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        if data.isEmpty {
            throw APIError.unknown("Data: \(data), but expected: \(T.self)")
        } else {
            do {
                return try JSONDecoder().decode(T.self, from: data)
            } catch let error {
                if let apiErrorObject = try? JSONDecoder().decode(APIErrorObject.self, from: data) {
                    throw APIError.api(apiErrorObject)
                }
                print("DECODING ERROR: ", url.absoluteString, "T: ", T.self, "pain-point: ", error)
                throw error
            }
        }
    }
    
    // MARK: - Initializer
    private init() {}
}
