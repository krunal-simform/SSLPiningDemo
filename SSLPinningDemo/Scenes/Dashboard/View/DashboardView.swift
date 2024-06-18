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
        .alert(isPresented: $viewModel.isShowinError, error: viewModel.apiError) { _ in
            Button("Retry") {
                viewModel.isShowinError = false
                viewModel.retry()
            }
            
            Button("OK", role: .cancel) {
                viewModel.isShowinError = false
            }
        } message: { error in
            if case let .pinningFailed(_, certificate) = error,
            let certificate {
                Text(certificate)
            }
        }
    }
}

// MARK: - Views
extension DashboardView {
    
    @ViewBuilder
    private var loadingButtons: some View {
        VStack(spacing: 24) {
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
        }
    }
}

// MARK: - Preview
#Preview {
    DashboardView()
}
