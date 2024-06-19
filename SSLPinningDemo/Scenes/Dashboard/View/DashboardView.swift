//
//  DashboardView.swift
//  SSLPinningDemo
//
//  Created by Krunal Patel on 18/06/24.
//

import SwiftUI

struct DashboardView: View {

    // MARK: - Vars & Lets
    @State private var viewModel = DashboardViewModel()
    
    // MARK: - Body
    var body: some View {
        VStack {
            Quote(viewModel.quote)
                .preferredColorScheme(.dark)
            
            Spacer()
            
            loadingButtons
        }
        .alert(viewModel.errorTitle, isPresented: $viewModel.isShowinError) { 
            Button("Retry") {
                viewModel.isShowinError = false
                viewModel.retry()
            }
            
            Button("OK", role: .cancel) {
                viewModel.isShowinError = false
            }
        } message: {
            if let message = viewModel.errorMessage {
                Text(message)
            }
        }
    }
}

// MARK: - Views
extension DashboardView {
    
    @ViewBuilder
    private var loadingButtons: some View {
        VStack(spacing: 24) {
            Divider()
            
            Button {
                viewModel.loadWithURLSessionNoPinning()
            } label: {
                Text("URLSession - Without Pinning")
                    .frame(minWidth: 276)
                    .padding(.vertical, 8)
            }
            .buttonStyle(BorderedButtonStyle())
            
            Button {
                viewModel.loadWithURLSessionCertificatePinning()
            } label: {
                Text("URLSession - Certificate Pinning")
                    .frame(minWidth: 276)
                    .padding(.vertical, 8)
            }
            .buttonStyle(BorderedButtonStyle())
            
            Button {
                viewModel.loadWithURLSessionPublicKeyPinning()
            } label: {
                Text("URLSession - Public Key Pinning")
                    .frame(minWidth: 276)
                    .padding(.vertical, 8)
            }
            .buttonStyle(BorderedButtonStyle())
            
            Divider()
            
            Button {
                viewModel.loadWithAFNoPinning()
            } label: {
                Text("Alamofire - Without Pinning")
                    .frame(minWidth: 276)
                    .padding(.vertical, 8)
            }
            .buttonStyle(BorderedButtonStyle())
            
            Button {
                viewModel.loadWithAFCertificatePinning()
            } label: {
                Text("Alamofire - Certificate Pinning")
                    .frame(minWidth: 276)
                    .padding(.vertical, 8)
            }
            .buttonStyle(BorderedButtonStyle())
            
            Button {
                viewModel.loadWithAFPublicKeyPinning()
            } label: {
                Text("Alamofire - Public Key Pinning")
                    .frame(minWidth: 276)
                    .padding(.vertical, 8)
            }
            .buttonStyle(BorderedButtonStyle())
        }
    }
}

// MARK: - Preview
#Preview {
    DashboardView()
}
