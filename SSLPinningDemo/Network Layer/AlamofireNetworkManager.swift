//
//  AlamofireNetworkManager.swift
//  SSLPinningDemo
//
//  Created by Krunal Patel on 18/06/24.
//

import Foundation
import Alamofire

class AlamofireNetworkManager: NetworkRequestable {
    
    // MARK: - Vars & Lets
    static let shared = AlamofireNetworkManager()
    
    func request<T: Decodable>(url: URL, authenticationMethod: AuthenticationMethod) async throws -> T {
        let session = createAlamofireSession(with: authenticationMethod)
        
        do {
            return try await session.request(url, of: T.self)
        } catch {
            guard let afError = error as? AFError else {
                throw error
            }
            
            switch afError {
            case .serverTrustEvaluationFailed(let reason):
                print(reason)
                throw APIError.pinningFailed(authenticationMethod, afError.localizedDescription)
            default:
                throw error
            }
        }
    }
}

// MARK: - Methods
extension AlamofireNetworkManager {
    
    func createAlamofireSession(with authenticationMethod: AuthenticationMethod) -> Session {
        switch authenticationMethod {
        case .noPinning:
            return Session()
        case .certificate:
            let evaluators: [String: ServerTrustEvaluating] = [
                "api.quotable.io": PinnedCertificatesTrustEvaluator()
            ]
            let manager = ServerTrustManager(evaluators: evaluators)
            return Session(serverTrustManager: manager)
        case .publicKey:
            let evaluators: [String: ServerTrustEvaluating] = [
                "api.quotable.io": PublicKeysTrustEvaluator()
            ]
            let manager = ServerTrustManager(evaluators: evaluators)
            return Session(serverTrustManager: manager)
        }
    }
}

extension Session {
    
    func request<T: Decodable>(
        _ convertible: any URLConvertible,
        method: HTTPMethod = .get,
        headers: [String: String] = [:],
        params: Parameters? = nil,
        of type: T.Type
    ) async throws -> T {
        // Set Encoding
        var encoding: ParameterEncoding = JSONEncoding.default
        switch method {
        case .post:
            encoding = JSONEncoding.default
        case .get:
            encoding = URLEncoding.default
        default:
            encoding = JSONEncoding.default
        }
        
        // You must resume the continuation exactly once
        return try await withCheckedThrowingContinuation { continuation in
            request(
                convertible,
                method: method,
                parameters: params,
                encoding: encoding,
                headers: HTTPHeaders(headers)
            )
            .validate()
            .responseDecodable(of: type) { response in
                switch response.result {
                case let .success(data):
                    continuation.resume(returning: data)
                    
                case let .failure(error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
