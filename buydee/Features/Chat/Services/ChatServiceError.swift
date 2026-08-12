import Foundation

enum ChatServiceError: LocalizedError {
    case missingAPIKey
    case invalidResponse
    case requestFailed(statusCode: Int)
    case emptyResponse

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            "OpenRouter API key belum tersedia. Tambahkan OPENROUTER_API_KEY melalui environment Xcode."
        case .invalidResponse:
            "Respons AI tidak dapat dibaca. Coba lagi, ya."
        case .requestFailed(let statusCode):
            "AI belum bisa dihubungi (kode \(statusCode)). Coba beberapa saat lagi."
        case .emptyResponse:
            "AI belum memberi jawaban. Coba kirim ulang pesanmu."
        }
    }
}
