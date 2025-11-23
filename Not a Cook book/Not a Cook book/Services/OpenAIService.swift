import Foundation
import UIKit

struct VisionIngredient: Codable, Hashable {
    let name: String
    let quantity: String?
    let confidence: Double?
}

struct VisionResult: Codable {
    let dish: String
    let ingredients: [VisionIngredient]
}

final class OpenAIService {
    static let shared = OpenAIService()

    private let apiKey: String = {
        let raw = Bundle.main.object(forInfoDictionaryKey: "OPENAI_API_KEY") as? String
        let key = raw?.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let key, !key.isEmpty else {
            print("❌ OPENAI_API_KEY missing in Info.plist (app target).")
            return ""
        }
        return key
    }()

    func analyze(image: UIImage) async throws -> VisionResult {
        guard !apiKey.isEmpty else {
            throw NSError(domain: "OpenAI", code: -100, userInfo: [
                NSLocalizedDescriptionKey: "Missing OPENAI_API_KEY in Info.plist (app target)."
            ])
        }

        // Downscale + compress off the main thread
        let jpegData = try await ImagePreprocessor.prepare(image, maxEdge: 1024, quality: 0.6)
        let base64 = jpegData.base64EncodedString()

        var req = URLRequest(url: URL(string: "https://api.openai.com/v1/chat/completions")!)
        req.httpMethod = "POST"
        req.timeoutInterval = 60
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        req.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let body: [String: Any] = [
            "model": "gpt-4o-mini",
            "temperature": 0.15,
            "response_format": ["type": "json_object"],
            "messages": [
                [
                    "role": "system",
                    "content": "You are a food assistant. Detect the dish and list likely ingredients. Output ONLY JSON."
                ],
                [
                    "role": "user",
                    "content": [
                        ["type": "text", "text":
                         """
                         Return EXACT JSON only:
                         {"dish": string, "ingredients": [{"name": string, "quantity": string|null, "confidence": number|null}]}
                         """],
                        ["type": "image_url",
                         "image_url": ["url": "data:image/jpeg;base64,\(base64)"]]
                    ]
                ]
            ]
        ]
        req.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse else {
            throw NSError(domain: "OpenAI", code: -1, userInfo: [NSLocalizedDescriptionKey: "No HTTP response"])
        }

        struct Envelope: Decodable {
            struct Choice: Decodable { struct Message: Decodable { let content: String } ; let message: Message }
            let choices: [Choice]
        }

        if (200...299).contains(http.statusCode) {
            let env = try JSONDecoder().decode(Envelope.self, from: data)
            guard let content = env.choices.first?.message.content.data(using: .utf8) else {
                throw NSError(domain: "OpenAI", code: -2, userInfo: [NSLocalizedDescriptionKey: "Empty completion"])
            }
            return try JSONDecoder().decode(VisionResult.self, from: content)
        } else {
            let err = String(data: data, encoding: .utf8) ?? "<no body>"
            throw NSError(domain: "OpenAI", code: http.statusCode,
                          userInfo: [NSLocalizedDescriptionKey: "OpenAI error \(http.statusCode): \(err)"])
        }
    }
}

