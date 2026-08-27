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
    private(set) var conversationLanguage: ChatLanguage
    private(set) var hasStoppedExploration = false

    @ObservationIgnored private let service: any ChatServicing
    @ObservationIgnored private let imageProcessor: ImageAttachmentProcessor
    @ObservationIgnored private let userDefaults: UserDefaults
    @ObservationIgnored private var userKnowledgeStore: (any UserKnowledgeStoring)?
    @ObservationIgnored private var decisionHistoryStore: (any DecisionHistoryStoring)?
    @ObservationIgnored private var userKnowledge = ""
    @ObservationIgnored private var decisionHistory: [PurchaseDecisionMemory] = []
    @ObservationIgnored private var pendingUserKnowledge: String?
    @ObservationIgnored private var sessionID = UUID()
    @ObservationIgnored private var responseTask: Task<Void, Never>?
    @ObservationIgnored private var imageProcessingTask: Task<Void, Never>?
    @ObservationIgnored private var activeRequestID: UUID?
    @ObservationIgnored private var lastRequestedMessage: ChatMessage?
    @ObservationIgnored private var lastRequestHistory: [ChatMessage] = []
    @ObservationIgnored private var lastRequestRequiresSummary = false
    @ObservationIgnored private var hasLockedConversationLanguage = false
    private(set) var isProcessingImage = false

    init(
        service: any ChatServicing,
        imageProcessor: ImageAttachmentProcessor = ImageAttachmentProcessor(),
        userDefaults: UserDefaults = .standard
    ) {
        self.service = service
        self.imageProcessor = imageProcessor
        self.userDefaults = userDefaults
        conversationLanguage = .primaryDefault
    }

    convenience init() {
        self.init(service: OpenRouterChatService())
    }

    func configureUserKnowledgeStore(_ store: any UserKnowledgeStoring) {
        userKnowledgeStore = store

        do {
            userKnowledge = try store.currentKnowledge()
        } catch {
            errorMessage = localized(
                indonesian: "Konteks dari chat sebelumnya belum berhasil dimuat. Chat ini tetap bisa dilanjutkan.",
                english: "Context from earlier chats could not be loaded. You can still continue this chat."
            )
        }
    }

    func configureDecisionHistoryStore(_ store: any DecisionHistoryStoring) {
        decisionHistoryStore = store

        do {
            decisionHistory = try store.recentDecisions(limit: Self.promptDecisionHistoryLimit)
        } catch {
            errorMessage = localized(
                indonesian: "Riwayat keputusan sebelumnya belum berhasil dimuat. Chat ini tetap bisa dilanjutkan.",
                english: "Earlier decisions could not be loaded. You can still continue this chat."
            )
        }
    }

    var canSend: Bool {
        (!cleanDraftText.isEmpty || draftImage != nil)
            && !isGenerating
            && !isProcessingImage
            && !hasStoppedExploration
    }

    var canAttachImage: Bool {
        !isGenerating && !isProcessingImage && !hasStoppedExploration
    }

    var canRetry: Bool {
        !isGenerating && errorMessage != nil && lastRequestedMessage != nil
    }

    var canOfferEarlyDecision: Bool {
        completedRoundTripCount >= 2
            && !messages.contains { $0.decisionSummary != nil }
            && !isGenerating
            && !hasStoppedExploration
    }

    var latestConsideredPriceInRupiah: RupiahAmount? {
        latestKnownPriceInRupiah()
    }

    func sendMessage() {
        guard canSend else { return }

        let text = cleanDraftText
        let imageData = draftImage?.jpegData
        guard imageData != nil || !Self.containsHTTPURL(in: text) else {
            errorMessage = localized(
                indonesian: "Link produk belum bisa dianalisis. Kirim nama produk dan harganya, atau lampirkan gambar produk.",
                english: "Product links cannot be analyzed yet. Send the product name and price, or attach a product image."
            )
            return
        }
        lockConversationLanguageIfNeeded(from: text)

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

        hasStoppedExploration = true
        let request = ChatMessage(
            role: .user,
            content: conversationLanguage.earlySummaryRequest
        )
        let history = messages
        beginResponse(to: request, history: history, requiresSummary: true)
    }

    @discardableResult
    func chooseDecision(_ decision: PurchaseDecision) -> Bool {
        guard !isGenerating,
              messages.last?.role == .assistant,
              let summary = messages.last?.decisionSummary else {
            return false
        }

        let latestMessage = ChatMessage(
            role: .user,
            content: decision.apiMessage(in: conversationLanguage)
        )
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
        beginResponse(
            to: lastRequestedMessage,
            history: lastRequestHistory,
            requiresSummary: lastRequestRequiresSummary
        )
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
                self.errorMessage = self.localizedImageErrorMessage(for: error)
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
        lastRequestRequiresSummary = false
        completedDecision = nil
        pendingUserKnowledge = nil
        hasStoppedExploration = false
        conversationLanguage = .primaryDefault
        hasLockedConversationLanguage = false
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

    private func beginResponse(
        to latestMessage: ChatMessage,
        history: [ChatMessage],
        requiresSummary: Bool = false
    ) {
        guard !isGenerating else { return }

        let requestID = UUID()
        activeRequestID = requestID
        lastRequestedMessage = latestMessage
        lastRequestHistory = history
        lastRequestRequiresSummary = requiresSummary
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
                    decisionHistory: self.decisionHistory,
                    language: self.conversationLanguage
                )
                try Task.checkCancellation()
                guard self.activeRequestID == requestID else { return }

                let contractResponse = requiresSummary
                    ? self.enforcingSummaryContract(on: response)
                    : response
                let resolvedResponse = self.enrichingPriceMetadata(in: contractResponse)
                self.messages.append(
                    ChatMessage(
                        role: .assistant,
                        content: resolvedResponse.content,
                        decisionMetadata: resolvedResponse.decisionMetadata,
                        selectedDecision: resolvedResponse.selectedDecision
                    )
                )
                if let updatedUserKnowledge = resolvedResponse.updatedUserKnowledge {
                    self.pendingUserKnowledge = updatedUserKnowledge
                }
                self.handleEarlyDecision(from: resolvedResponse)
                self.lastRequestedMessage = nil
                self.lastRequestHistory = []
                self.lastRequestRequiresSummary = false
            } catch is CancellationError {
                return
            } catch {
                guard self.activeRequestID == requestID else { return }
                self.errorMessage = self.localizedErrorMessage(for: error)
            }
        }
    }

    private func finishResponse(id: UUID) {
        guard activeRequestID == id else { return }
        activeRequestID = nil
        responseTask = nil
        isGenerating = false
    }

    private func persistPendingUserKnowledge() {
        guard let pendingUserKnowledge else { return }

        do {
            try userKnowledgeStore?.replaceKnowledge(with: pendingUserKnowledge)
            userKnowledge = pendingUserKnowledge
            self.pendingUserKnowledge = nil
        } catch {
            errorMessage = localized(
                indonesian: "Keputusanmu sudah tersimpan, tetapi konteks pentingnya belum berhasil disimpan.",
                english: "Your decision was saved, but its important context could not be saved."
            )
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
                fallback: localized(
                    indonesian: "Produk dari sesi ini",
                    english: "Product from this session"
                ),
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
            errorMessage = localized(
                indonesian: "Pilihanmu tetap diproses, tetapi detail keputusan ini belum berhasil disimpan.",
                english: "Your choice was processed, but the decision details could not be saved."
            )
        }
        persistPendingUserKnowledge()
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

    private func lockConversationLanguageIfNeeded(from text: String) {
        guard !hasLockedConversationLanguage else { return }

        if !text.isEmpty {
            conversationLanguage = ChatLanguage.detected(
                from: text,
                fallback: conversationLanguage
            )
        }
        hasLockedConversationLanguage = true
    }

    private func enforcingSummaryContract(
        on response: ChatServiceResponse
    ) -> ChatServiceResponse {
        if let metadata = response.decisionMetadata,
           DecisionSummary(markdown: response.content, metadata: metadata) != nil {
            return response
        }

        let summaryBody = Self.removingQuestions(from: response.content)
        var visibleSummary = summaryBody.isEmpty
            ? conversationLanguage.insufficientSummary
            : summaryBody
        var content = "\(visibleSummary)\n\n\(conversationLanguage.decisionQuestion)"
        var metadata = metadataWithFallbackPrice(
            response.decisionMetadata,
            contextSummary: visibleSummary
        )
        if DecisionSummary(markdown: content, metadata: metadata) == nil {
            visibleSummary = conversationLanguage.insufficientSummary
            content = "\(visibleSummary)\n\n\(conversationLanguage.decisionQuestion)"
            metadata = metadataWithFallbackPrice(
                nil,
                contextSummary: visibleSummary
            )
        }

        return ChatServiceResponse(
            content: content,
            updatedUserKnowledge: response.updatedUserKnowledge,
            decisionMetadata: metadata,
            selectedDecision: response.selectedDecision
        )
    }

    private static func removingQuestions(from content: String) -> String {
        var keptSentences: [String] = []
        var currentSentence = ""

        for character in content {
            currentSentence.append(character)

            if character == "?" {
                currentSentence = ""
            } else if character == "." || character == "!" || character == "\n" {
                let sentence = currentSentence
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                if !sentence.isEmpty {
                    keptSentences.append(sentence)
                }
                currentSentence = ""
            }
        }

        let remainder = currentSentence
            .trimmingCharacters(in: .whitespacesAndNewlines)
        if !remainder.isEmpty {
            keptSentences.append(remainder)
        }

        return keptSentences
            .joined(separator: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func latestKnownPriceInRupiah() -> RupiahAmount? {
        for message in messages.reversed() {
            if let summaryPrice = message.decisionSummary?.consideredPriceInRupiah {
                return summaryPrice
            }
            if let metadataPrice = message.decisionMetadata?.priceInRupiah,
               metadataPrice > 0 {
                return RupiahAmount(value: metadataPrice, isEstimated: false)
            }
            if let originalPriceText = message.decisionMetadata?.originalPriceText,
               let parsedPrice = RupiahCurrency.firstAmount(in: originalPriceText) {
                return parsedPrice
            }
            if let parsedPrice = RupiahCurrency.firstAmount(in: message.content) {
                return parsedPrice
            }
        }
        return nil
    }

    private func metadataWithFallbackPrice(
        _ metadata: DecisionMetadata?,
        contextSummary: String
    ) -> DecisionMetadata {
        let fallbackPrice = latestKnownPriceInRupiah()
        return DecisionMetadata(
            productName: metadata?.productName,
            productCategory: metadata?.productCategory,
            originalPriceText: metadata?.originalPriceText
                ?? fallbackPrice.map { RupiahCurrency.formatted($0.value) },
            priceInRupiah: metadata?.priceInRupiah ?? fallbackPrice?.value,
            priceRangeLower: metadata?.priceRangeLower,
            priceRangeUpper: metadata?.priceRangeUpper,
            contextSummary: metadata?.contextSummary ?? Self.normalized(
                contextSummary,
                fallback: conversationLanguage.insufficientSummary,
                maximumLength: 240
            ),
            relatedGoal: metadata?.relatedGoal
        )
    }

    private func enrichingPriceMetadata(
        in response: ChatServiceResponse
    ) -> ChatServiceResponse {
        guard let metadata = response.decisionMetadata else { return response }

        let price = metadata.priceInRupiah.map {
            RupiahAmount(value: $0, isEstimated: false)
        }
            ?? metadata.originalPriceText.flatMap(RupiahCurrency.firstAmount)
            ?? RupiahCurrency.firstAmount(in: response.content)
            ?? latestKnownPriceInRupiah()
        guard let price else { return response }

        let enrichedMetadata = DecisionMetadata(
            productName: metadata.productName,
            productCategory: metadata.productCategory,
            originalPriceText: metadata.originalPriceText
                ?? RupiahCurrency.formatted(price.value),
            priceInRupiah: metadata.priceInRupiah ?? price.value,
            priceRangeLower: metadata.priceRangeLower,
            priceRangeUpper: metadata.priceRangeUpper,
            contextSummary: metadata.contextSummary,
            relatedGoal: metadata.relatedGoal
        )
        return ChatServiceResponse(
            content: response.content,
            updatedUserKnowledge: response.updatedUserKnowledge,
            decisionMetadata: enrichedMetadata,
            selectedDecision: response.selectedDecision
        )
    }

    private func localizedErrorMessage(for error: Error) -> String {
        guard let serviceError = error as? ChatServiceError else {
            return error.localizedDescription
        }

        return serviceError.message(in: conversationLanguage)
    }

    private func localizedImageErrorMessage(for error: Error) -> String {
        guard let imageError = error as? ImageAttachmentError else {
            return error.localizedDescription
        }

        return imageError.message(in: conversationLanguage)
    }

    private func localized(indonesian: String, english: String) -> String {
        conversationLanguage.text(indonesian: indonesian, english: english)
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

    private static let promptDecisionHistoryLimit = 12
}
