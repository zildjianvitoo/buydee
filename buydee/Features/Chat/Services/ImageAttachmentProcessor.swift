import CoreImage
import Foundation
import ImageIO
import UniformTypeIdentifiers

actor ImageAttachmentProcessor {
    private let maximumPixelDimension = 2_048.0
    private let jpegQuality = 0.82
    private let context = CIContext(options: [.cacheIntermediates: false])

    func process(_ data: Data) throws -> DraftImageAttachment {
        guard !data.isEmpty,
              let sourceImage = CIImage(
                data: data,
                options: [.applyOrientationProperty: true]
              ) else {
            throw ImageAttachmentError.invalidImage
        }

        let longestDimension = max(sourceImage.extent.width, sourceImage.extent.height)
        guard longestDimension > 0 else {
            throw ImageAttachmentError.invalidImage
        }

        let scale = min(1, maximumPixelDimension / longestDimension)
        let preparedImage = sourceImage.transformed(
            by: CGAffineTransform(scaleX: scale, y: scale)
        )
        guard let cgImage = context.createCGImage(
            preparedImage,
            from: preparedImage.extent
        ) else {
            throw ImageAttachmentError.encodingFailed
        }

        let jpegData = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(
            jpegData,
            UTType.jpeg.identifier as CFString,
            1,
            nil
        ) else {
            throw ImageAttachmentError.encodingFailed
        }
        CGImageDestinationAddImage(
            destination,
            cgImage,
            [kCGImageDestinationLossyCompressionQuality: jpegQuality] as CFDictionary
        )
        guard CGImageDestinationFinalize(destination) else {
            throw ImageAttachmentError.encodingFailed
        }

        return DraftImageAttachment(jpegData: jpegData as Data)
    }
}
