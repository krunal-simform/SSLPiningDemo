//
//  URLSessionNetworkManager.swift
//  SSLPinningDemo
//
//  Created by Krunal Patel on 18/06/24.
//

import Foundation
import Security
import CommonCrypto

class URLSessionNetworkManager: NetworkRequestable {
    
    // MARK: - Vars & Lets
    static let shared = URLSessionNetworkManager()
    private lazy var session = createURLSession()
    
    // MARK: - Methods
    func request<T: Decodable>(url: URL, authenticationMethod: AuthenticationMethod = .certificate) async throws -> T {
        let delegate = AuthenticationDelegate(method: authenticationMethod)
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
                let description = authenticationMethod == .certificate ? delegate.invalidCertificate?.description : nil
                throw APIError.pinningFailed(authenticationMethod, description)
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
    
    let method: AuthenticationMethod
    private(set) var invalidCertificate: SecCertificate?
    private let publicKeyHash = "n1LbOnAI6SOy82FR17x5jpF63+Q0hL3epJF0clFKcnY="
    let rsa2048Asn1Header:[UInt8] = [
//        0x2d, 0x6e, 0x20, 0x6e, 0x31, 0x4c,
//        0x62, 0x4f, 0x6e, 0x41, 0x49, 0x36,
//        0x53, 0x4f, 0x79, 0x38, 0x32, 0x46,
//        0x52, 0x31, 0x37, 0x78, 0x35, 0x6a
        0x30, 0x82, 0x01, 0x22, 0x30, 0x0d,
        0x06, 0x09, 0x2a, 0x86, 0x48, 0x86,
        0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05,
        0x00, 0x03, 0x82, 0x01, 0x0f, 0x00
    ]
    
    // MARK: - Delegate Methods
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge) async -> (URLSession.AuthChallengeDisposition, URLCredential?) {
        
        return switch method {
        case .noPinning:
            (URLSession.AuthChallengeDisposition.performDefaultHandling, nil)
        case .certificate:
            performCertificatePinning(with: challenge)
        case .publicKey:
            performPublicKeyPinning(with: challenge)
        }
        
    }
    
    private func performCertificatePinning(with challenge: URLAuthenticationChallenge) -> (URLSession.AuthChallengeDisposition, URLCredential?) {
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
    
    private func performPublicKeyPinning(with challenge: URLAuthenticationChallenge) -> (URLSession.AuthChallengeDisposition, URLCredential?) {
        // Server Trust
        guard let serverTrust = challenge.protectionSpace.serverTrust,
              let certificates = SecTrustCopyCertificateChain(serverTrust) as? [SecCertificate],
              let remoteCertificate = certificates.first else {
            invalidCertificate = nil
            return (URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge, nil)
        }
        
        // Public key pinning
        let serverPublicKey = SecCertificateCopyKey(remoteCertificate)
        let serverPublicKeyData:NSData = SecKeyCopyExternalRepresentation(serverPublicKey!, nil)!
        let keyHash = sha256(data: serverPublicKeyData as Data)
        if (keyHash == publicKeyHash) {
            print("Public Key Pinning successful.")
            let credentials = URLCredential(trust: serverTrust)
            return (URLSession.AuthChallengeDisposition.useCredential, credentials)
        } else {
            print("Public Key Pinning failed.")
            return (URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge, nil)
        }
    }
    
    private func sha256(data : Data) -> String {
        var keyWithHeader = Data(rsa2048Asn1Header)
        keyWithHeader.append(data)
        var hash = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
        keyWithHeader.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(keyWithHeader.count), &hash)
        }
        return Data(hash).base64EncodedString()
    }
    
    // MARK: - Initializer
    init(method: AuthenticationMethod = .certificate) {
        self.method = method
    }
}

extension SecCertificate {
    
    var description: String {
        String(describing: self)
    }
}
