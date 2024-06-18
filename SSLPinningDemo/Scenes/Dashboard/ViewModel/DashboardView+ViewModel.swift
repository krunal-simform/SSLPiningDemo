//
//  DashboardView+ViewModel.swift
//  SSLPinningDemo
//
//  Created by Krunal Patel on 18/06/24.
//

import SwiftUI

@Observable
class DashboardViewModel {
    
    // MARK: - Vars & Lets
    private(set) var quote = "Let's have some words of wisdom..."
    private let urlSessionNetworkManager = URLSessionNetworkManager.shared
    private let quoteURL = URL(string: "https://api.quotable.io/quotes/random")!
    private var currentAuthMethod: AuthenticationMethod = .certificate
    @ObservationIgnored var apiError: APIError?
    var isShowinError: Bool = false {
        didSet {
            if isShowinError == false {
                apiError = nil
            }
        }
    }
}

// MARK: - URLSession Methods
extension DashboardViewModel {
    
    private func loadWithURLSession() {
        Task {
            await loadRandomThought()
        }
    }
    
    private func loadRandomThought() async {
        do {
            let quoteResponse: [QuoteResponse] = try await urlSessionNetworkManager.request(url: quoteURL, authenticationMethod: currentAuthMethod)
            quote = quoteResponse[0].content
        } catch let apiError as APIError {
            self.apiError = apiError
            isShowinError = true
        } catch {
            print("[Error]: ", error.localizedDescription)
        }
    }
}

// MARK: - Methods
extension DashboardViewModel {
    
    func retry() {
        Task {
            await loadRandomThought()
        }
    }
    
    func loadWithURLSessionNoPinning() {
        currentAuthMethod = .noPinning
        loadWithURLSession()
    }
    
    func loadWithURLSessionCertificatePinning() {
        currentAuthMethod = .certificate
        loadWithURLSession()
    }
    
    func loadWithURLSessionPublicKeyPinning() {
        currentAuthMethod = .publicKey
        loadWithURLSession()
    }
}
