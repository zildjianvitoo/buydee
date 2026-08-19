import Foundation
import NaturalLanguage

enum ChatLanguage: String, Sendable {
    case indonesian
    case english

    static var primaryDefault: Self { .english }

    static func detected(from text: String, fallback: Self) -> Self {
        let normalized = text.lowercased()
        let indonesianSignals = [
            "aku", "saya", "mau", "pengen", "ingin", "beli", "harga",
            "karena", "tapi", "buat", "nggak", "gak", "udah", "yang",
        ]
        let englishSignals = [
            "i", "me", "my", "want", "buy", "price", "because", "but",
            "for", "need", "already", "this", "that", "the",
        ]
        let words = Set(
            normalized.split { !$0.isLetter }.map(String.init)
        )
        let indonesianScore = indonesianSignals.reduce(0) { score, word in
            score + (words.contains(word) ? 1 : 0)
        }
        let englishScore = englishSignals.reduce(0) { score, word in
            score + (words.contains(word) ? 1 : 0)
        }

        if indonesianScore != englishScore {
            return indonesianScore > englishScore ? .indonesian : .english
        }

        switch NLLanguageRecognizer.dominantLanguage(for: text) {
        case .indonesian:
            return .indonesian
        case .english:
            return .english
        default:
            return fallback
        }
    }

    var sessionPromptInstruction: String {
        switch self {
        case .indonesian:
            "Gunakan Bahasa Indonesia untuk SEMUA content yang terlihat pengguna selama sesi ini, termasuk bubble eksplorasi, Summary, pertanyaan BUY/BYE, respons penutup, dan acknowledgement keputusan. Jangan berganti ke English hanya karena ada istilah, nama produk, atau pesan singkat berbahasa English."
        case .english:
            "Use English for ALL user-visible content throughout this session, including exploration bubbles, the Summary, the BUY/BYE question, closing responses, and decision acknowledgements. Do not switch to Indonesian because of an Indonesian term, product name, or short Indonesian message."
        }
    }

    var earlySummaryRequest: String {
        switch self {
        case .indonesian:
            "Hentikan eksplorasi sekarang dan langsung buat Summary terbaik dari konteks yang sudah ada. Jangan ajukan pertanyaan klarifikasi atau pertanyaan eksplorasi lagi. Jika konteksnya belum cukup, katakan dengan jujur di dalam Summary bahwa konteksnya masih terbatas dan sebutkan informasi yang belum diketahui sebagai pernyataan, bukan pertanyaan. Tetap akhiri dengan pilihan BUY atau BYE dan marker internal Summary yang valid."
        case .english:
            "Stop the exploration now and immediately provide the best Summary possible from the available context. Do not ask another clarification or exploration question. If context is insufficient, say honestly in the Summary that it is limited and state what is still unknown without phrasing it as a question. Still end with the BUY or BYE choice and valid internal Summary markers."
        }
    }

    var imageOnlyCaption: String {
        switch self {
        case .indonesian:
            "Identifikasi barang dan harga yang terlihat, lalu bantu aku mempertimbangkannya sebelum membeli."
        case .english:
            "Identify the visible item and price, then help me think it through before buying."
        }
    }

    var insufficientSummary: String {
        switch self {
        case .indonesian:
            "Konteks yang ada masih terbatas, jadi Summary ini belum bisa menangkap alasan dan pertimbanganmu secara lengkap. Kamu tetap bisa menentukan pilihan dari informasi yang sudah ada."
        case .english:
            "The available context is still limited, so this Summary cannot fully capture your reasons and considerations. You can still decide using the information already available."
        }
    }

    var decisionQuestion: String {
        switch self {
        case .indonesian:
            "Kalau untuk sekarang, kamu pilih **BUY** atau **BYE**?"
        case .english:
            "For now, do you choose **BUY** or **BYE**?"
        }
    }

    func text(indonesian: String, english: String) -> String {
        self == .indonesian ? indonesian : english
    }
}
