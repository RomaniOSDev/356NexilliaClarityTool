import SwiftUI

private let inkPlaceholderColor = Color("AppTextPrimary").opacity(0.55)

struct WorksheetField: View {
    let label: String
    @Binding var text: String
    var prompt: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label.uppercased())
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .tracking(0.6)
                .foregroundColor(Color("AppTextSecondary"))
            ZStack(alignment: .leading) {
                if text.isEmpty, !prompt.isEmpty {
                    Text(prompt)
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                        .tracking(-0.3)
                        .foregroundColor(inkPlaceholderColor)
                        .allowsHitTesting(false)
                }
                TextField("", text: $text)
                    .textFieldStyle(.plain)
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .tracking(-0.3)
                    .foregroundColor(Color("AppTextPrimary"))
                    .tint(Color("AppPrimary"))
                    .submitLabel(.done)
                    .onSubmit { Keyboard.dismiss() }
            }
            .padding(.bottom, 6)
            Rectangle()
                .fill(Color("AppPrimary"))
                .frame(height: 1.6)
        }
    }
}

struct WorksheetEditor: View {
    let label: String
    @Binding var text: String
    var prompt: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label.uppercased())
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .tracking(0.6)
                .foregroundColor(Color("AppTextSecondary"))
            ZStack(alignment: .topLeading) {
                TextEditor(text: $text)
                    .scrollContentBackground(.hidden)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(Color("AppTextPrimary"))
                    .tint(Color("AppPrimary"))
                    .frame(minHeight: 88, maxHeight: 160)
                    .padding(.horizontal, -4)
                if text.isEmpty, !prompt.isEmpty {
                    Text(prompt)
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundColor(inkPlaceholderColor)
                        .padding(.top, 8)
                        .padding(.leading, 1)
                        .allowsHitTesting(false)
                }
            }
            Rectangle()
                .fill(Color("AppPrimary"))
                .frame(height: 1.6)
        }
    }
}
