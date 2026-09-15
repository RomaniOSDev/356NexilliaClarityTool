import SwiftUI

struct LayeredSurface<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            VStack(spacing: 10) {
                Circle()
                    .fill(Color("AppBackground"))
                    .frame(width: 8, height: 8)
                    .overlay(Circle().stroke(Color("AppPrimary").opacity(0.45), lineWidth: 1))
                Circle()
                    .fill(Color("AppBackground"))
                    .frame(width: 8, height: 8)
                    .overlay(Circle().stroke(Color("AppPrimary").opacity(0.45), lineWidth: 1))
            }
            .padding(.top, 6)
            content
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(14)
        .background(
            LinearGradient(
                colors: [Color("AppBackground").opacity(0.55), Color("AppSurface")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .overlay(
            Rectangle()
                .fill(Color("AppPrimary"))
                .frame(width: 3),
            alignment: .leading
        )
        .contentShape(Rectangle())
        .pinkGlow()
    }
}
