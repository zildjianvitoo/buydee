import Foundation

enum ImageAttachmentError: LocalizedError {
    case invalidImage
    case encodingFailed

    var errorDescription: String? {
        switch self {
        case .invalidImage:
            "Gambar tidak dapat dibaca. Pilih atau ambil gambar lain, ya."
        case .encodingFailed:
            "Gambar belum bisa diproses. Coba gunakan gambar lain."
        }
    }
}
