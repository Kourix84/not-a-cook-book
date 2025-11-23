import Foundation

public struct ChatMessage: Identifiable, Hashable, Codable {
    public let id: UUID
    public var text: String
    public var isUser: Bool

    public init(id: UUID = UUID(), text: String, isUser: Bool) {
        self.id = id
        self.text = text
        self.isUser = isUser
    }
}
