import SwiftUI

struct ParallelogramChip: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let cut: CGFloat = min(10, rect.width * 0.18)
        path.move(to: CGPoint(x: cut, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        path.addLine(to: CGPoint(x: rect.width - cut, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.closeSubpath()
        return path
    }
}

struct SubjectChip: View {
    let subject: Subject

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: subject.stampSymbol)
                .font(.system(size: 10, weight: .semibold))
            Text(subject.rawValue)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .tracking(-0.2)
        }
        .foregroundColor(Color("AppTextPrimary"))
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            ParallelogramChip()
                .fill(Color("AppSurface").opacity(0.85))
        )
        .overlay(
            ParallelogramChip()
                .stroke(Color("AppPrimary"), lineWidth: 1.4)
        )
    }
}

struct TagChip: View {
    let label: String

    var body: some View {
        Text(label)
            .font(.system(size: 11, weight: .medium, design: .rounded))
            .tracking(-0.15)
            .foregroundColor(Color("AppTextPrimary"))
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(
                ParallelogramChip()
                    .fill(Color("AppBackground").opacity(0.45))
            )
            .overlay(
                ParallelogramChip()
                    .stroke(Color("AppAccent"), lineWidth: 1)
            )
    }
}
