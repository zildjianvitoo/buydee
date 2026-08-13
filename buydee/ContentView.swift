import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var path: [Route] = []
    @State private var chatViewModel = ChatViewModel()
    @State private var homeViewModel = HomeViewModel()
    @State private var showsCamera = false
    @State private var sendsCaptureToChat = false

    private enum Route: Hashable {
        case chat
        case completion(PurchaseDecision, RupiahAmount?)
    }

    var body: some View {
        NavigationStack(path: $path) {
            HomeView(viewModel: homeViewModel, newCheckAction: openHomeCamera)
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .chat:
                        ChatView(
                            viewModel: chatViewModel,
                            onDecision: showCompletion,
                            onCameraRequested: openChatCamera
                        )
                    case .completion(let decision, let consideredPrice):
                        DecisionCompletionView(
                            decision: decision,
                            consideredPriceInRupiah: consideredPrice,
                            language: chatViewModel.conversationLanguage,
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
        .task {
            chatViewModel.configureUserKnowledgeStore(
                SwiftDataUserKnowledgeStore(modelContext: modelContext)
            )
            chatViewModel.configureDecisionHistoryStore(
                SwiftDataDecisionHistoryStore(modelContext: modelContext)
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
        let consideredPrice = chatViewModel.latestConsideredPriceInRupiah

        if decision == .bye, let consideredPrice {
            homeViewModel.addSavings(consideredPrice.value)
        }

        path.append(.completion(decision, consideredPrice))
    }

    private func finishCheck() {
        chatViewModel.startNewConversation()
        path.removeAll()
    }
}

#Preview {
    ContentView()
        .modelContainer(
            for: [UserChatKnowledge.self, PurchaseDecisionRecord.self],
            inMemory: true
        )
}
