//
//  NetworkManager.swift
//  SSLPinningDemo
//
//  Created by Krunal Patel on 18/06/24.
//

import Foundation

protocol NetworkRequestable {
    
    func request<T: Decodable>(url: URL, authenticationMethod: AuthenticationMethod) async throws -> T
}
