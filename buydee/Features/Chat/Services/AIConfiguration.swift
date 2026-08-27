import Foundation

struct AIConfiguration: Sendable {
    let endpoint: URL
    let model: String
    let maximumHistoryCount: Int
    let maximumOutputTokens: Int
    let reasoningEffort: ReasoningEffort
    let excludesReasoningFromResponse: Bool
    let timeout: TimeInterval

    static let `default` = AIConfiguration(
        endpoint: openRouterEndpoint,
        model: "openai/gpt-5.6-luna",
        maximumHistoryCount: 12,
        maximumOutputTokens: 2_048,
        reasoningEffort: .low,
        excludesReasoningFromResponse: true,
        timeout: 90
    )

    static let goalMessage = AIConfiguration(
        endpoint: openRouterEndpoint,
        model: "openai/gpt-5.6-luna",
        maximumHistoryCount: 0,
        maximumOutputTokens: 256,
        reasoningEffort: .low,
        excludesReasoningFromResponse: true,
        timeout: 30
    )

    private static let openRouterEndpoint: URL = {
        guard let endpoint = URL(string: "https://openrouter.ai/api/v1/chat/completions") else {
            fatalError("The bundled OpenRouter endpoint is invalid.")
        }
        return endpoint
    }()
}
