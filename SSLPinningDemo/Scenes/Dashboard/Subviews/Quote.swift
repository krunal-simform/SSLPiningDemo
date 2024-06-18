//
//  Quote.swift
//  SSLPinningDemo
//
//  Created by Krunal Patel on 18/06/24.
//

import SwiftUI

struct Quote: View {
    
    // MARK: - lets
    let quote: String
    
    // MARK: - Body
    var body: some View {
        
        Text(quote)
            .italic()
            .frame(maxWidth: .infinity, minHeight: 40)
            .padding(16)
            .overlay {
                RoundedRectangle(cornerSize: CGSize(width: 6, height: 6))
                    .inset(by: 2)
                    .stroke(.green, lineWidth: 2)
                    .padding(.horizontal, 8)
            }
    }
    
    // MARK: - Initializer
    init(_ quote: String) {
        self.quote = quote
    }
}

#Preview {
    Quote("The only real mistake is the one from which we learn nothing.")
}
