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
        }
        .alert(isPresented: $viewModel.isShowinError, error: viewModel.apiError) {
            Button("OK", role: .cancel) {
                viewModel.isShowinError = false
            }
        }
    }
}

#Preview {
    DashboardView()
}
