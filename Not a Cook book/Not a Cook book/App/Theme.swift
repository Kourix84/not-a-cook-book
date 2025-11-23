import SwiftUI

enum AppColor {
    static let accentPink  = Color(red: 1.00, green: 0.30, blue: 0.60)
    static let accentGreen = Color(red: 0.60, green: 0.90, blue: 0.60)
    static let panel       = Color(.secondarySystemBackground)
}

extension Font {
    static func inter(_ weight: String, _ size: CGFloat) -> Font {
        .custom("Inter-\(weight)", size: size) // e.g., "Inter-Black"
    }
}

extension View {
    func roundedPanel() -> some View {
        self.padding()
            .background(AppColor.panel)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .shadow(radius: 8, x: 0, y: 4)
    }
}
