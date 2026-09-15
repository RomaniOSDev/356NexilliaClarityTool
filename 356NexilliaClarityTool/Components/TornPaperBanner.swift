import SwiftUI

struct TornPaperShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let xs: [CGFloat] = [0, 0.07, 0.15, 0.24, 0.33, 0.42, 0.51, 0.61, 0.72, 0.83, 0.92, 1]
        let top: [CGFloat] = [6, 13, 4, 15, 7, 16, 5, 14, 8, 12, 4, 10]
        let bottom: [CGFloat] = [9, 4, 14, 6, 16, 5, 13, 7, 15, 4, 12, 8]

        path.move(to: CGPoint(x: 0, y: top[0]))
        for index in 1..<xs.count {
            path.addLine(to: CGPoint(x: rect.width * xs[index], y: top[index]))
        }
        path.addLine(to: CGPoint(x: rect.width, y: rect.height - bottom[bottom.count - 1]))
        for index in stride(from: xs.count - 1, through: 0, by: -1) {
            path.addLine(to: CGPoint(x: rect.width * xs[index], y: rect.height - bottom[index]))
        }
        path.closeSubpath()
        return path
    }
}

struct TornPaperBanner: View {
    var caption: String = "Open the planner. Mark the period."

    var body: some View {
        Color.clear
            .frame(maxWidth: .infinity)
            .frame(height: 148)
            .background {
                Image("banner_planner")
                    .resizable()
                    .scaledToFill()
                    .allowsHitTesting(false)
            }
            .clipped()
            .contentShape(TornPaperShape())
            .overlay {
                LinearGradient(
                    stops: [
                        .init(color: Color("AppBackground").opacity(0.05), location: 0.0),
                        .init(color: Color("AppPrimary").opacity(0.28), location: 0.38),
                        .init(color: Color("AppBackground").opacity(0.72), location: 1.0)
                    ],
                    startPoint: UnitPoint(x: 0.05, y: 0.0),
                    endPoint: UnitPoint(x: 0.95, y: 1.0)
                )
            }
            .overlay(alignment: .bottomLeading) {
                Text(caption)
                    .roundedTitle(15, weight: .semibold)
                    .foregroundColor(Color("AppTextPrimary"))
                    .padding(.horizontal, 18)
                    .padding(.bottom, 16)
            }
            .clipShape(TornPaperShape())
            .allowsHitTesting(false)
            .pinkGlow()
            .padding(.horizontal, 14)
    }
}
