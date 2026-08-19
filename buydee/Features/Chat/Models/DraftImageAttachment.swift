import Foundation

struct DraftImageAttachment: Equatable, Sendable {
    let jpegData: Data

    var dataURL: String {
        "data:image/jpeg;base64,\(jpegData.base64EncodedString())"
    }
}
