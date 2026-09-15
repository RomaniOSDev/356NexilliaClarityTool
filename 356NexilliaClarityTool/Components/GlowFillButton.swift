import SwiftUI

struct GlowFillButton: View {
    let title: String
    let symbol: String
    var enabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: symbol)
                Text(title)
            }
            .roundedTitle(16, weight: .semibold)
            .foregroundColor(Color("AppTextPrimary"))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                LinearGradient(
                    colors: enabled
                        ? [Color("AppPrimary"), Color("AppAccent")]
                        : [Color("AppSurface"), Color("AppSurface")],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
        .pinkGlow()
        .disabled(!enabled)
        .opacity(enabled ? 1 : 0.55)
    }
}

struct InkIconButton: View {
    let symbol: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(Color("AppTextPrimary"))
                .frame(width: 44, height: 44)
                .background(Color("AppPrimary"))
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
        .pinkGlow()
    }
}
