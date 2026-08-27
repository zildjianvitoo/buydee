import Foundation

struct OpenRouterChatService: ChatServicing {
    private let configuration: AIConfiguration
    private let credentialStore: OpenRouterCredentialStore
    private let session: URLSession

    init(
        configuration: AIConfiguration = .default,
        credentialStore: OpenRouterCredentialStore = OpenRouterCredentialStore(),
        session: URLSession = .shared
    ) {
        self.configuration = configuration
        self.credentialStore = credentialStore
        self.session = session
    }

    func response(
        to latestMessage: ChatMessage,
        history: [ChatMessage],
        goals: String,
        userKnowledge: String,
        decisionHistory: [PurchaseDecisionMemory],
        language: ChatLanguage
    ) async throws -> ChatServiceResponse {
        try Task.checkCancellation()

        var requestMessages = [
            Request.Message(
                role: .developer,
                content: .text(
                    DeveloperPrompt.render(
                        goals: goals,
                        userKnowledge: userKnowledge,
                        decisionHistory: decisionHistory,
                        language: language
                    )
                )
            )
        ]
        requestMessages += history
            .suffix(configuration.maximumHistoryCount)
            .map { makeRequestMessage(from: $0, language: language) }
        requestMessages.append(makeRequestMessage(from: latestMessage, language: language))

        let body = Request(
            model: configuration.model,
            messages: requestMessages,
            maximumTokens: configuration.maximumOutputTokens,
            reasoning: Request.Reasoning(
                effort: configuration.reasoningEffort,
                exclude: configuration.excludesReasoningFromResponse
            ),
            stream: false
        )

        var request = URLRequest(url: configuration.endpoint)
        request.httpMethod = "POST"
        request.timeoutInterval = configuration.timeout
        request.setValue(
            "Bearer \(try credentialStore.apiKey())",
            forHTTPHeaderField: "Authorization"
        )
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)

        do {
            let (data, response) = try await session.data(for: request)
            try Task.checkCancellation()

            guard let httpResponse = response as? HTTPURLResponse else {
                throw ChatServiceError.invalidResponse
            }
            guard (200..<300).contains(httpResponse.statusCode) else {
                throw ChatServiceError.requestFailed(statusCode: httpResponse.statusCode)
            }

            let decodedResponse: Response
            do {
                decodedResponse = try JSONDecoder().decode(Response.self, from: data)
            } catch {
                throw ChatServiceError.invalidResponse
            }

            guard let answer = decodedResponse.firstNonemptyText else {
                throw ChatServiceError.emptyResponse
            }
            let parsedResponse = ChatServiceResponse(rawContent: answer)
            guard !parsedResponse.content.isEmpty else {
                throw ChatServiceError.emptyResponse
            }
            return parsedResponse
        } catch is CancellationError {
            throw CancellationError()
        } catch let error as URLError where error.code == .cancelled {
            throw CancellationError()
        }
    }

    private func makeRequestMessage(
        from message: ChatMessage,
        language: ChatLanguage
    ) -> Request.Message {
        let role: Role = message.role == .user ? .user : .assistant
        let trimmedContent = message.content.trimmingCharacters(in: .whitespacesAndNewlines)

        guard let imageData = message.imageData else {
            return Request.Message(role: role, content: .text(trimmedContent))
        }

        let caption = trimmedContent.isEmpty ? language.imageOnlyCaption : trimmedContent
        let attachment = DraftImageAttachment(jpegData: imageData)
        return Request.Message(
            role: role,
            content: .parts([
                .text(caption),
                .image(url: attachment.dataURL)
            ])
        )
    }

}

private extension OpenRouterChatService {
    struct Request: Encodable {
        let model: String
        let messages: [Message]
        let maximumTokens: Int
        let reasoning: Reasoning
        let stream: Bool

        enum CodingKeys: String, CodingKey {
            case model
            case messages
            case maximumTokens = "max_tokens"
            case reasoning
            case stream
        }

        struct Reasoning: Encodable {
            let effort: ReasoningEffort
            let exclude: Bool
        }

        struct Message: Encodable {
            let role: Role
            let content: Content
        }

        enum Content: Encodable {
            case text(String)
            case parts([Part])

            func encode(to encoder: Encoder) throws {
                var container = encoder.singleValueContainer()
                switch self {
                case .text(let text):
                    try container.encode(text)
                case .parts(let parts):
                    try container.encode(parts)
                }
            }
        }

        struct Part: Encodable {
            let type: PartType
            let text: String?
            let imageURL: ImageURL?

            enum CodingKeys: String, CodingKey {
                case type
                case text
                case imageURL = "image_url"
            }

            static func text(_ text: String) -> Self {
                Self(type: .text, text: text, imageURL: nil)
            }

            static func image(url: String) -> Self {
                Self(type: .imageURL, text: nil, imageURL: ImageURL(url: url))
            }
        }

        struct ImageURL: Encodable {
            let url: String
        }
    }

    enum Role: String, Encodable {
        case developer
        case user
        case assistant
    }

    enum PartType: String, Encodable {
        case text
        case imageURL = "image_url"
    }

    struct Response: Decodable {
        let choices: [Choice]?

        var firstNonemptyText: String? {
            choices?
                .flatMap { choice in
                    [choice.message?.content?.text, choice.text]
                }
                .compactMap { $0 }
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .first { !$0.isEmpty }
        }

        struct Choice: Decodable {
            let message: Message?
            let text: String?
        }

        struct Message: Decodable {
            let content: Content?
        }

        enum Content: Decodable {
            case text(String)
            case parts([Part])

            init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()
                if let text = try? container.decode(String.self) {
                    self = .text(text)
                } else if let parts = try? container.decode([Part].self) {
                    self = .parts(parts)
                } else {
                    self = .text("")
                }
            }

            var text: String {
                switch self {
                case .text(let text):
                    text
                case .parts(let parts):
                    parts.compactMap(\.text).joined()
                }
            }
        }

        struct Part: Decodable {
            let text: String?
        }
    }
}
