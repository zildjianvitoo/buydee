import Foundation
import Observation

@MainActor
@Observable
final class ChatViewModel {
    var messages: [ChatMessage] = []
    var draftText = ""
    var draftImage: DraftImageAttachment?
    var isGenerating = false
    var errorMessage: String?

    @ObservationIgnored private let service: any ChatServicing
    @ObservationIgnored private let imageProcessor: ImageAttachmentProcessor
    @ObservationIgnored private let userDefaults: UserDefaults
    @ObservationIgnored private var responseTask: Task<Void, Never>?
    @ObservationIgnored private var imageProcessingTask: Task<Void, Never>?
    @ObservationIgnored private var activeRequestID: UUID?
    @ObservationIgnored private var lastRequestedMessage: ChatMessage?
    @ObservationIgnored private var lastRequestHistory: [ChatMessage] = []
    private(set) var isProcessingImage = false

    init(
        service: any ChatServicing,
        imageProcessor: ImageAttachmentProcessor = ImageAttachmentProcessor(),
        userDefaults: UserDefaults = .standard
    ) {
        self.service = service
        self.imageProcessor = imageProcessor
        self.userDefaults = userDefaults
    }

    convenience init() {
        self.init(service: OpenRouterChatService())
    }

    var canSend: Bool {
        (!cleanDraftText.isEmpty || draftImage != nil)
            && !isGenerating
            && !isProcessingImage
    }

    var canAttachImage: Bool {
        !isGenerating && !isProcessingImage
    }

    var canRetry: Bool {
        !isGenerating && errorMessage != nil && lastRequestedMessage != nil
    }

    var canOfferEarlyDecision: Bool {
        completedRoundTripCount >= 2
            && !messages.contains { $0.decisionSummary != nil }
            && !isGenerating
    }

    var latestConsideredPriceInRupiah: Int? {
        messages.reversed().lazy
            .compactMap(\.decisionSummary)
            .compactMap { RupiahCurrency.firstAmount(in: $0.context) }
            .first
    }

    func sendMessage() {
        guard canSend else { return }

        let text = cleanDraftText
        let imageData = draftImage?.jpegData
        guard imageData != nil || !Self.containsHTTPURL(in: text) else {
            errorMessage = Self.unsupportedLinkMessage
            return
        }

        let latestMessage = ChatMessage(
            role: .user,
            content: text,
            imageData: imageData
        )
        let history = messages

        messages.append(latestMessage)
        draftText = ""
        draftImage = nil
        beginResponse(to: latestMessage, history: history)
    }

    func requestEarlySummary() {
        guard canOfferEarlyDecision else { return }

        let request = ChatMessage(role: .user, content: Self.earlySummaryRequest)
        let history = messages
        messages.append(request)
        beginResponse(to: request, history: history)
    }

    @discardableResult
    func chooseDecision(_ decision: PurchaseDecision) -> Bool {
        guard !isGenerating,
              messages.last?.role == .assistant,
              messages.last?.decisionSummary != nil else {
            return false
        }

        let latestMessage = ChatMessage(role: .user, content: decision.apiMessage)
        let history = messages
        messages.append(latestMessage)
        beginResponse(to: latestMessage, history: history)
        return true
    }

    func removeDraftImage() {
        imageProcessingTask?.cancel()
        imageProcessingTask = nil
        isProcessingImage = false
        draftImage = nil
    }

    func retryLastResponse() {
        guard canRetry, let lastRequestedMessage else { return }
        beginResponse(to: lastRequestedMessage, history: lastRequestHistory)
    }

    func cancelActiveRequest() {
        activeRequestID = nil
        responseTask?.cancel()
        responseTask = nil
        isGenerating = false
    }

    func attachImageData(_ data: Data) {
        guard canAttachImage else { return }

        imageProcessingTask?.cancel()
        errorMessage = nil
        isProcessingImage = true
        imageProcessingTask = Task { [weak self] in
            guard let self else { return }
            defer {
                self.isProcessingImage = false
                self.imageProcessingTask = nil
            }

            do {
                let attachment = try await self.imageProcessor.process(data)
                try Task.checkCancellation()
                self.draftImage = attachment
            } catch is CancellationError {
                return
            } catch {
                self.errorMessage = error.localizedDescription
            }
        }
    }

    func startNewConversation() {
        cancelActiveRequest()
        imageProcessingTask?.cancel()
        imageProcessingTask = nil
        isProcessingImage = false
        messages = []
        draftText = ""
        draftImage = nil
        errorMessage = nil
        lastRequestedMessage = nil
        lastRequestHistory = []
    }

    nonisolated static func containsHTTPURL(in text: String) -> Bool {
        guard let detector = try? NSDataDetector(
            types: NSTextCheckingResult.CheckingType.link.rawValue
        ) else {
            return false
        }

        let range = NSRange(text.startIndex..., in: text)
        return detector.matches(in: text, range: range).contains { match in
            guard let scheme = match.url?.scheme?.lowercased() else { return false }
            return scheme == "http" || scheme == "https"
        }
    }

    private var cleanDraftText: String {
        draftText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var completedRoundTripCount: Int {
        var pendingUserMessages = 0
        var completedRoundTrips = 0

        for message in messages {
            switch message.role {
            case .user:
                pendingUserMessages += 1
            case .assistant where pendingUserMessages > 0:
                pendingUserMessages -= 1
                completedRoundTrips += 1
            case .assistant:
                continue
            }
        }

        return completedRoundTrips
    }

    private func beginResponse(to latestMessage: ChatMessage, history: [ChatMessage]) {
        guard !isGenerating else { return }

        let requestID = UUID()
        activeRequestID = requestID
        lastRequestedMessage = latestMessage
        lastRequestHistory = history
        errorMessage = nil
        isGenerating = true

        let goals = userDefaults.string(forKey: "userGoals") ?? ""
        responseTask = Task { [weak self] in
            guard let self else { return }
            defer { self.finishResponse(id: requestID) }

            do {
                let answer = try await self.service.response(
                    to: latestMessage,
                    history: history,
                    goals: goals
                )
                try Task.checkCancellation()
                guard self.activeRequestID == requestID else { return }

                self.messages.append(ChatMessage(role: .assistant, content: answer))
                self.lastRequestedMessage = nil
                self.lastRequestHistory = []
            } catch is CancellationError {
                return
            } catch {
                guard self.activeRequestID == requestID else { return }
                self.errorMessage = error.localizedDescription
            }
        }
    }

    private func finishResponse(id: UUID) {
        guard activeRequestID == id else { return }
        activeRequestID = nil
        responseTask = nil
        isGenerating = false
    }

    private static let unsupportedLinkMessage =
        "Link produk belum bisa dianalisis. Kirim nama produk dan harganya, atau lampirkan gambar produk."

    private static let earlySummaryRequest =
        "Aku siap menentukan pilihan sekarang. Tolong rangkum percakapan ini sesuai format Summary dan tawarkan BUY atau BYE secara netral."
}
