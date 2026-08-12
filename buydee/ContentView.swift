import SwiftUI

struct ContentView: View {
    @State private var path: [Route] = []
    @State private var chatViewModel = ChatViewModel()
    @State private var showsCamera = false
    @State private var sendsCaptureToChat = false
    @State private var latestConsideredPriceInRupiah = 0

    private enum Route: Hashable {
        case chat
        case completion(PurchaseDecision)
    }

    var body: some View {
        NavigationStack(path: $path) {
            HomeView(newCheckAction: openHomeCamera)
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .chat:
                        ChatView(
                            viewModel: chatViewModel,
                            onDecision: showCompletion,
                            onCameraRequested: openChatCamera
                        )
                    case .completion(let decision):
                        DecisionCompletionView(
                            decision: decision,
                            consideredPriceInRupiah: latestConsideredPriceInRupiah,
                            onDone: finishCheck
                        )
                    }
                }
        }
        .tint(Color.buydee.primaryButton)
        .fullScreenCover(isPresented: $showsCamera) {
            CameraCaptureView(
                onDismiss: dismissCamera,
                onImageCaptured: handleCapturedImage
            )
        }
    }

    private func openHomeCamera() {
        sendsCaptureToChat = false
        showsCamera = true
    }

    private func openChatCamera() {
        sendsCaptureToChat = true
        showsCamera = true
    }

    private func dismissCamera() {
        showsCamera = false
    }

    private func handleCapturedImage(_ image: UIImage) {
        guard let data = image.jpegData(compressionQuality: 0.95) ?? image.pngData() else {
            return
        }

        if !sendsCaptureToChat {
            chatViewModel.startNewConversation()
            path.append(.chat)
        }

        chatViewModel.attachImageData(data)
    }

    private func showCompletion(_ decision: PurchaseDecision) {
        latestConsideredPriceInRupiah = chatViewModel.latestConsideredPriceInRupiah ?? 0
        path.append(.completion(decision))
    }

    private func finishCheck() {
        chatViewModel.startNewConversation()
        path.removeAll()
    }
}

#Preview {
    ContentView()
}
