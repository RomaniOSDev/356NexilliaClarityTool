import SwiftUI

struct UndoBanner: View {
    let message: String
    let onUndo: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Text(message)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(Color("AppTextPrimary"))
                .lineLimit(2)
            Spacer()
            Button("Undo", action: onUndo)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(Color("AppPrimary"))
                .contentShape(Rectangle())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color("AppSurface"))
        .overlay(
            Rectangle()
                .fill(Color("AppPrimary"))
                .frame(height: 2),
            alignment: .top
        )
        .pinkGlow()
        .padding(.horizontal, 16)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}
