//
//  URLSessionNetworkManager.swift
//  SSLPinningDemo
//
//  Created by Krunal Patel on 18/06/24.
//

import Foundation

class URLSessionNetworkManager: NetworkRequestable {
    
    // MARK: - Vars & Lets
    static let shared = URLSessionNetworkManager()
    private lazy var session = createURLSession()
    private let delegate = AuthenticationDelegate()
    
    // MARK: - Methods
    func request<T: Decodable>(url: URL) async throws -> T {
        
        do {
            let (data, _) = try await session.data(from: url, delegate: delegate)
            
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
                throw APIError.certificateFailed(delegate.invalidCertificate?.description)
            }
            throw error
        }
    }
    
    // MARK: - Initializer
    private init() {}
}

// MARK: - Private Methods
extension URLSessionNetworkManager {
    
    private func createURLSession() -> URLSession {
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration)
        return session
    }
}

// MARK: - AuthenticationDelegate + URLSessionTaskDelegate
private class AuthenticationDelegate: NSObject, URLSessionTaskDelegate {
    
    private(set) var invalidCertificate: SecCertificate?
    
    // MARK: - Delegate Methods
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge) async -> (URLSession.AuthChallengeDisposition, URLCredential?) {
        
        // Server Trust
        guard let serverTrust = challenge.protectionSpace.serverTrust,
              let certificates = SecTrustCopyCertificateChain(serverTrust) as? [SecCertificate],
              let remoteCertificate = certificates.first else {
            invalidCertificate = nil
            return (URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge, nil)
        }
        
        // Certificate Pinning
        
        // SSL Policy for domain check
        let policy = NSMutableArray()
        policy.add(SecPolicyCreateSSL(true, challenge.protectionSpace.host as CFString))
        
        // Evaluate the Certificate
        let isServerTrusted = SecTrustEvaluateWithError(serverTrust, nil)
        
        // Local and Remote Certificate Data
        let remoteCertificateData = Data(referencing: SecCertificateCopyData(remoteCertificate))
        let localCertificateData = getLocalCertificateData()
        
        if isServerTrusted && remoteCertificateData == localCertificateData {
            print("Certificate pinning successful.")
            let credentials = URLCredential(trust: serverTrust)
            return (URLSession.AuthChallengeDisposition.useCredential, credentials)
        } else {
            print("SSL Pinning failed.")
            invalidCertificate = remoteCertificate
            return (URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge, nil)
        }
    }
    
    private func getLocalCertificateData() -> Data {
        let url = Bundle.main.url(forResource: "api.quotable.io", withExtension: "der")!
        return try! Data(contentsOf: url)
    }
}

extension SecCertificate {
    
    var description: String {
        String(describing: self)
    }
}
