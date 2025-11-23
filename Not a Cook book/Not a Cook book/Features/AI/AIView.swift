import SwiftUI
import UIKit

struct AIView: View {
    // MARK: - State
    @State private var messages: [ChatMessage] = [
        .init(text: "Hi! Send a meal photo and I’ll guess the dish and ingredients.", isUser: false)
    ]
    @State private var input = ""
    @State private var showCamera = false
    @State private var showLibrary = false
    @State private var busy = false

    var body: some View {
        ZStack {
            // Backdrop so glass pops
            LinearGradient(
                colors: [Color.black.opacity(0.88), Color.black.opacity(0.78)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Glassy header (rounded only at bottom)
                GlassHeader(title: "AI Chat Bot", subtitle: "Scan meals • get ingredients")

                // Messages
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(messages) { m in
                                MessageRow(message: m)
                                    .id(m.id)
                                    .transition(.opacity.combined(with: .move(edge: m.isUser ? .trailing : .leading)))
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 14)
                    }
                    .onChange(of: messages) { _ in
                        if let last = messages.last {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                withAnimation(.easeInOut) { proxy.scrollTo(last.id, anchor: .bottom) }
                            }
                        }
                    }
                }
            }

            // Loading overlay (prevents “freeze” feel)
            if busy {
                ZStack {
                    Color.black.opacity(0.35).ignoresSafeArea()
                    ProgressView("Analyzing…")
                        .padding(16)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.1), lineWidth: 1))
                }
                .transition(.opacity)
            }
        }
        // Floating glass input bar (safe above keyboard)
        .safeAreaInset(edge: .bottom) {
            GlassInputBar(
                text: $input,
                isBusy: busy,
                onLibrary: { showLibrary = true },
                onCamera:  { showCamera  = true },
                onSend:    { send() }
            )
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        // Pickers (one sheet at a time)
        .sheet(isPresented: $showLibrary) {
            ImagePicker(source: .library) { img in analyze(img) }
                .ignoresSafeArea()
        }
        .sheet(isPresented: $showCamera) {
            ImagePicker(source: .camera) { img in analyze(img) }
                .ignoresSafeArea()
        }
        .navigationBarHidden(true)
    }

    // MARK: - Actions

    private func send() {
        let text = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        messages.append(.init(text: text, isUser: true))
        input = ""

        // (Optional) quick canned reply
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            messages.append(.init(text: "Got it! You can also tap the camera to analyze a meal photo.", isUser: false))
        }
    }

    /// Direct OpenAI Vision (no Spoonacular/servers). Also dismisses sheets ASAP to avoid UI contention.
    private func analyze(_ image: UIImage) {
        // Dismiss active sheet immediately so UIKit isn’t juggling two presentations
        if showCamera { showCamera = false }
        if showLibrary { showLibrary = false }

        Task {
            busy = true
            defer { busy = false }
            do {
                let result = try await OpenAIService.shared.analyze(image: image)
                let list = result.ingredients.map { $0.name }.joined(separator: ", ")
                messages.append(.init(
                    text: "🍽️ Dish: **\(result.dish)**\n🥗 Ingredients: \(list)",
                    isUser: false
                ))
            } catch {
                messages.append(.init(
                    text: "❌ Analysis failed: \(error.localizedDescription)",
                    isUser: false
                ))
            }
        }
    }
}

// MARK: - Glassy Components

/// Frosted header with rounded bottom corners
private struct GlassHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.custom("Inter-Black", size: 26))
            Text(subtitle)
                .font(.custom("Inter-Regular", size: 13))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .background(.thinMaterial)
        .clipShape(RoundedCorner(radius: 22, corners: [.bottomLeft, .bottomRight]))
        .overlay(
            RoundedCorner(radius: 22, corners: [.bottomLeft, .bottomRight])
                .stroke(Color.white.opacity(0.07), lineWidth: 1)
        )
    }
}

/// One chat bubble: pink for user, glass for assistant
private struct MessageRow: View {
    let message: ChatMessage
    var body: some View {
        HStack {
            if message.isUser { Spacer(minLength: 40) }
            Text(message.text)
                .font(.custom("Inter-Regular", size: 15))
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
                .background(
                    message.isUser
                    ? AnyView(Capsule().fill(AppColor.accentPink))
                    : AnyView(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(.ultraThinMaterial))
                )
                .foregroundStyle(message.isUser ? .white : .primary)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(message.isUser ? 0 : 0.12), lineWidth: 1)
                )
            if !message.isUser { Spacer(minLength: 40) }
        }
    }
}

/// Floating glass input with plus / search field / send / camera
private struct GlassInputBar: View {
    @Binding var text: String
    var isBusy: Bool
    var onLibrary: () -> Void
    var onCamera: () -> Void
    var onSend: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            GlassIconButton(system: "plus", action: onLibrary)
                .disabled(isBusy)

            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass").opacity(0.85)
                TextField("Ask or Make an Image", text: $text)
                    .textFieldStyle(.plain)
                    .disabled(isBusy)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .background(.ultraThinMaterial, in: Capsule())
            .overlay(Capsule().stroke(Color.white.opacity(0.15), lineWidth: 1))

            GlassIconButton(system: "paperplane.fill", action: onSend)
                .disabled(isBusy)

            GlassIconButton(system: "camera", action: onCamera)
                .disabled(isBusy)
        }
        .padding(10)
        .background(.thinMaterial, in: Capsule())
        .overlay(Capsule().stroke(Color.white.opacity(0.08), lineWidth: 1))
        .shadow(color: .black.opacity(0.25), radius: 12, x: 0, y: 8)
    }
}

private struct GlassIconButton: View {
    let system: String
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            Image(systemName: system)
                .font(.system(size: 16, weight: .semibold))
                .padding(10)
        }
        .background(.ultraThinMaterial, in: Capsule())
        .overlay(Capsule().stroke(Color.white.opacity(0.15), lineWidth: 1))
    }
}

// Rounded corners utility that supports stroke(inset) semantics
private struct RoundedCorner: InsettableShape {
    var radius: CGFloat = 12
    var corners: UIRectCorner = .allCorners
    var insetAmount: CGFloat = 0

    func path(in rect: CGRect) -> Path {
        let r = rect.insetBy(dx: insetAmount, dy: insetAmount)
        let path = UIBezierPath(
            roundedRect: r,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }

    func inset(by amount: CGFloat) -> some InsettableShape {
        var copy = self
        copy.insetAmount += amount
        return copy
    }
}
