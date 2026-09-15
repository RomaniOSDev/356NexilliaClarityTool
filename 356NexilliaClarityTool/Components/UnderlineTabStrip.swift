import SwiftUI

enum PlannerTab: String, CaseIterable, Identifiable {
    case syllabus = "Syllabus"
    case snaps = "Snaps"
    case plans = "Plans"
    case board = "Board"
    case stats = "Stats"

    var id: String { rawValue }

    var heading: String {
        switch self {
        case .syllabus: return "Class Roster"
        case .snaps: return "Quick Ideas"
        case .plans: return "Full Plans"
        case .board: return "Subject Board"
        case .stats: return "Ink Stats"
        }
    }
}

struct UnderlineTabStrip: View {
    @Binding var selection: PlannerTab
    var revisionCount: Int = 0

    var body: some View {
        HStack(spacing: 0) {
            ForEach(PlannerTab.allCases) { tab in
                Button {
                    selection = tab
                } label: {
                    VStack(spacing: 6) {
                        ZStack(alignment: .topTrailing) {
                            Text(tab.rawValue)
                                .font(.system(size: 13, weight: selection == tab ? .bold : .medium, design: .rounded))
                                .tracking(-0.45)
                                .foregroundColor(
                                    selection == tab
                                        ? Color("AppTextPrimary")
                                        : Color("AppTextSecondary")
                                )
                                .lineLimit(1)
                                .minimumScaleFactor(0.72)
                                .frame(maxWidth: .infinity)
                            if tab == .plans, revisionCount > 0 {
                                Text(revisionCount > 9 ? "9+" : "\(revisionCount)")
                                    .font(.system(size: 9, weight: .bold, design: .rounded))
                                    .foregroundColor(Color("AppTextPrimary"))
                                    .padding(.horizontal, 4)
                                    .padding(.vertical, 1)
                                    .background(Color("AppPrimary"))
                                    .offset(x: 8, y: -6)
                            }
                        }
                        Rectangle()
                            .fill(selection == tab ? Color("AppPrimary") : Color.clear)
                            .frame(height: 2.5)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 6)
        .contentShape(Rectangle())
        .background(Color("AppBackground").opacity(0.01))
        .zIndex(4)
    }
}
