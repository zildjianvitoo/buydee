import SwiftUI

struct DraftImagePreviewView: View {
    let attachment: DraftImageAttachment
    let remove: () -> Void

    var body: some View {
        Group {
            if let image = UIImage(data: attachment.jpegData) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 88, height: 88)
                    .clipShape(.rect(cornerRadius: 20))
                    .accessibilityLabel("Product image ready to send")
            } else {
                ContentUnavailableView(
                    "Image unavailable",
                    systemImage: "photo.badge.exclamationmark"
                )
                .frame(width: 180, height: 88)
            }
        }
        .overlay(alignment: .topTrailing) {
            Button("Remove image", systemImage: "xmark.circle.fill", action: remove)
                .labelStyle(.iconOnly)
                .symbolRenderingMode(.palette)
                .foregroundStyle(
                    Color.buydee.cardBackground,
                    Color.buydee.primaryButton
                )
                .frame(minWidth: 44, minHeight: 44)
                .offset(x: 12, y: -12)
        }
    }
}
