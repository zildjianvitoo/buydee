//
//  NewCheckButton.swift
//  buydee
//

import SwiftUI

struct NewCheckButton: View {
    // MARK: - Properties
    let action: () -> Void

    // MARK: - Body
    var body: some View {
        Button(action: action) {
            Text("Check It Together")
                .font(.buydeeTitle3)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.buydee.primaryButton)
                .clipShape(RoundedRectangle(cornerRadius: BuydeeRadius.small))
                
        }
        .buttonStyle(.plain)
        .accessibilityHint("Starts a new purchase reflection")
    }
}

#Preview {
    NewCheckButton(action: {})
        .padding()
}
