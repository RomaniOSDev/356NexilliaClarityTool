import SwiftUI

struct RuledNotebookCanvas: View {
    var body: some View {
        Canvas { context, size in
            let spacing: CGFloat = 30
            var y: CGFloat = 18
            var rules = Path()
            while y < size.height {
                rules.move(to: CGPoint(x: 0, y: y))
                rules.addLine(to: CGPoint(x: size.width, y: y))
                y += spacing
            }
            context.stroke(
                rules,
                with: .color(Color("AppTextPrimary").opacity(0.06)),
                lineWidth: 1
            )

            var margin = Path()
            margin.move(to: CGPoint(x: 20, y: 0))
            margin.addLine(to: CGPoint(x: 20, y: size.height))
            context.stroke(
                margin,
                with: .color(Color("AppPrimary").opacity(0.22)),
                lineWidth: 1.4
            )
        }
        .allowsHitTesting(false)
    }
}
