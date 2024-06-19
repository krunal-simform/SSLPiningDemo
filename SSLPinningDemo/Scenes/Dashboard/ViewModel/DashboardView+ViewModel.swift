//
//  DashboardView+ViewModel.swift
//  SSLPinningDemo
//
//  Created by Krunal Patel on 18/06/24.
//

import SwiftUI
import Alamofire

@Observable
class DashboardViewModel {
    
    // MARK: - Vars & Lets
    private(set) var quote = "Let's have some words of wisdom..."
    private let urlSessionNetworkManager = URLSessionNetworkManager.shared
    private let afNetworkManager = AlamofireNetworkManager.shared
    private let quoteURL = URL(string: "https://api.quotable.io/quotes/random")!
    private var currentAuthMethod: AuthenticationMethod = .certificate
    private var isURLSession: Bool = true
    @ObservationIgnored var errorTitle: String = ""
    @ObservationIgnored var errorMessage: String?
    var isShowinError: Bool = false {
        didSet {
            if isShowinError == false {
                errorTitle = ""
                errorMessage = nil
            }
        }
    }
    
}

// MARK: - URLSession Methods
extension DashboardViewModel {
    
    private func loadWithURLSession() {
        Task {
            isURLSession = true
            do {
                let quoteResponse: [QuoteResponse] = try await urlSessionNetworkManager.request(url: quoteURL, authenticationMethod: currentAuthMethod)
                quote = quoteResponse[0].content
            } catch let apiError as APIError {
                errorTitle = apiError.errorDescription ?? "Something went wrong."
                if case let .pinningFailed(_, message) = apiError {
                    errorMessage = message
                }
                isShowinError = true
            } catch {
                print("[Error]: ", error.localizedDescription)
            }
        }
    }
    
    private func loadWithAF() {
        Task {
            isURLSession = false
            do {
                let quoteResponse: [QuoteResponse] = try await afNetworkManager.request(url: quoteURL, authenticationMethod: currentAuthMethod)
                quote = quoteResponse[0].content
            } catch let apiError as APIError {
                errorTitle = apiError.errorDescription ?? "Something went wrong."
                isShowinError = true
            } catch let afError as AFError {
                errorTitle = afError.localizedDescription
                isShowinError = true
            } catch {
                print("[Error]: ", error.localizedDescription)
            }
        }
    }
}

// MARK: - Methods
extension DashboardViewModel {
    
    func retry() {
        isURLSession ? loadWithURLSession() : loadWithAF()
    }
}

// MARK: - URLSession Methods
extension DashboardViewModel {
    
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

// MARK: - Alamofire Methods
extension DashboardViewModel {
    
    func loadWithAFNoPinning() {
        currentAuthMethod = .noPinning
        loadWithAF()
    }
    
    func loadWithAFCertificatePinning() {
        currentAuthMethod = .certificate
        loadWithAF()
    }
    
    func loadWithAFPublicKeyPinning() {
        currentAuthMethod = .publicKey
        loadWithAF()
    }
}
