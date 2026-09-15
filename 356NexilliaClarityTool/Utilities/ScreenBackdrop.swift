import SwiftUI
import UIKit

enum Keyboard {
    static func dismiss() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

extension View {
    func plannerScreenBackground() -> some View {
        frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                Color("AppBackground")
                    .overlay {
                        Image("bg_classroom")
                            .resizable()
                            .scaledToFill()
                            .opacity(0.22)
                            .allowsHitTesting(false)
                    }
                    .clipped()
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }
    }

    func pinkGlow() -> some View {
        shadow(color: Color("AppPrimary").opacity(0.48), radius: 8, x: 0, y: 4)
    }

    func roundedTitle(_ size: CGFloat, weight: Font.Weight = .bold) -> some View {
        font(.system(size: size, weight: weight, design: .rounded))
            .tracking(-0.55)
    }

    func editorKeyboardDone() -> some View {
        toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { Keyboard.dismiss() }
                    .foregroundColor(Color("AppPrimary"))
            }
        }
    }

    func addInkButton(action: @escaping () -> Void) -> some View {
        safeAreaInset(edge: .bottom, spacing: 0) {
            Color.clear
                .frame(height: 58)
                .allowsHitTesting(false)
        }
        .overlay(alignment: .bottomTrailing) {
            InkIconButton(symbol: "plus", action: action)
                .padding(.trailing, 20)
                .padding(.bottom, 12)
        }
    }
}
