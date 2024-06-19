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
    @State private var isPickingDocument = false
    @State private var isShowingDeleteAlert = false
    
    // MARK: - Body
    var body: some View {
        VStack {
            Quote(viewModel.quote)
                .preferredColorScheme(.dark)
            
            ScrollView {
                loadingButtons
            }
            .scrollIndicators(.hidden)
            
            certificateManagerView
        }
        .frame(maxHeight: .infinity)
        .fileImporter(isPresented: $isPickingDocument, allowedContentTypes: [.x509Certificate]) { result in
            switch result {
            case .success(let url):
                viewModel.addUserCertificate(url: url)
            case .failure(let error):
                viewModel.userCertificateError = error.localizedDescription
                viewModel.isShowingUserCertificateError = true
            }
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
        .alert(viewModel.userCertificateError, isPresented: $viewModel.isShowingUserCertificateError) {
            Button("OK", role: .cancel) {
                viewModel.isShowingUserCertificateError = false
            }
        }
        .alert("Delete your certificate?", isPresented: $isShowingDeleteAlert) {
            Button("Delete", role: .destructive) {
                viewModel.deleteUserCertificate()
                isShowingDeleteAlert = false
            }
        }
    }
}

// MARK: - Views
extension DashboardView {
    
    @ViewBuilder
    private var certificateManagerView: some View {
        HStack(spacing: 30) {
            Button {
                isPickingDocument = true
            } label: {
                Image(.certificate)
                    .resizable()
            }
            .tint(.white)
            .buttonStyle(BorderedButtonStyle())
            .frame(width: 60, height: 50)
            
            Button {
                isShowingDeleteAlert = true
            } label: {
                Image(systemName: "xmark")
                    .resizable()
                    .padding(4)
            }
            .tint(.orange)
            .buttonStyle(BorderedButtonStyle())
            .frame(width: 60, height: 50)
        }
        .padding(.top, 12)
        .padding(.bottom, 24)
    }
    
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
            
            Divider()
            
            Button {
                viewModel.loadWithTrustKitPublicKeyPinning()
            } label: {
                Text("TrustKit - Public Key Pinning")
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
