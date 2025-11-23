import Foundation
import UIKit

enum ImgBBUploader {
    static let apiKey = "da25505be4c24d62dd1d98dda32c18e9" // <-- replace with your key

    static func upload(_ image: UIImage) async throws -> URL {
        // JPEG bytes (no base64; avoids 400 Invalid base64)
        guard let jpeg = image.jpegData(compressionQuality: 0.9) else {
            throw URLError(.dataNotAllowed)
        }
        guard let url = URL(string: "https://api.imgbb.com/1/upload") else {
            throw URLError(.badURL)
        }

        // Build multipart/form-data request
        let boundary = "Boundary-\(UUID().uuidString)"
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        // field: key
        body.appendString("--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"key\"\r\n\r\n")
        body.appendString("\(apiKey)\r\n")
        // field: image
        body.appendString("--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"image\"; filename=\"photo.jpg\"\r\n")
        body.appendString("Content-Type: image/jpeg\r\n\r\n")
        body.append(jpeg)
        body.appendString("\r\n")
        // end
        body.appendString("--\(boundary)--\r\n")
        req.httpBody = body

        let (respData, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse else { throw URLError(.badServerResponse) }

        if http.statusCode != 200 {
            let bodyText = String(data: respData, encoding: .utf8) ?? "<no body>"
            print("❌ ImgBB \(http.statusCode): \(bodyText)")
            throw URLError(.badServerResponse)
        }

        struct Resp: Codable {
            struct D: Codable { let url: String?; let display_url: String? }
            let data: D
        }
        let decoded = try JSONDecoder().decode(Resp.self, from: respData)

        if let s = decoded.data.display_url ?? decoded.data.url,
           let u = URL(string: s) {
            return u
        }
        throw URLError(.badURL)
    }
}

// Helper to append strings to Data
private extension Data {
    mutating func appendString(_ string: String) {
        if let d = string.data(using: .utf8) { append(d) }
    }
}
