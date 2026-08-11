//
//  OnboardingPage4View.swift
//  buydee
//

import SwiftUI

struct OnboardingPage4View: View {
    @Bindable var viewModel: OnboardingViewModel
    var action: () -> Void
    
    var body: some View {
        ZStack {
            // Background
            VStack(spacing: 0) {
                Color.buydee.cardBackground
                    .frame(height: 300)
                
                GeometryReader { geometry in
                    ZStack(alignment: .top) {
                        Color.buydee.background
                        
                        // Simulated curve
                        Ellipse()
                            .fill(Color.buydee.cardBackground)
                            .frame(width: geometry.size.width * 1.5, height: 200)
                            .offset(y: -100)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped() // Mencegah background melebar dan mengacaukan TabView
                }
            }
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                // Header text
                VStack(alignment: .leading) {
                    Text("Before we go,")
                        .font(.largeTitle) // Dynamic Type
                        .fontWeight(.bold)
                        .foregroundColor(Color.buydee.primaryText)
                        .padding(.top, 40)
                        .padding(.horizontal, 32)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                // Otter Placeholder Illustration
                Image(systemName: "seal.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .foregroundColor(Color.buydee.primaryButton)
                    .padding(.top, 20)
                
                // Question
                Text("What would you like to\nkeep it in mind before you buy?")
                    .font(.title3) // Dynamic Type
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color.buydee.primaryText)
                    .padding(.top, 20)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 24)
                
                // Options List
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(OnboardingGoal.allCases) { goal in
                            GoalSelectionRow(
                                goal: goal,
                                isSelected: viewModel.selectedGoal == goal,
                                customText: $viewModel.customGoalText
                            ) {
                                viewModel.selectGoal(goal)
                            }
                        }
                    }
                    .padding(.horizontal, 32)
                }
                
                Spacer()
                
                Button(action: action) {
                    Text("Meet me")
                        .font(.headline) // Dynamic Type
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.buydee.primaryButton)
                        .clipShape(Capsule())
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 20)
                .disabled(viewModel.selectedGoal == nil || (viewModel.selectedGoal == .others && viewModel.customGoalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty))
                .opacity(viewModel.selectedGoal == nil ? 0.5 : 1.0)
            }
        }
    }
}

// MARK: - Support View
struct GoalSelectionRow: View {
    let goal: OnboardingGoal
    let isSelected: Bool
    @Binding var customText: String
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: action) {
                HStack(spacing: 16) {
                    Image(systemName: goal.iconName)
                        .font(.title3)
                        .foregroundColor(Color(red: 0.1, green: 0.2, blue: 0.35)) // Dark navy blue as per design
                        .frame(width: 24)
                    
                    Text(goal.rawValue)
                        .font(.body) // Dynamic Type
                        .fontWeight(.medium)
                        .foregroundColor(Color(red: 0.1, green: 0.2, blue: 0.35))
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color.buydee.cardBackground)
                .cornerRadius(isSelected && goal == .others ? 16 : 16, corners: isSelected && goal == .others ? [.topLeft, .topRight] : .allCorners)
            }
            .buttonStyle(.plain) // Wajib agar layout Button tidak hancur di dalam ScrollView
            
            if isSelected && goal == .others {
                TextField("Something else...", text: $customText)
                    .font(.body) // Dynamic Type
                    .padding(16)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                    .background(Color.buydee.cardBackground)
                    .cornerRadius(16, corners: [.bottomLeft, .bottomRight])
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isSelected ? Color.buydee.primaryButton : Color.clear, lineWidth: 2)
        )
        // Add subtle shadow for the cards
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - View Extension for Corners
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
