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
    private(set) var completedDecision: PurchaseDecision?

    @ObservationIgnored private let service: any ChatServicing
    @ObservationIgnored private let imageProcessor: ImageAttachmentProcessor
    @ObservationIgnored private let userDefaults: UserDefaults
    @ObservationIgnored private var userKnowledgeStore: (any UserKnowledgeStoring)?
    @ObservationIgnored private var decisionHistoryStore: (any DecisionHistoryStoring)?
    @ObservationIgnored private var userKnowledge = ""
    @ObservationIgnored private var decisionHistory: [PurchaseDecisionMemory] = []
    @ObservationIgnored private var sessionID = UUID()
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

    func configureUserKnowledgeStore(_ store: any UserKnowledgeStoring) {
        userKnowledgeStore = store

        do {
            userKnowledge = try store.currentKnowledge()
        } catch {
            errorMessage = Self.knowledgeLoadErrorMessage
        }
    }

    func configureDecisionHistoryStore(_ store: any DecisionHistoryStoring) {
        decisionHistoryStore = store

        do {
            decisionHistory = try store.recentDecisions(limit: Self.promptDecisionHistoryLimit)
        } catch {
            errorMessage = Self.decisionHistoryLoadErrorMessage
        }
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

    var latestConsideredPriceInRupiah: RupiahAmount? {
        messages.reversed().lazy
            .compactMap(\.decisionSummary)
            .compactMap(\.consideredPriceInRupiah)
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
              let summary = messages.last?.decisionSummary else {
            return false
        }

        let latestMessage = ChatMessage(role: .user, content: decision.apiMessage)
        let history = messages
        messages.append(latestMessage)
        beginResponse(to: latestMessage, history: history)
        persistDecision(summary, decision: decision)
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

    func consumeCompletedDecision() {
        completedDecision = nil
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
        completedDecision = nil
        sessionID = UUID()
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
                let response = try await self.service.response(
                    to: latestMessage,
                    history: history,
                    goals: goals,
                    userKnowledge: self.userKnowledge,
                    decisionHistory: self.decisionHistory
                )
                try Task.checkCancellation()
                guard self.activeRequestID == requestID else { return }

                self.messages.append(
                    ChatMessage(
                        role: .assistant,
                        content: response.content,
                        decisionMetadata: response.decisionMetadata,
                        selectedDecision: response.selectedDecision
                    )
                )
                self.persistUserKnowledge(response.updatedUserKnowledge)
                self.handleEarlyDecision(from: response)
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

    private func persistUserKnowledge(_ updatedKnowledge: String?) {
        guard let updatedKnowledge else { return }

        do {
            try userKnowledgeStore?.replaceKnowledge(with: updatedKnowledge)
            userKnowledge = updatedKnowledge
        } catch {
            errorMessage = Self.knowledgeSaveErrorMessage
        }
    }

    private func persistDecision(
        _ summary: DecisionSummary,
        decision: PurchaseDecision
    ) {
        let metadata = summary.metadata
        let consideredPrice = summary.consideredPriceInRupiah
        let rangeBounds = consideredPrice?.isEstimated == true
            ? Self.validatedRangeBounds(
                lower: metadata?.priceRangeLower,
                upper: metadata?.priceRangeUpper
            )
            : nil
        let memory = PurchaseDecisionMemory(
            id: UUID(),
            sessionID: sessionID,
            productName: Self.normalized(
                metadata?.productName,
                fallback: Self.unknownProductName,
                maximumLength: 100
            ),
            productCategory: Self.normalizedOptional(
                metadata?.productCategory,
                maximumLength: 80
            ),
            priceInRupiah: consideredPrice?.value,
            originalPriceText: Self.normalizedOptional(
                metadata?.originalPriceText,
                maximumLength: 100
            ),
            priceIsEstimated: consideredPrice?.isEstimated ?? false,
            priceRangeLower: rangeBounds?.lower,
            priceRangeUpper: rangeBounds?.upper,
            decision: decision,
            decidedAt: .now,
            contextSummary: Self.normalized(
                metadata?.contextSummary,
                fallback: summary.content,
                maximumLength: 240
            ),
            prosSummary: Self.normalized(
                metadata?.prosSummary,
                fallback: "",
                maximumLength: 200
            ),
            consSummary: Self.normalized(
                metadata?.consSummary,
                fallback: "",
                maximumLength: 200
            ),
            relatedGoal: Self.normalizedOptional(
                metadata?.relatedGoal,
                maximumLength: 120
            )
        )

        do {
            try decisionHistoryStore?.save(memory)
            decisionHistory.removeAll { $0.sessionID == memory.sessionID }
            decisionHistory.insert(memory, at: 0)
            decisionHistory = Array(decisionHistory.prefix(Self.promptDecisionHistoryLimit))
        } catch {
            errorMessage = Self.decisionHistorySaveErrorMessage
        }
    }

    private func handleEarlyDecision(from response: ChatServiceResponse) {
        guard let selectedDecision = response.selectedDecision,
              let metadata = response.decisionMetadata,
              let summary = DecisionSummary(
                markdown: response.content,
                metadata: metadata,
                requiresChoicePrompt: false
              ) else {
            return
        }

        persistDecision(summary, decision: selectedDecision)
        completedDecision = selectedDecision
    }

    private static func normalized(
        _ value: String?,
        fallback: String,
        maximumLength: Int
    ) -> String {
        normalizedOptional(value, maximumLength: maximumLength)
            ?? normalizedOptional(fallback, maximumLength: maximumLength)
            ?? ""
    }

    private static func normalizedOptional(
        _ value: String?,
        maximumLength: Int
    ) -> String? {
        guard let value else { return nil }
        let normalizedValue = value
            .split(whereSeparator: \Character.isWhitespace)
            .joined(separator: " ")
        guard !normalizedValue.isEmpty else { return nil }
        return String(normalizedValue.prefix(maximumLength))
    }

    private static func validatedRangeBounds(
        lower: Int?,
        upper: Int?
    ) -> (lower: Int, upper: Int)? {
        guard let lower, let upper, lower > 0, upper >= lower else { return nil }
        return (lower, upper)
    }

    private static let unsupportedLinkMessage =
        "Link produk belum bisa dianalisis. Kirim nama produk dan harganya, atau lampirkan gambar produk."

    private static let knowledgeLoadErrorMessage =
        "Konteks dari chat sebelumnya belum berhasil dimuat. Chat ini tetap bisa dilanjutkan."

    private static let knowledgeSaveErrorMessage =
        "Respons sudah diterima, tetapi konteks pentingnya belum berhasil disimpan."

    private static let decisionHistoryLoadErrorMessage =
        "Riwayat keputusan sebelumnya belum berhasil dimuat. Chat ini tetap bisa dilanjutkan."

    private static let decisionHistorySaveErrorMessage =
        "Pilihanmu tetap diproses, tetapi detail keputusan ini belum berhasil disimpan."

    private static let unknownProductName = "Produk dari sesi ini"
    private static let promptDecisionHistoryLimit = 12

    private static let earlySummaryRequest =
        "Aku siap menentukan pilihan sekarang. Jika harga berupa rentang dan nilai tengahnya belum aku konfirmasi, tanyakan konfirmasinya dulu. Jika harganya sudah valid, rangkum secara natural dan singkat sesuai aturan Summary, lalu tawarkan BUY atau BYE secara netral."
}
