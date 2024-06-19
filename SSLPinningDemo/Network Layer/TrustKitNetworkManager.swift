//
//  TrustKitNetworkManager.swift
//  SSLPinningDemo
//
//  Created by Krunal Patel on 19/06/24.
//

import Foundation
import TrustKit

class TrustKitNetworkManager: NetworkRequestable {
    
    // MARK: - Vars & Lets
    static let shared = TrustKitNetworkManager()
    private var session: URLSession!
    
    // MARK: - Methods
    func request<T>(url: URL, authenticationMethod: AuthenticationMethod) async throws -> T where T : Decodable {
        session = URLSession(configuration: .ephemeral, delegate: AuthenticationDelegate(method: authenticationMethod), delegateQueue: nil)
        do {
            let (data, _) = try await session.data(from: url)
            
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
                    throw APIError.unknown(error.localizedDescription)
                }
            }
        } catch {
            if error.localizedDescription == "cancelled" {
                throw APIError.pinningFailed(authenticationMethod, nil)
            }
            throw error
        }
    }
    
    // MARK: - Initializer
    private init() {
        let trustKitConfig = [
            kTSKSwizzleNetworkDelegates: false,
            kTSKPinnedDomains: [
                "api.quotable.io": [
                    kTSKEnforcePinning: true,
                    kTSKPublicKeyHashes: [
                        "n1LbOnAI6SOy82FR17x5jpF63+Q0hL3epJF0clFKcnY=",
                        "ndajskdbn3NwednkQWEdnqwnQWddwfWee33232dwe4f="
                    ],]]] as [String : Any]
        
        TrustKit.initSharedInstance(withConfiguration:trustKitConfig)
        
        session = URLSession(configuration: .ephemeral)
    }
}


// MARK: - AuthenticationDelegate + URLSessionTaskDelegate
private class AuthenticationDelegate: NSObject, URLSessionDelegate {
    
    let method: AuthenticationMethod
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard method != .noPinning else {
            completionHandler(.performDefaultHandling, nil)
            return
        }
        
        let pinningValidator = TrustKit.sharedInstance().pinningValidator
        
        if (!pinningValidator.handle(challenge, completionHandler: completionHandler)) {
            // TrustKit did not handle this challenge: perhaps it was not for server trust
            // or the domain was not pinned. Fall back to the default behavior
            completionHandler(.performDefaultHandling, nil)
        }
    }
    
    // MARK: - Initializer
    init(method: AuthenticationMethod = .publicKey) {
        self.method = method
    }
}
