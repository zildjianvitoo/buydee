//
//  OnboardingPage4View.swift
//  buydee
//
import SwiftUI
struct OnboardingPage4View: View {
    @Bindable var viewModel: OnboardingViewModel
    var action: () -> Void
    
    @FocusState private var focusedField: OnboardingGoal?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                Color.buydee.cardBackground.ignoresSafeArea()
                
                Text("Before we go,")
                    .font(.buydeeLargeTitle)
                    .foregroundColor(Color.buydee.primaryText)
                    .padding(.top, 40)
                    .padding(.horizontal, 32)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                
                Image("otter")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 250)
                    .position(x: geometry.size.width / 2, y: geometry.size.height * 0.25 + 30)
                
                
                VStack(spacing: 0) {
                    Spacer(minLength: 0)
                    
                    ZStack(alignment: .top) {
                        
                        Color.buydee.background
                            .clipShape(CurveTopShape())
                            .ignoresSafeArea(edges: .bottom)
                        
                       
                        VStack(spacing: 0) {
                            Text("What would you like to\nkeep it in mind before you buy?")
                                .font(.buydeeTitle2)
                                .multilineTextAlignment(.center)
                                .foregroundColor(Color.buydee.primaryText)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.top, 30)
                                .padding(.horizontal, 32)
                                .padding(.bottom, 24)
                            
                            ScrollView {
                                VStack(spacing: 12) {
                                    ForEach(OnboardingGoal.allCases) { goal in
                                        GoalSelectionRow(
                                            goal: goal,
                                            isSelected: viewModel.selectedGoal == goal,
                                            customText: $viewModel.customGoalText,
                                            focusedField: $focusedField
                                        ) {
                                            viewModel.selectGoal(goal)
                                        }
                                    }
                                }
                                .padding(.horizontal, 32)
                                .padding(.bottom, 20)
                            }
                            .scrollDisabled(true)
                            .scrollIndicators(.hidden)
                            
                            Spacer(minLength: 0)
                            
                            let isDisabled = viewModel.selectedGoal == nil || viewModel.customGoalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            
                            Button(action: action) {
                                Text("Meet me")
                                    .font(.buydeeHeadline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(isDisabled ? Color.gray.opacity(0.6) : Color.buydee.primaryButton)
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal, 32)
                            .padding(.bottom, 54) // Menyamakan posisi dengan page 3 (safe area bottom ~34 + 20)
                            .disabled(isDisabled)
                        }
                    }
                    .frame(height: geometry.size.height * 0.75) // 3/4 Screen
                }
                .ignoresSafeArea(edges: .bottom)
            }
            .offset(y: focusedField != nil ? -180 : 0)
            .animation(.easeOut(duration: 0.25), value: focusedField)
        }
        .ignoresSafeArea(.keyboard)
    }
}
// MARK: - Support View
struct GoalSelectionRow: View {
    let goal: OnboardingGoal
    let isSelected: Bool
    @Binding var customText: String
    var focusedField: FocusState<OnboardingGoal?>.Binding
    var action: () -> Void
    var body: some View {
        VStack(spacing: 0) {
            Button(action: action) {
                HStack(spacing: 16) {
                    Image(systemName: goal.iconName)
                        .font(.title3)
                        .foregroundColor(Color.buydee.primaryText)
                        .frame(width: 24)
                    Text(goal.rawValue)
                        .font(.buydeeBody)
                        .foregroundColor(Color.buydee.primaryText)
                    Spacer()
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 20)
                .background(Color.buydee.cardBackground)
                .cornerRadius(16, corners: isSelected ? [.topLeft, .topRight] : .allCorners)
            }
            .buttonStyle(.plain)
            if isSelected {
                TextField(goal == .others ? "Something else..." : "Name your goal...", text: $customText)
                    .focused(focusedField, equals: goal)
                    .font(.buydeeBody)
                    .foregroundColor(Color.buydee.primaryText)
                    .padding(16)
                    .background(Color.buydee.background.opacity(0.3))
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
        let curveDepth: CGFloat = 20
        path.move(to: CGPoint(x: 0, y: curveDepth))
        path.addQuadCurve(to: CGPoint(x: rect.width, y: curveDepth), control: CGPoint(x: rect.width / 2, y: -curveDepth))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.closeSubpath()
        return path
    }
}
#Preview {
    OnboardingPage4View(viewModel: OnboardingViewModel(), action: {})
}
