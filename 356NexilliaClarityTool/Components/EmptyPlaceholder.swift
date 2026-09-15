import SwiftUI

struct EmptyPlaceholder: View {
    let title: String
    let symbol: String
    var hint: String = ""

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: symbol)
                .font(.system(size: 42, weight: .medium))
                .foregroundColor(Color("AppPrimary"))
                .shadow(color: Color("AppPrimary").opacity(0.45), radius: 8, x: 0, y: 4)
            Text(title)
                .roundedTitle(20)
                .foregroundColor(Color("AppTextPrimary"))
                .multilineTextAlignment(.center)
            if !hint.isEmpty {
                Text(hint)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(Color("AppTextSecondary"))
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 28)
        .padding(.vertical, 36)
    }
}
