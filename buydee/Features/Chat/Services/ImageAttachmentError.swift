import Foundation

enum ImageAttachmentError: LocalizedError {
    case invalidImage
    case encodingFailed

    var errorDescription: String? {
        message(in: .primaryDefault)
    }

    func message(in language: ChatLanguage) -> String {
        switch self {
        case .invalidImage:
            language.text(
                indonesian: "Gambar tidak dapat dibaca. Pilih atau ambil gambar lain, ya.",
                english: "The image could not be read. Choose or take another image."
            )
        case .encodingFailed:
            language.text(
                indonesian: "Gambar belum bisa diproses. Coba gunakan gambar lain.",
                english: "The image could not be processed. Try another image."
            )
        }
    }
}
