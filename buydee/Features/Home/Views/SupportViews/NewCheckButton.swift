//
//  NewCheckButton.swift
//  buydee
//

import SwiftUI

struct NewCheckButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("Check It Together")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.buydee.primaryButton)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .shadow(
                    color: Color.black.opacity(0.22),
                    radius: 8,
                    x: 0,
                    y: 4
                )
        }
        .buttonStyle(.plain)
        .accessibilityHint("Starts a new purchase reflection")
    }
}

#Preview {
    NewCheckButton(action: {})
        .padding()
}
