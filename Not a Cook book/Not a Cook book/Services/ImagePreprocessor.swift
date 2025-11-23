import UIKit

enum ImagePreprocessor {
    static func prepare(_ image: UIImage, maxEdge: CGFloat = 1024, quality: CGFloat = 0.6) async throws -> Data {
        try await withCheckedThrowingContinuation { cont in
            DispatchQueue.global(qos: .userInitiated).async {
                let resized = resize(image, maxEdge: maxEdge)
                guard let jpeg = resized.jpegData(compressionQuality: quality) else {
                    return cont.resume(throwing: NSError(domain: "ImagePreprocessor", code: -1, userInfo: [
                        NSLocalizedDescriptionKey: "JPEG encode failed"
                    ]))
                }
                cont.resume(returning: jpeg)
            }
        }
    }

    private static func resize(_ image: UIImage, maxEdge: CGFloat) -> UIImage {
        let size = image.size
        let longest = max(size.width, size.height)
        guard longest > maxEdge else { return image }
        let scale = maxEdge / longest
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)

        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
        return renderer.image { _ in image.draw(in: CGRect(origin: .zero, size: newSize)) }
    }
}
