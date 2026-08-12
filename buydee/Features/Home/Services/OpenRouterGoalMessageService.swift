import Foundation

struct OpenRouterGoalMessageService: GoalMessageGenerating {
    private let configuration: AIConfiguration
    private let credentialStore: OpenRouterCredentialStore
    private let session: URLSession

    init(
        configuration: AIConfiguration = .goalMessage,
        credentialStore: OpenRouterCredentialStore = OpenRouterCredentialStore(),
        session: URLSession = .shared
    ) {
        self.configuration = configuration
        self.credentialStore = credentialStore
        self.session = session
    }

    func goalMessage(savedAmount: Int, goal: String) async throws -> String {
        try Task.checkCancellation()

        let body = Request(
            model: configuration.model,
            messages: [
                Request.Message(role: .developer, content: GoalMessagePrompt.developerMessage),
                Request.Message(
                    role: .user,
                    content: GoalMessagePrompt.renderInput(savedAmount: savedAmount, goal: goal)
                )
            ],
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

            guard let answer = decodedResponse.firstNonemptyText,
                  let message = Self.sanitized(answer) else {
                throw ChatServiceError.emptyResponse
            }
            return message
        } catch is CancellationError {
            throw CancellationError()
        } catch let error as URLError where error.code == .cancelled {
            throw CancellationError()
        }
    }

    /// Keeps only the single motivational sentence, even when the model echoes the
    /// surrounding template or wraps the answer in markdown.
    private static func sanitized(_ rawMessage: String) -> String? {
        let lines = rawMessage
            .replacing("*", with: "")
            .replacing("#", with: "")
            .split(whereSeparator: \Character.isNewline)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        let sentence = lines.first { $0.lowercased().hasPrefix("that") } ?? lines.first
        guard let sentence else { return nil }

        let message = sentence.trimmingCharacters(in: Self.decorationCharacters)
        guard !message.isEmpty, message.count <= Self.maximumMessageLength else { return nil }
        return message
    }

    private static let decorationCharacters = CharacterSet(charactersIn: "\"'“”‘’-— \t")
    private static let maximumMessageLength = 240
}

private extension OpenRouterGoalMessageService {
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
            let content: String
        }
    }

    enum Role: String, Encodable {
        case developer
        case user
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
