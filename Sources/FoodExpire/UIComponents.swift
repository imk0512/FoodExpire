import SwiftUI

struct TitleFont: ViewModifier {
    func body(content: Content) -> some View {
        content.font(.system(size: 20, weight: .bold))
    }
}

extension View {
    func titleFont() -> some View {
        self.modifier(TitleFont())
    }
}

struct BodyFont: ViewModifier {
    func body(content: Content) -> some View {
        content.font(.system(size: 16))
    }
}

extension View {
    func bodyFont() -> some View {
        self.modifier(BodyFont())
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .bold))
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(Color.accentColor)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}
