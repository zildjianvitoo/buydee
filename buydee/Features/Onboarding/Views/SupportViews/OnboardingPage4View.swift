//
//  OnboardingPage4View.swift
//  buydee
//

import SwiftUI

struct OnboardingPage4View: View {
    @Bindable var viewModel: OnboardingViewModel
    var action: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                // 1. Top white background
                Color.buydee.cardBackground.ignoresSafeArea()
                
                // 2. Header text
                Text("Before we go,")
                    .font(.largeTitle) // Dynamic Type
                    .fontWeight(.bold)
                    .foregroundColor(Color.buydee.primaryText)
                    .padding(.top, 40)
                    .padding(.horizontal, 32)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // 3. Otter Illustration (Behind the curve)
                // Tinggi green background adalah 65% dari layar, jadi batasnya di 35% dari atas.
                // Kita posisikan otter sedikit di atas batas itu agar kakinya tertutup lengkungan.
                Image("otter")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 180)
                    .position(x: geometry.size.width / 2, y: geometry.size.height * 0.35 - 30)
                
                // 4. Bottom Green Curved Background
                VStack(spacing: 0) {
                    Spacer(minLength: 0)
                    Color.buydee.background
                        .clipShape(CurveTopShape())
                        .frame(height: geometry.size.height * 0.65)
                }
                .ignoresSafeArea()
                
                // 5. Foreground Content (Text, Cards, Button)
                VStack(spacing: 0) {
                    Spacer(minLength: 0) // Dorong konten ke area hijau (bawah)
                    
                    VStack(spacing: 0) {
                        // Question
                        Text("What would you like to\nkeep it in mind before you buy?")
                            .font(.title3) // Dynamic Type
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color.buydee.primaryText)
                            .padding(.top, 50) // Jarak dari puncak kurva
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
                            .padding(.bottom, 20)
                        }
                        
                        // Meet me button
                        Button(action: action) {
                            Text("Meet me")
                                .font(.headline) // Dynamic Type
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.buydee.primaryButton)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 32)
                        .padding(.bottom, 30)
                        .disabled(viewModel.selectedGoal == nil || (viewModel.selectedGoal == .others && viewModel.customGoalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty))
                        .opacity(viewModel.selectedGoal == nil ? 0.5 : 1.0)
                    }
                    .frame(height: geometry.size.height * 0.65) // Match height dengan green background
                }
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
                        .foregroundColor(Color.buydee.primaryText)
                        .frame(width: 24)
                    
                    Text(goal.rawValue)
                        .font(.body) // Dynamic Type
                        .fontWeight(.medium)
                        .foregroundColor(Color.buydee.primaryText)
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color.buydee.cardBackground)
                .cornerRadius(isSelected && goal == .others ? 16 : 16, corners: isSelected && goal == .others ? [.topLeft, .topRight] : .allCorners)
            }
            .buttonStyle(.plain)
            
            if isSelected && goal == .others {
                TextField("Something else...", text: $customText)
                    .font(.body) // Dynamic Type
                    .foregroundColor(Color.buydee.primaryText)
                    .padding(16)
                    .background(Color.buydee.background.opacity(0.3)) // Subtle background for text field
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

struct CurveTopShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let curveDepth: CGFloat = 40
        // Titik awal di kiri (agak turun)
        path.move(to: CGPoint(x: 0, y: curveDepth))
        // Melengkung ke atas di tengah, lalu turun lagi ke kanan
        path.addQuadCurve(to: CGPoint(x: rect.width, y: curveDepth), control: CGPoint(x: rect.width / 2, y: -curveDepth))
        // Tarik garis ke ujung kanan bawah
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        // Tarik garis ke ujung kiri bawah
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.closeSubpath()
        return path
    }
}
