//
//  OnboardingPage3View.swift
//  buydee
//
import SwiftUI
struct OnboardingPage3View: View {
    var action: () -> Void
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("So, here's how\nwe'll do it.")
                .font(.buydeeLargeTitle)
                .foregroundColor(Color.buydee.primaryText)
                .padding(.top, 40)
            Text("However you find it, bring it here and we'll think it through with what matters to you in mind.")
                .font(.buydeeBody)
                .foregroundColor(Color.buydee.primaryText)
                .padding(.trailing, 20)
            Spacer()
            ZStack {
                HStack(spacing: 20) {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 140, height: 160)
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 140, height: 160)
                }
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.gray.opacity(0.45))
                    .frame(width: 160, height: 180)
                    .offset(y: 40)
            }
            .frame(maxWidth: .infinity)
            Spacer()
            Button(action: action) {
                Text("Got it")
                    .font(.buydeeHeadline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.buydee.primaryButton)
                    .clipShape(Capsule())
            }
            .padding(.bottom, 20)
        }
        .padding(.horizontal, 32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.buydee.cardBackground)
    }
}
#Preview {
    OnboardingPage3View(action: {})
}
