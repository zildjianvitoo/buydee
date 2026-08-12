import Foundation

struct AIConfiguration: Sendable {
    let endpoint: URL
    let model: String
    let maximumHistoryCount: Int
    let maximumOutputTokens: Int
    let timeout: TimeInterval

    static let `default` = AIConfiguration(
        endpoint: openRouterEndpoint,
        model: "openai/gpt-5.6-luna",
        maximumHistoryCount: 12,
        maximumOutputTokens: 2_048,
        timeout: 90
    )

    private static let openRouterEndpoint: URL = {
        guard let endpoint = URL(string: "https://openrouter.ai/api/v1/chat/completions") else {
            fatalError("The bundled OpenRouter endpoint is invalid.")
        }
        return endpoint
    }()
}
