import Foundation

enum ChatServiceError: LocalizedError {
    case missingAPIKey
    case invalidResponse
    case requestFailed(statusCode: Int)
    case emptyResponse

    var errorDescription: String? {
        message(in: .primaryDefault)
    }

    func message(in language: ChatLanguage) -> String {
        switch self {
        case .missingAPIKey:
            language.text(
                indonesian: "OpenRouter API key belum tersedia. Tambahkan OPENROUTER_API_KEY melalui environment Xcode.",
                english: "The OpenRouter API key is unavailable. Add OPENROUTER_API_KEY through the Xcode environment."
            )
        case .invalidResponse:
            language.text(
                indonesian: "Respons belum dapat dibaca. Coba lagi, ya.",
                english: "The response could not be read. Please try again."
            )
        case .requestFailed(let statusCode):
            language.text(
                indonesian: "Layanan belum bisa dihubungi dengan kode \(statusCode). Coba beberapa saat lagi.",
                english: "The service could not be reached with code \(statusCode). Please try again shortly."
            )
        case .emptyResponse:
            language.text(
                indonesian: "Belum ada jawaban yang diterima. Coba kirim ulang pesanmu.",
                english: "No answer was received. Please send your message again."
            )
        }
    }
}
