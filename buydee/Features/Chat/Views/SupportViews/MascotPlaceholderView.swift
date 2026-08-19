import SwiftUI

struct MascotPlaceholderView: View {
    let width: Double
    let height: Double

    var body: some View {
        Rectangle()
            .fill(Color.buydee.chatMascotPlaceholder)
            .frame(width: width, height: height)
            .accessibilityHidden(true)
    }
}

#Preview {
    MascotPlaceholderView(width: 64, height: 64)
}
